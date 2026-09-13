#!/usr/bin/env python3
"""Build a printable computer-services punch list from Xero invoice JSON.

Splits every invoice line into Equipment vs Labor (plus Services / Other / Notes),
renders one section per invoice (phase), and writes a self-contained HTML page
that works as a checklist in the browser and prints cleanly on Letter paper.

Usage:
  build_punchlist.py invoices.json [more.json ...] -o punchlist.html
      [--invoices I-10383,I-10384]      only these invoice numbers (default: all)
      [--customer "Adams Beef Company"] override customer name
      [--site "123 Main St, Durant OK"] site / address line
      [--project "Fall 2026 network buildout"]
      [--company "Computer Services of Durant, Inc."] [--tagline "csdurant.com"]
      [--prepared-by "Chris Pierce"] [--logo path.png]   (default: logo.png beside this script)
      [--title "Adams Beef Punch List"]
      [--item "Decide on internet service | Josh"]  pre-filled action item (repeatable)
      [--reclass "I-10304:U7 Pro Max=equipment"]   force a line into a bucket

Input: the JSON returned by the Xero MCP get_invoices tool (an object with an
"invoices" list) or a bare list of invoice objects. Files are merged.
"""
import argparse
import base64
import datetime as dt
import html
import json
import mimetypes
import os
import re
import sys
from decimal import Decimal, ROUND_HALF_UP

BUCKETS = ("equipment", "labor", "service", "other")

LABOR_RE = re.compile(
    r"^\s*labor\s*-\s*(?P<cat>[^()]+?)\s*(?:\((?P<unit>[^)]*)\))?\s*(?:-\s*(?P<task>.+))?\s*$",
    re.I,
)
REF_RE = re.compile(r"^\s*Q(\d+)", re.I)


def dec(v):
    if v is None or v == "":
        return Decimal("0")
    return Decimal(str(v))


def money(v):
    v = Decimal(v).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    sign = "-" if v < 0 else ""
    return f"{sign}${abs(v):,.2f}"


def qty_str(q):
    q = Decimal(q)
    if q == q.to_integral():
        return f"{int(q)}"
    return f"{q.normalize()}"


def esc(s):
    return html.escape(str(s if s is not None else ""), quote=True)


def norm_invnum(s):
    s = s.strip().upper()
    m = re.match(r"^I-?(\d+)$", s)
    return f"I-{m.group(1)}" if m else s


def fmt_date(iso):
    try:
        d = dt.date.fromisoformat(iso)
        return d.strftime("%b %-d, %Y")
    except Exception:
        return iso or ""


# ---------------------------------------------------------------- classify

def classify(line):
    """Return one of: note, labor, service, other, equipment."""
    code = (line.get("item_code") or "").strip().upper()
    desc = (line.get("description") or "").strip()
    acct = str(line.get("account_code") or "")
    if line.get("quantity") is None and line.get("unit_amount") is None:
        return "note"
    if code.startswith("LBR-") or code.startswith("TRIP-"):
        return "labor"
    if code.startswith("SVC-"):
        return "service"
    if code == "SHIPPING":
        return "other"
    if desc.lower().startswith("labor"):
        return "labor"
    if not code:
        # Free-typed line with no inventory item: adjustments, prorates, credits.
        return "other" if acct == "4100" else "equipment"
    return "equipment"


def parse_labor(line):
    """-> (category, task, unit_word)"""
    desc = (line.get("description") or "").strip()
    name = (line.get("item_name") or "").strip()
    m = LABOR_RE.match(desc)
    if m:
        cat = m.group("cat").strip()
        task = (m.group("task") or "").strip().rstrip(".")
        unit = (m.group("unit") or "").strip()
        return cat, task, unit
    m2 = LABOR_RE.match(name)
    if m2:
        return m2.group("cat").strip(), desc.rstrip("."), (m2.group("unit") or "").strip()
    # Trip charge and anything else
    cat = re.sub(r"\s*\(.*?\)\s*", "", name or desc).strip()
    return cat, "", ""


def qty_unit(bucket, line):
    code = (line.get("item_code") or "").upper()
    desc = (line.get("description") or "").lower()
    if bucket == "labor":
        if code.startswith("TRIP-") or "per mile" in desc:
            return "mi"
        return "hr"
    if code.endswith("-FT") or "per foot" in desc or "(per ft" in desc:
        return "ft"
    return ""


# ---------------------------------------------------------------- build model

def load_invoices(paths):
    out = []
    for p in paths:
        with open(p) as f:
            data = json.load(f)
        if isinstance(data, dict):
            data = data.get("invoices", [])
        out.extend(data)
    # de-dupe by invoice number
    seen, uniq = set(), []
    for inv in out:
        n = inv.get("invoice_number")
        if n in seen:
            continue
        seen.add(n)
        uniq.append(inv)
    return uniq


def phase_sort_key(ph):
    """--phase overrides print in the order given; then Q1, Q2...; then by invoice number.
    Takes a built phase record (keys "ref" and "number"), not a raw invoice."""
    ref = (ph.get("ref") or "").strip()
    num = ph.get("number") or ""
    order = list(PHASE_NAMES)
    for key in (ref.lower(), num.lower()):
        if key and key in order:
            return (0, order.index(key), num)
    m = REF_RE.match(ref)
    if m:
        return (1, int(m.group(1)), num)
    return (2, 0, num)


def build_model(invoices, reclass):
    phases = []
    for inv in invoices:
        rows = {b: [] for b in BUCKETS}
        notes = []
        for i, line in enumerate(inv.get("line_items", [])):
            bucket = classify(line)
            key = f"{inv.get('invoice_number')}:{line.get('description','')}"
            for pat, forced in reclass:
                if pat in key:
                    bucket = forced
            if bucket == "note":
                notes.append((line.get("description") or "").strip())
                continue
            qty = dec(line.get("quantity"))
            net = dec(line.get("line_amount_net"))
            disc = dec(line.get("line_discount_amount"))
            tax = dec(line.get("line_tax_amount"))
            row = {
                "idx": i,
                "bucket": bucket,
                "desc": (line.get("description") or "").strip(),
                "code": (line.get("item_code") or "").strip(),
                "qty": qty,
                "unit": qty_unit(bucket, line),
                "rate": dec(line.get("unit_amount")),
                "net": net,
                "tax": tax,
                "discount": disc,
                "no_charge": net == 0 and disc > 0,
            }
            if bucket == "labor":
                row["cat"], row["task"], _ = parse_labor(line)
            rows[bucket].append(row)
        phases.append({
            "number": inv.get("invoice_number"),
            "ref": (inv.get("reference") or "").strip(),
            "date": inv.get("invoice_date") or "",
            "status": inv.get("status") or "",
            "total": dec(inv.get("amount_total")),
            "net": dec(inv.get("amount_net")),
            "tax": dec(inv.get("amount_tax")),
            "rows": rows,
            "notes": [n for n in notes if n],
        })
    phases.sort(key=phase_sort_key)
    return phases


def totals(phases):
    t = {b: Decimal("0") for b in BUCKETS}
    t_tax = {b: Decimal("0") for b in BUCKETS}
    hours = Decimal("0")
    grand = Decimal("0")
    n_items = 0
    for ph in phases:
        grand += ph["total"]
        for b in BUCKETS:
            for r in ph["rows"][b]:
                t[b] += r["net"]
                t_tax[b] += r["tax"]
                if b in ("equipment", "labor"):
                    n_items += 1
                if b == "labor" and r["unit"] == "hr":
                    hours += r["qty"]
    return t, t_tax, hours, grand, n_items


# ---------------------------------------------------------------- render

CSS = r"""
:root{
  --paper:#EEF1EE; --sheet:#FFFFFF; --ink:#1B2126; --muted:#5B666D; --faint:#8A959B;
  --rule:#C9D1CF; --rule-soft:#E2E7E5; --box:#1B2126;
  --brand:#20406A; --brand-2:#8C9ED2; --logo-plate:transparent; --logo-pad:0;
  --equip:var(--brand); --equip-soft:#E9EDF6; --labor:#9A5A14; --labor-soft:#F8EEDF;
  --svc:#3D6F5A; --svc-soft:#E4F0EA; --shadow:0 1px 2px rgba(20,30,40,.08),0 12px 32px -18px rgba(20,30,40,.25);
}
@media (prefers-color-scheme: dark){
  :root:not([data-theme="light"]){
    --paper:#0F1315; --sheet:#181E22; --ink:#E7ECEA; --muted:#A3AEB4; --faint:#6E7A81;
    --rule:#3A464E; --rule-soft:#28323A; --box:#E7ECEA;
    --brand:#9DAEE0; --brand-2:#8C9ED2; --logo-plate:#FFFFFF; --logo-pad:6px 10px;
    --equip:var(--brand); --equip-soft:#1E2B45; --labor:#E5A257; --labor-soft:#3A2B17;
    --svc:#7CC4A4; --svc-soft:#1C3128; --shadow:none;
  }
}
:root[data-theme="dark"]{
  --paper:#0F1315; --sheet:#181E22; --ink:#E7ECEA; --muted:#A3AEB4; --faint:#6E7A81;
  --rule:#3A464E; --rule-soft:#28323A; --box:#E7ECEA;
  --brand:#9DAEE0; --brand-2:#8C9ED2; --logo-plate:#FFFFFF; --logo-pad:6px 10px;
  --equip:var(--brand); --equip-soft:#1E2B45; --labor:#E5A257; --labor-soft:#3A2B17;
  --svc:#7CC4A4; --svc-soft:#1C3128; --shadow:none;
}
*{box-sizing:border-box}
body{margin:0;background:var(--paper);color:var(--ink);
  font-family:"IBM Plex Sans",-apple-system,"Segoe UI",Helvetica,Arial,sans-serif;
  font-size:14px;line-height:1.45;padding-inline:16px;padding-block:24px;
  -webkit-print-color-adjust:exact;print-color-adjust:exact}
.page{max-width:8.5in;margin:0 auto;background:var(--sheet);box-shadow:var(--shadow);
  padding-inline:clamp(18px,4vw,52px);padding-block:40px 48px}
h1,h2,h3{font-family:"IBM Plex Sans Condensed","IBM Plex Sans","Arial Narrow",Arial,sans-serif;
  margin:0;text-wrap:balance;line-height:1.1}
.mono{font-family:"IBM Plex Mono",ui-monospace,SFMono-Regular,Menlo,monospace}
.num{font-variant-numeric:tabular-nums}
.eyebrow{font-family:"IBM Plex Sans Condensed","Arial Narrow",Arial,sans-serif;font-weight:600;
  text-transform:uppercase;letter-spacing:.12em;font-size:11px;color:var(--muted)}

/* header */
.doc-head{display:grid;grid-template-columns:1fr auto;gap:18px 32px;align-items:end;
  padding-bottom:18px;border-bottom:3px solid var(--brand)}
.brand{display:flex;flex-direction:column;gap:10px;align-items:flex-start}
.brand .logo{display:block;height:72px;width:auto;max-width:100%;background:var(--logo-plate);
  padding:var(--logo-pad);border-radius:6px;box-sizing:content-box}
.brand .co{font-family:"IBM Plex Sans Condensed","Arial Narrow",Arial,sans-serif;font-weight:600;
  font-size:12px;letter-spacing:.12em;text-transform:uppercase;color:var(--muted)}
.brand .co span{font-weight:500;letter-spacing:.04em;text-transform:none;font-family:"IBM Plex Mono",ui-monospace,Menlo,monospace;font-size:11px}
h1{font-size:44px;font-weight:700;letter-spacing:-.01em;margin-top:2px;color:var(--brand)}
.docid{text-align:right;color:var(--muted);font-size:12px;line-height:1.6}
.docid b{display:block;color:var(--ink);font-size:14px}
.meta{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:12px 28px;
  margin:0;padding:16px 0 4px;border-bottom:1px solid var(--rule)}
.meta div{display:flex;flex-direction:column;gap:2px;min-width:0}
.meta dt{margin:0}
.meta dd{margin:0;font-weight:500;overflow-wrap:anywhere}
.meta dd.blank{border-bottom:1px solid var(--rule);min-height:22px}
.meta dd .inv{display:inline-block;margin-right:8px}

/* summary strip */
.summary{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));
  gap:0;margin:22px 0 8px;border:1px solid var(--rule);border-radius:4px;overflow:hidden}
.summary div{padding:12px 16px;border-right:1px solid var(--rule-soft);display:flex;flex-direction:column;gap:2px}
.summary div:last-child{border-right:0}
.summary .v{font-family:"IBM Plex Sans Condensed","Arial Narrow",Arial,sans-serif;font-size:24px;font-weight:600;line-height:1.1}
.summary .s{font-size:11px;color:var(--muted)}
.summary .k-equip{box-shadow:inset 0 3px 0 var(--equip)}
.summary .k-labor{box-shadow:inset 0 3px 0 var(--labor)}
.summary .k-total{background:color-mix(in srgb,var(--ink) 4%,transparent)}

/* controls */
.controls{display:flex;flex-wrap:wrap;gap:10px 18px;align-items:center;margin:10px 0 6px;
  font-size:12px;color:var(--muted)}
.controls label{display:inline-flex;align-items:center;gap:6px;cursor:pointer}
.controls button{font:inherit;font-size:12px;padding:4px 10px;border:1px solid var(--rule);
  border-radius:4px;background:transparent;color:var(--ink);cursor:pointer}
.controls button:hover{border-color:var(--ink)}
.controls .grow{flex:1}
.controls .prog{color:var(--muted)}
:focus-visible{outline:2px solid var(--equip);outline-offset:2px}

/* phases */
.phase{margin-top:30px;border-top:1px solid var(--rule);padding-top:14px}
.phase-head{display:flex;flex-wrap:wrap;align-items:baseline;gap:8px 14px;margin-bottom:12px}
.phase-head h2{font-size:22px;font-weight:700}
.phase-head .ref{font-family:"IBM Plex Mono",ui-monospace,Menlo,monospace;font-size:12px;
  padding:2px 8px;border:1px solid var(--ink);border-radius:3px;letter-spacing:.02em}
.phase-head .inv{font-family:"IBM Plex Mono",ui-monospace,Menlo,monospace;font-size:12px;color:var(--muted)}
.phase-head .date{font-size:12px;color:var(--muted)}
.phase-head .cnt{margin-left:auto;font-size:12px;color:var(--muted)}
.phase-head .cnt b{color:var(--ink)}

.bucket{display:flex;align-items:center;gap:10px;margin:14px 0 6px}
.bucket h3{font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.14em}
.bucket .sub{font-family:"IBM Plex Mono",ui-monospace,Menlo,monospace;font-size:11px;color:var(--muted)}
.bucket::before{content:"";width:10px;height:10px;border-radius:2px;background:var(--b)}
.bucket.equipment{--b:var(--equip)} .bucket.labor{--b:var(--labor)} .bucket.service{--b:var(--svc)}

.tbl{overflow-x:auto}
table{width:100%;border-collapse:collapse;break-inside:auto}
thead th{font-family:"IBM Plex Sans Condensed","Arial Narrow",Arial,sans-serif;font-weight:600;
  font-size:11px;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);text-align:left;
  padding:4px 8px 6px;border-bottom:1px solid var(--rule);white-space:nowrap}
tbody td{padding:7px 8px;border-bottom:1px solid var(--rule-soft);vertical-align:top}
tbody tr{break-inside:avoid}
tbody tr:last-child td{border-bottom:1px solid var(--rule)}
td.ck{width:32px;padding-left:2px;padding-right:2px;text-align:center}
td.q{width:74px;white-space:nowrap;text-align:right;font-family:"IBM Plex Mono",ui-monospace,Menlo,monospace;font-size:13px}
td.q small{color:var(--muted);font-size:11px;margin-left:2px}
td.item{min-width:200px}
td.item .code{display:block;font-family:"IBM Plex Mono",ui-monospace,Menlo,monospace;font-size:10.5px;color:var(--faint);margin-top:1px}
td.item .cat{display:inline-block;font-size:10.5px;font-weight:600;letter-spacing:.06em;text-transform:uppercase;
  color:var(--labor);background:var(--labor-soft);padding:1px 6px;border-radius:3px;margin-right:6px;vertical-align:1px}
td.item .task{font-weight:500}
td.fill{width:34%;min-width:150px}
td.fill input{width:100%;font:inherit;font-size:12.5px;color:var(--ink);background:transparent;
  border:0;border-bottom:1px solid var(--rule);padding:2px 2px 3px;border-radius:0}
td.fill input::placeholder{color:var(--faint)}
td.fill input:focus{outline:none;border-bottom-color:var(--equip)}
td.amt{width:96px;text-align:right;white-space:nowrap;font-family:"IBM Plex Mono",ui-monospace,Menlo,monospace;font-size:13px}
td.amt .nc{font-size:10.5px;color:var(--muted);letter-spacing:.04em;text-transform:uppercase}
tr.done td.item{color:var(--muted)}
tr.done td.item .task,tr.done td.item .name{text-decoration:line-through;text-decoration-color:var(--faint)}
tfoot td{padding:6px 8px 0;font-size:12px;color:var(--muted);text-align:right}
tfoot td b{color:var(--ink);font-family:"IBM Plex Mono",ui-monospace,Menlo,monospace;font-weight:500}
.no-prices .amt,.no-prices .money,.no-prices tfoot{display:none}

input[type=checkbox].box{appearance:none;-webkit-appearance:none;width:18px;height:18px;margin:2px 0 0;
  border:1.5px solid var(--box);border-radius:3px;background:transparent;cursor:pointer;display:inline-grid;place-content:center}
input[type=checkbox].box::before{content:"";width:10px;height:10px;transform:scale(0);
  background:var(--box);clip-path:polygon(14% 44%,0 65%,50% 100%,100% 16%,80% 0,43% 62%);transition:transform .08s}
input[type=checkbox].box:checked::before{transform:scale(1)}

.notes{margin-top:10px;padding:8px 12px;border-left:3px solid var(--rule);color:var(--muted);font-size:12.5px}
.notes .eyebrow{margin-bottom:2px}
.notes p{margin:2px 0;white-space:pre-line}

/* punch / signoff */
.punch{margin-top:34px;border-top:3px solid var(--ink);padding-top:14px;break-inside:avoid}
.punch h2{font-size:22px;font-weight:700;margin-bottom:4px}
.punch p{margin:0 0 10px;color:var(--muted);font-size:12.5px;max-width:65ch}
.lines{display:grid;gap:0}
.lines div{display:grid;grid-template-columns:32px 1fr 110px;gap:8px;align-items:end;height:32px;border-bottom:1px solid var(--rule)}
.lines .n{font-family:"IBM Plex Mono",ui-monospace,Menlo,monospace;font-size:11px;color:var(--faint);padding-bottom:4px}
.lines .lbl{font-size:10px;color:var(--faint);text-transform:uppercase;letter-spacing:.08em;padding-bottom:4px}
.lines .ai{height:auto;min-height:32px;padding:5px 0 5px;align-items:start}
.lines .ai input.box{margin-top:1px;justify-self:center}
.lines .txt{font-weight:500;padding-bottom:0}
.lines .own{font-size:12px;color:var(--ink);padding-bottom:0}
.lines .ai.done .txt{text-decoration:line-through;text-decoration-color:var(--faint);color:var(--muted)}
.sign{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:20px 36px;margin-top:30px;break-inside:avoid}
.sign div{display:grid;gap:26px}
.sign .line{border-bottom:1px solid var(--ink);height:34px;position:relative}
.sign .line span{position:absolute;left:0;bottom:-16px;font-size:10px;text-transform:uppercase;letter-spacing:.08em;color:var(--muted)}
.foot{margin-top:40px;font-size:11px;color:var(--faint);display:flex;justify-content:space-between;gap:16px;flex-wrap:wrap}

@media (max-width:560px){
  h1{font-size:34px}
  .doc-head{grid-template-columns:1fr}
  .docid{text-align:left}
  td.fill{min-width:130px}
}
@media print{
  :root{--paper:#fff;--sheet:#fff;--ink:#000;--muted:#444;--faint:#777;--rule:#999;--rule-soft:#ccc;--box:#000;
    --brand:#20406A;--brand-2:#8C9ED2;--logo-plate:transparent;--logo-pad:0;
    --equip:#20406A;--equip-soft:#E9EDF6;--labor:#9A5A14;--labor-soft:#F8EEDF;--svc:#3D6F5A;--svc-soft:#E4F0EA;--shadow:none}
  .brand .logo{height:64px}
  @page{size:letter;margin:.55in .6in}
  body{padding:0;font-size:12.5px}
  .page{max-width:none;padding:0;box-shadow:none}
  .controls{display:none}
  h1{font-size:36px}
  .phase{break-inside:auto}
  .paged .phase{break-before:page;border-top:0;margin-top:0;padding-top:0}
  .paged .punch{break-before:page}
  .phase-head,.bucket,thead{break-after:avoid}
  td.fill input{border-bottom-color:#999}
  a{color:inherit;text-decoration:none}
}
@media (prefers-reduced-motion:reduce){input[type=checkbox].box::before{transition:none}}
"""

JS = r"""
(function(){
  var KEY = 'punchlist:' + (document.body.dataset.docid || 'doc');
  var state = {};
  try { state = JSON.parse(localStorage.getItem(KEY) || '{}') || {}; } catch (e) { state = {}; }
  function save(){ try { localStorage.setItem(KEY, JSON.stringify(state)); } catch (e) {} }

  var boxes = Array.prototype.slice.call(document.querySelectorAll('input.box'));
  var fills = Array.prototype.slice.call(document.querySelectorAll('td.fill input'));

  function paintRow(b){ var tr = b.closest('tr, .lines > div'); if (tr) tr.classList.toggle('done', b.checked); }
  function counts(){
    document.querySelectorAll('.phase').forEach(function(ph){
      var all = ph.querySelectorAll('input.box'), n = 0;
      all.forEach(function(b){ if (b.checked) n++; });
      var el = ph.querySelector('.cnt'); if (el) el.innerHTML = '<b>' + n + '</b> of ' + all.length + ' checked';
    });
    var t = document.getElementById('prog');
    if (t) { var n = 0; boxes.forEach(function(b){ if (b.checked) n++; }); t.textContent = n + ' of ' + boxes.length + ' items checked'; }
  }

  boxes.forEach(function(b){
    if (state[b.id]) b.checked = true;
    paintRow(b);
    b.addEventListener('change', function(){ state[b.id] = b.checked ? 1 : 0; if (!b.checked) delete state[b.id]; paintRow(b); counts(); save(); });
  });
  fills.forEach(function(i){
    if (typeof state[i.id] === 'string') i.value = state[i.id];
    i.addEventListener('input', function(){ if (i.value) state[i.id] = i.value; else delete state[i.id]; save(); });
  });

  var prices = document.getElementById('showPrices');
  function applyPrices(){ document.documentElement.classList.toggle('no-prices', prices && !prices.checked); }
  if (prices) {
    if (state.__hidePrices) prices.checked = false;
    prices.addEventListener('change', function(){ state.__hidePrices = prices.checked ? 0 : 1; if (prices.checked) delete state.__hidePrices; applyPrices(); save(); });
    applyPrices();
  }

  var printBtn = document.getElementById('printBtn');
  if (printBtn) printBtn.addEventListener('click', function(){ window.print(); });

  var clearBtn = document.getElementById('clearBtn'), armed = null;
  if (clearBtn) clearBtn.addEventListener('click', function(){
    if (armed) {
      clearTimeout(armed); armed = null;
      boxes.forEach(function(b){ b.checked = false; paintRow(b); });
      fills.forEach(function(i){ i.value = ''; });
      var keep = state.__hidePrices; state = {}; if (keep) state.__hidePrices = keep;
      save(); counts(); clearBtn.textContent = 'Clear all checks';
    } else {
      clearBtn.textContent = 'Click again to clear';
      armed = setTimeout(function(){ armed = null; clearBtn.textContent = 'Clear all checks'; }, 3000);
    }
  });
  counts();
})();
"""


def render_equipment_table(ph, rows):
    if not rows:
        return ""
    sub = sum(r["net"] for r in rows)
    tax = sum(r["tax"] for r in rows)
    out = [f'<div class="bucket equipment"><h3>Equipment</h3>'
           f'<span class="sub">{len(rows)} line{"s" if len(rows)!=1 else ""}</span></div>',
           '<div class="tbl"><table>',
           '<thead><tr><th></th><th style="text-align:right">Qty</th><th>Item</th>'
           '<th>Serial / Location</th><th style="text-align:right" class="amt">Amount</th></tr></thead><tbody>']
    for r in rows:
        rid = f"{ph['number']}-{r['idx']}"
        unit = f"<small>{r['unit']}</small>" if r["unit"] else ""
        code = f'<span class="code">{esc(r["code"])}</span>' if r["code"] else ""
        amt = money(r["net"])
        out.append(
            f'<tr><td class="ck"><input type="checkbox" class="box" id="ck-{esc(rid)}" '
            f'aria-label="Installed: {esc(r["desc"])}"></td>'
            f'<td class="q num">{qty_str(r["qty"])}{unit}</td>'
            f'<td class="item"><span class="name">{esc(r["desc"])}</span>{code}</td>'
            f'<td class="fill"><input type="text" id="sn-{esc(rid)}" placeholder="" '
            f'aria-label="Serial or location for {esc(r["desc"])}"></td>'
            f'<td class="amt num">{amt}</td></tr>'
        )
    out.append("</tbody>")
    out.append(f'<tfoot><tr><td colspan="5">Equipment subtotal <b>{money(sub)}</b>'
               + (f' &nbsp;·&nbsp; tax <b>{money(tax)}</b>' if tax else "") + "</td></tr></tfoot>")
    out.append("</table></div>")
    return "\n".join(out)


def render_labor_table(ph, rows):
    if not rows:
        return ""
    sub = sum(r["net"] for r in rows)
    hrs = sum(r["qty"] for r in rows if r["unit"] == "hr")
    out = [f'<div class="bucket labor"><h3>Labor</h3>'
           f'<span class="sub">{qty_str(hrs)} hr{"s" if hrs != 1 else ""} billed</span></div>',
           '<div class="tbl"><table>',
           '<thead><tr><th></th><th>Task</th><th style="text-align:right">Time</th>'
           '<th>Done by / Date</th><th style="text-align:right" class="amt">Amount</th></tr></thead><tbody>']
    for r in rows:
        rid = f"{ph['number']}-{r['idx']}"
        cat, task = r.get("cat", ""), r.get("task", "")
        if task:
            item = f'<span class="cat">{esc(cat)}</span><span class="task">{esc(task)}</span>'
        else:
            item = f'<span class="task">{esc(cat)}</span>'
        unit = f"<small>{r['unit']}</small>" if r["unit"] else ""
        if r["no_charge"]:
            amt = f'<span class="nc">No charge</span>'
        else:
            amt = money(r["net"])
        out.append(
            f'<tr><td class="ck"><input type="checkbox" class="box" id="ck-{esc(rid)}" '
            f'aria-label="Complete: {esc(task or cat)}"></td>'
            f'<td class="item">{item}</td>'
            f'<td class="q num">{qty_str(r["qty"])}{unit}</td>'
            f'<td class="fill"><input type="text" id="by-{esc(rid)}" placeholder="" '
            f'aria-label="Completed by and date for {esc(task or cat)}"></td>'
            f'<td class="amt num">{amt}</td></tr>'
        )
    out.append("</tbody>")
    out.append(f'<tfoot><tr><td colspan="5">Labor subtotal <b>{money(sub)}</b></td></tr></tfoot>')
    out.append("</table></div>")
    return "\n".join(out)


def render_service_table(ph, rows, title, css_class):
    if not rows:
        return ""
    sub = sum(r["net"] for r in rows)
    out = [f'<div class="bucket {css_class}"><h3>{esc(title)}</h3></div>',
           '<div class="tbl"><table>',
           '<thead><tr><th></th><th style="text-align:right">Qty</th><th>Item</th>'
           '<th>Notes</th><th style="text-align:right" class="amt">Amount</th></tr></thead><tbody>']
    for r in rows:
        rid = f"{ph['number']}-{r['idx']}"
        code = f'<span class="code">{esc(r["code"])}</span>' if r["code"] else ""
        out.append(
            f'<tr><td class="ck"><input type="checkbox" class="box" id="ck-{esc(rid)}" '
            f'aria-label="Provisioned: {esc(r["desc"])}"></td>'
            f'<td class="q num">{qty_str(r["qty"])}</td>'
            f'<td class="item"><span class="name">{esc(r["desc"])}</span>{code}</td>'
            f'<td class="fill"><input type="text" id="nt-{esc(rid)}" aria-label="Notes for {esc(r["desc"])}"></td>'
            f'<td class="amt num">{money(r["net"])}</td></tr>'
        )
    out.append("</tbody>")
    out.append(f'<tfoot><tr><td colspan="5">{esc(title)} subtotal <b>{money(sub)}</b></td></tr></tfoot>')
    out.append("</table></div>")
    return "\n".join(out)


def render(phases, args, customer):
    t, t_tax, hours, grand, n_items = totals(phases)
    inv_numbers = [p["number"] for p in phases]
    docid = "-".join(inv_numbers)
    today = dt.date.today().strftime("%b %-d, %Y")
    title = args.title or f"{customer} Punch List"
    site_dd = f'<dd>{esc(args.site)}</dd>' if args.site else '<dd class="blank"></dd>'
    project_block = (f'<div><dt class="eyebrow">Project</dt><dd>{esc(args.project)}</dd></div>'
                     if args.project else "")

    parts = []
    parts.append(f"<title>{esc(title)}</title>")
    parts.append('<link rel="preconnect" href="https://fonts.googleapis.com">')
    parts.append('<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500'
                 '&family=IBM+Plex+Sans+Condensed:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&display=swap">')
    parts.append(f"<style>{CSS}</style>")
    page_cls = "page paged" if args.page_per_phase else "page"
    parts.append(f'<div class="{page_cls}" data-docid="{esc(docid)}">')

    # header
    logo_uri = load_logo(args.logo)
    logo_html = (f'<img class="logo" src="{logo_uri}" alt="{esc(args.company)}">' if logo_uri
                 else f'<div class="co" style="font-size:20px;letter-spacing:.02em;text-transform:none;color:var(--ink)">{esc(args.company)}</div>')
    tagline = f' <span>· {esc(args.tagline)}</span>' if args.tagline else ""
    parts.append('<header class="doc-head">')
    parts.append(f'<div class="brand">{logo_html}'
                 f'<div class="co">{esc(args.company)}{tagline}</div>'
                 f'<h1>Punch List</h1></div>')
    parts.append(f'<div class="docid"><b>{esc(customer)}</b>'
                 f'{len(phases)} invoice{"s" if len(phases)!=1 else ""} · {n_items} punch items<br>Prepared {esc(today)}</div>')
    parts.append('</header>')

    parts.append('<dl class="meta">')
    parts.append(f'<div><dt class="eyebrow">Customer</dt><dd>{esc(customer)}</dd></div>')
    parts.append(f'<div><dt class="eyebrow">Site</dt>{site_dd}</div>')
    parts.append(project_block)
    parts.append(f'<div><dt class="eyebrow">Prepared by</dt><dd>{esc(args.prepared_by)}</dd></div>')
    invs = " ".join(f'<span class="inv mono">{esc(n)}</span>' for n in inv_numbers)
    parts.append(f'<div><dt class="eyebrow">Invoices</dt><dd>{invs}</dd></div>')
    parts.append('</dl>')

    # summary
    eq_total = t["equipment"] + t_tax["equipment"]
    any_tax = any(t_tax[b] for b in BUCKETS)
    eq_sub = (f'{money(t["equipment"])} + {money(t_tax["equipment"])} tax' if t_tax["equipment"]
              else f'{len([r for p in phases for r in p["rows"]["equipment"]])} lines · no sales tax')
    parts.append('<section class="summary" aria-label="Totals">')
    parts.append(f'<div class="k-equip money"><span class="eyebrow">Equipment</span>'
                 f'<span class="v num">{money(eq_total)}</span>'
                 f'<span class="s">{eq_sub}</span></div>')
    parts.append(f'<div class="k-labor money"><span class="eyebrow">Labor</span>'
                 f'<span class="v num">{money(t["labor"])}</span>'
                 f'<span class="s">{qty_str(hours)} hours of labor</span></div>')
    if t["service"] or t["other"]:
        parts.append(f'<div class="money"><span class="eyebrow">Services &amp; other</span>'
                     f'<span class="v num">{money(t["service"] + t["other"] + t_tax["service"] + t_tax["other"])}</span>'
                     f'<span class="s">hosting, shipping, adjustments</span></div>')
    parts.append(f'<div class="k-total money"><span class="eyebrow">Invoiced total</span>'
                 f'<span class="v num">{money(grand)}</span>'
                 f'<span class="s">{"includes tax" if any_tax else "no sales tax"}</span></div>')
    parts.append('</section>')

    # controls
    parts.append('<div class="controls">'
                 '<label><input type="checkbox" id="showPrices" checked> Show prices</label>'
                 '<button type="button" id="printBtn">Print</button>'
                 '<button type="button" id="clearBtn">Clear all checks</button>'
                 '<span class="grow"></span><span class="prog" id="prog"></span></div>')

    # phases
    for ph in phases:
        parts.append(f'<section class="phase" id="{esc(ph["number"])}">')
        ref = f'<span class="ref">{esc(ph["ref"])}</span>' if ph["ref"] else ""
        parts.append(f'<div class="phase-head">{ref}<h2>{esc(phase_title(ph))}</h2>'
                     f'<span class="inv">{esc(ph["number"])}</span>'
                     f'<span class="date">{esc(fmt_date(ph["date"]))}</span>'
                     f'<span class="cnt"></span></div>')
        parts.append(render_equipment_table(ph, ph["rows"]["equipment"]))
        parts.append(render_labor_table(ph, ph["rows"]["labor"]))
        parts.append(render_service_table(ph, ph["rows"]["service"], "Services", "service"))
        parts.append(render_service_table(ph, ph["rows"]["other"], "Other charges", "service"))
        if ph["notes"]:
            parts.append('<div class="notes"><div class="eyebrow">Notes from invoice</div>')
            for n in ph["notes"]:
                parts.append(f'<p>{esc(n)}</p>')
            parts.append('</div>')
        parts.append('</section>')

    # action items / signoff
    parts.append('<section class="punch"><h2>Action items</h2>'
                 '<p>Open decisions, anything not checked above, and anything found during walk-through, '
                 'each with an owner. The job is closed when every item is done and both parties have signed.</p>'
                 '<div class="lines">')
    n = 0
    for text, owner, due in parse_items(args.item):
        n += 1
        own = " · ".join(x for x in (owner, due) if x)
        parts.append(f'<div class="ai"><input type="checkbox" class="box" id="ai-{n}" aria-label="Done: {esc(text)}">'
                     f'<span class="txt">{esc(text)}</span>'
                     f'<span class="own">{esc(own) if own else "<span class=lbl>Owner / due</span>"}</span></div>')
    for _ in range(max(3, 6 - n)):
        n += 1
        parts.append(f'<div><span class="n">{n}</span><span></span><span class="lbl">Owner / due</span></div>')
    parts.append('</div></section>')
    parts.append('<section class="sign">'
                 '<div><div class="line"><span>Technician</span></div><div class="line"><span>Date</span></div></div>'
                 '<div><div class="line"><span>Customer acceptance</span></div><div class="line"><span>Date</span></div></div>'
                 '</section>')
    foot_co = esc(args.company) + (f' · {esc(args.tagline)}' if args.tagline else "")
    parts.append(f'<div class="foot"><span>{foot_co} · {esc(customer)} · {esc(docid)}</span>'
                 f'<span>Equipment and labor as invoiced in Xero.'
                 f'{" Amounts before tax except where noted." if any_tax else ""}</span></div>')
    parts.append('</div>')
    parts.append(f"<script>{JS}</script>")
    return "\n".join(p for p in parts if p)


def parse_items(specs):
    """'text | owner | due' -> (text, owner, due); owner and due optional."""
    out = []
    for spec in specs:
        bits = [b.strip() for b in spec.split("|")]
        text = bits[0] if bits else ""
        if not text:
            continue
        owner = bits[1] if len(bits) > 1 else ""
        due = bits[2] if len(bits) > 2 else ""
        out.append((text, owner, due))
    return out


def load_logo(path):
    """Return a data: URI for the logo, or "" if the file is missing/unreadable."""
    if not path:
        return ""
    try:
        with open(path, "rb") as f:
            raw = f.read()
    except OSError:
        print(f"WARNING: logo not found at {path}; falling back to text header", file=sys.stderr)
        return ""
    mime = mimetypes.guess_type(path)[0] or "image/png"
    return f"data:{mime};base64,{base64.b64encode(raw).decode('ascii')}"


PHASE_NAMES = {}


def phase_title(ph):
    """Turn 'Q4-Environmental-2' into 'Environmental', 'gasdock-1' into 'Gasdock'.
    --phase "ref=Title" overrides (matched case-insensitively on the full reference)."""
    ref = ph["ref"]
    if ref and ref.lower() in PHASE_NAMES:
        return PHASE_NAMES[ref.lower()]
    if (ph["number"] or "").lower() in PHASE_NAMES:
        return PHASE_NAMES[ph["number"].lower()]
    if not ref:
        return f"Invoice {ph['number']}"
    m = re.match(r"^\s*Q\d+\s*[-_ ]\s*(.+?)(?:\s*[-_ ]\s*\d+)?\s*$", ref, re.I)
    if m:
        name = m.group(1)
    else:
        name = re.sub(r"\s*[-_ ]\s*\d+\s*$", "", ref)  # strip trailing revision "-1"
    name = name.replace("-", " ").replace("_", " ").strip()
    return name.upper() if len(name) <= 4 else name[:1].upper() + name[1:]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("inputs", nargs="+", help="JSON file(s) from Xero get_invoices")
    ap.add_argument("-o", "--output", required=True, help="HTML file to write")
    ap.add_argument("--invoices", default="", help="comma-separated invoice numbers to include")
    ap.add_argument("--customer", default="")
    ap.add_argument("--site", default="")
    ap.add_argument("--project", default="")
    ap.add_argument("--company", default="Computer Services of Durant, Inc.")
    ap.add_argument("--tagline", default="csdurant.com", help='shown after the company name; "" to omit')
    ap.add_argument("--logo", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "logo.png"),
                    help='PNG/SVG/JPG embedded in the header; "" for a text-only header')
    ap.add_argument("--prepared-by", default="Chris Pierce")
    ap.add_argument("--title", default="")
    ap.add_argument("--item", action="append", default=[],
                    help='pre-filled action item: "text | owner | due" (owner and due optional); repeatable')
    ap.add_argument("--phase", action="append", default=[],
                    help='section title override: "<invoice reference>=<Title>"; repeatable')
    ap.add_argument("--page-per-phase", action="store_true",
                    help="start each invoice section on a new printed page (multi-site jobs)")
    ap.add_argument("--reclass", action="append", default=[],
                    help='"<invoice>:<description substring>=<bucket>" to force a line into equipment|labor|service|other')
    args = ap.parse_args()

    invoices = load_invoices(args.inputs)
    if args.invoices:
        want = {norm_invnum(x) for x in args.invoices.split(",") if x.strip()}
        got = {inv.get("invoice_number") for inv in invoices}
        missing = sorted(want - got)
        if missing:
            print(f"WARNING: not in input JSON: {', '.join(missing)}", file=sys.stderr)
        invoices = [inv for inv in invoices if inv.get("invoice_number") in want]
    if not invoices:
        sys.exit("No invoices to render.")

    for spec in args.phase:
        ref, _, title = spec.partition("=")
        if ref.strip() and title.strip():
            PHASE_NAMES[ref.strip().lower()] = title.strip()

    reclass = []
    for spec in args.reclass:
        pat, _, bucket = spec.rpartition("=")
        if bucket not in BUCKETS:
            sys.exit(f"--reclass bucket must be one of {BUCKETS}: {spec}")
        reclass.append((pat, bucket))

    customers = sorted({(inv.get("contact") or {}).get("name", "") for inv in invoices})
    if len(customers) > 1 and not args.customer:
        print(f"WARNING: invoices span multiple customers: {customers}", file=sys.stderr)
    customer = args.customer or customers[0] or "Customer"

    phases = build_model(invoices, reclass)
    with open(args.output, "w") as f:
        f.write(render(phases, args, customer))

    t, t_tax, hours, grand, n_items = totals(phases)
    print(f"Wrote {args.output}")
    print(f"  invoices : {', '.join(p['number'] for p in phases)}")
    print(f"  equipment: {money(t['equipment'])} net + {money(t_tax['equipment'])} tax")
    print(f"  labor    : {money(t['labor'])} ({qty_str(hours)} hrs)")
    if t["service"] or t["other"]:
        print(f"  services : {money(t['service'])}   other: {money(t['other'])}")
    print(f"  invoiced : {money(grand)} incl. tax  ·  {n_items} punch items")


if __name__ == "__main__":
    main()

---
name: punchlist
description: Build a computer-services punch list from Xero invoice numbers. Pulls the invoices, splits every line into Equipment vs Labor, and renders a printable install checklist (one section per invoice/phase) as an artifact. Use when the user gives Xero invoice numbers (I-#####) and asks for a punch list, install checklist, walk-through sheet, or an equipment-vs-labor split.
allowed-tools: Bash, Read, Write, Artifact, mcp__claude_ai_Xero__get_invoices, mcp__claude_ai_Xero__get_contacts
---

# Punch list from Xero invoices

A punch list is the field document for a job: every piece of equipment that has to be
installed and every labor task that has to be completed, each with a checkbox, plus
blank "outstanding items" lines and a technician / customer sign-off. The user hands
you Xero invoice numbers; you hand back a published artifact they can print or work
from on a phone.

**The template lives in `build_punchlist.py` next to this file.** Do not hand-author
the HTML. Run the script. If the user asks for a template change (a column, a
wording, a color), edit the script so the change sticks for every future punch list.

## Steps

### 1. Normalize the invoice numbers

Xero numbers look like `I-10383`. Users type them loosely (`I10384`, `i-10386`).
Normalize each to `I-<digits>` before anything else.

### 2. Pull the invoices from Xero

Use `mcp__claude_ai_Xero__get_invoices` with `include_line_items: true`. The tool has
no invoice-number filter, so scope the query:

- **Recent numbers:** query an issued-date range. Numbers run roughly 12 to 15 per
  week, so estimate the date from a known anchor and use a two-to-three week window.
- **Once one invoice is found:** re-query with that invoice's `contact_ids` and no
  date filter. Sibling invoices for the same job almost always share the customer,
  and that one call returns all of them.
- The tool pages at 30. Check `total_page_count` before concluding a number is
  missing.

**A number that does not come back is almost always a DRAFT.** The MCP tool returns
only approved (AUTHORISED) and PAID invoices. Say so and ask the user to approve it,
then re-pull. Do not guess line items and do not build the list without it unless the
user says to proceed.

Also watch for a number that belongs to a different customer than its neighbors
(e.g. I-10385 sat between four Adams Beef invoices but was Homegrown Meats). Only
include what the user asked for.

### 3. Write the invoice JSON

Save the invoice objects to `<scratchpad>/punchlist/<customer-slug>/invoices.json`
as `{"invoices": [ ... ]}`. Copy the objects from the tool result. The script reads
these fields and ignores the rest:

`invoice_number, reference, status, invoice_date, contact.name, amount_total,
amount_net, amount_tax, line_items[].{description, quantity, unit_amount,
line_amount_net, line_discount_amount, line_tax_amount, account_code, item_code,
item_name}`

Keep `null` quantities on note-only lines; the script turns those into "Notes from
invoice" callouts.

### 4. Build

```
python3 ~/.claude/skills/punchlist/build_punchlist.py \
  <scratchpad>/punchlist/<slug>/invoices.json \
  -o <scratchpad>/punchlist/<slug>/<slug>-punchlist.html \
  --invoices I-10383,I-10384 \
  [--site "..."] [--project "..."] [--title "<Customer> Punch List"]
```

Flags: `--customer` overrides the name; `--site` fills the Site line (otherwise a
blank write-in line is printed); `--project` adds a Project line; `--company`,
`--tagline` and `--prepared-by` default to Computer Services of Durant, Inc. /
csdurant.com / Chris Pierce; `--reclass "I-10304:U7 Pro Max=equipment"` forces one
line into a bucket when the rules below get it wrong.

**Action items.** `--item "text | owner | due"` (repeatable) pre-fills a line in the
Action items section with a checkbox, above the blank write-in lines. Use it when
the user says "add an action item for X to ..." Owner and due are optional.

**Multi-site jobs.** When one customer has an invoice per location (Grandpappy:
Restaurant, Gas Dock, Mill Creek, ...), keep it one document with one section per
invoice. `--phase "<reference or invoice number>=<Title>"` names each section (Xero
references like `gasdock-1` are not customer-readable) and the order you pass the
flags is the order the sections print. `--page-per-phase` starts each section on a
new printed page so a site's sheet can be handed to whoever is working there. Fix
obvious typos in the Xero contact name with `--customer` and say you did.

**Keep a `build.sh` per job** in the job's scratchpad folder holding the full
command with every flag (title, site, items, reclass). Re-runs after "do it again"
or "add an item" edit that script and re-execute it, so nothing added earlier is
lost.

**Branding.** The header carries the CS logo from `logo.png` beside this script
(a copy of `~/Dropbox/Design/CS Durant Files/Logo Files/CS_logo_flat.png`),
embedded as a data URI so the page is self-contained. Pass `--logo path` to swap it
or `--logo ""` for a text-only header. The page palette takes the logo's navy
(#20406A) for headings, rules and the equipment accent; labor stays amber so the
split reads at a glance. In dark mode the logo sits on a white plate.

The script prints the equipment / labor / hours / invoiced totals. Sanity-check them
against the invoice totals from Xero before publishing.

**Re-running after the user edits invoices in Xero** ("do it again, I updated
totals"): re-pull with the same `contact_ids` call, diff against the saved JSON, and
say in one line what actually changed (tax removed, a line added, a quantity moved).
If only tax or totals changed, update those fields in place rather than retyping the
file. Republish to the same artifact URL by using the same file path.

### 5. Publish

Publish the HTML with the Artifact tool. Title `<Customer> Punch List`, favicon 📋,
description naming the invoices covered. Then give the user the link, the totals
line, and anything the classifier flagged (multi-customer warning, missing numbers,
lines you reclassified).

## How lines are classified

Order matters; first rule that matches wins.

| Rule | Bucket |
|---|---|
| `quantity` and `unit_amount` both null | **Note** (rendered under the phase, no checkbox) |
| `item_code` starts with `LBR-` or `TRIP-` | **Labor** |
| `item_code` starts with `SVC-` | **Service** (hosting, domains, email; checkbox reads "provisioned") |
| `item_code` is `Shipping` | **Other** (totals only) |
| description starts with "Labor" | **Labor** |
| no `item_code`, `account_code` 4100 | **Other** (prorates, credits, adjustments) |
| everything else | **Equipment** |

Item code beats account code on purpose: Xero has a few inventory items filed under
4100 (the U7 Pro Max AP, for one) and a few services filed under 4000 (domains,
cloud backup). The item code is the reliable signal.

Labor descriptions follow `Labor - <Category> (Hourly) - <Task>`. The script shows
the task as the punch item with the category as a tag. When there is no task suffix,
the category itself is the line ("Server and Routing"). Labor `quantity` is hours;
`TRIP-` quantity is miles. A labor line discounted to $0 shows "No charge" and still
gets a checkbox because the work still has to happen.

## Phases

One section per invoice, ordered by reference when references look like `Q1-WIFI`,
`Q2-Phones-1`, otherwise by invoice number. The section title is the reference with
the `Q#` prefix and any trailing revision number stripped (`Q4-Environmental-2` reads
as "Environmental"). Each section has its Equipment table, then Labor, then Services
or Other if present, then the invoice notes.

## What the page does

- Checkboxes and the Serial / Location and Done by / Date fields persist per browser
  in localStorage, keyed by the invoice numbers, so a tech can work it on a phone.
- "Show prices" toggle hides every amount for a customer-facing or tech copy.
- Print button, Letter page setup, light palette forced on print, controls hidden.
- Six blank "Outstanding items" lines with an owner / due column, then Technician
  and Customer acceptance signature lines.

If the user wants checks shared across people (Chris marks on the laptop, the tech
sees it on the phone), that is the artifact `db` capability: load the
`artifact-capabilities` skill and swap the localStorage layer in the script's JS for
it. Do not do this unprompted.

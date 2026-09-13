# Fleet Standards — csdurant CakePHP Sites

> **Deploy:** Copy to `~/.claude/commands/fleet-standard.md` to enable globally.
> **Usage:** Type `/fleet-standard` when working on any fleet site — especially when
> migrating an old site up to standard. Pairs with `/cakephp` (framework rules);
> this skill covers what makes a site *fleet*, not what makes it CakePHP.

---
description: csdurant fleet standards — admin chrome, emails, SEO, phones, reorder, RTE, devproxy, deploys. The checklist of things every site must have.
allowed-tools: WebFetch, Bash, Read, Edit, Write, Glob, Grep
---

You are working on one of the csdurant fleet of CakePHP 5.3 sites. Everything below is
a **standard**, not a suggestion. When auditing or migrating a site, work the checklist
at the bottom. When the human says "bring X up to fleet standard," this file IS the spec.

## 0. Canonical sources — copy from these, in this order

1. **`~/Workspace/csdurant/_devproxy/templates/*.tpl`** — THE scaffolding source
   (compose.yml, Makefile, site.conf, dockerfile, custom.ini, github workflows,
   AdminController, UsersController w/ TOTP, HostHeaderMiddleware, Installer,
   app_local templates, login/2FA templates). Sed the `{{PROJECT_NAME}}`/`{{HOSTNAME}}`/
   `{{DOMAIN}}` placeholders. Prefer these over copying from a sibling site.
2. **`caleraok.org`** — admin.css base, sitemap.xsl pattern, Mailer classes,
   rte.js, admin-reorder.js, phpstan.neon. ⚠️ NOT its email templates — they
   have the `<style>`-block + double-document bug (§5); copy adarentals instead.
3. **`adarentals.com`** — top-bar user menu (avatar dropdown), icon-only row actions
   (`element/admin/row_actions.php`), HTML email templates (fully inline styles +
   content-only email layout).
4. **`joneslawpc.net`** — invite-only user creation, drag-to-reorder endpoint,
   icon actions in lists, GA4 placement.
5. **`blackburnlpg.com`** — newest full migration; dark public design reference,
   invisible reCAPTCHA v3, Choices.js dark scoping, SEO/OG/JSON-LD head, tank-gauge
   example of a site "signature" element.

Fleet git history is the changelog of these standards — `git log --oneline` in the
siblings before inventing anything new.

## 1. Local dev — the shared _devproxy stack

- One Traefik (`dev-proxy`) binds :80/:443 for the whole fleet; one `dev-db` MySQL;
  one `dev-mailcatcher` (http://localhost:1080). Sites publish **no ports**.
- Site `compose.yml`: app (php-fpm) + nginx with Traefik labels for
  `dev.<domain>`; container names `<project>-php_app` / `<project>-nginx`;
  nginx fastcgi_pass targets the **unique container name**, never `app`
  (shared network → DNS round-robin hits the wrong site).
- nginx site.conf: plain :80, `map $http_x_forwarded_proto` onto the `HTTPS`
  fastcgi param (Traefik terminates TLS).
- `Makefile` from the template: `make up` auto-starts _devproxy; `make cake CMD=`,
  `make composer CMD=`, `make db` (connects to dev-db, database `<project>_db_name>`).
- **DNS: `dev.<domain>` is an A record → 127.0.0.1 in Route53, NOT /etc/hosts.**
  The fleet zones use the reusable delegation set behind the dns1–4.csdurant.com
  vanity nameservers. After creating the record, remember negative-cache lag.
- **Fleet TLS cert:** add the hostname to `_devproxy/certs/hosts.txt`, run
  `make cert` in _devproxy (mkcert; Traefik hot-reloads). Commit hosts.txt.
- Create `<site>_db` + `<site>_db_test` on dev-db with grants for `my_app`.
- Local admin user: email + password from the site's 1Password item (`op item get`).

## 2. Secrets & config

- **No secrets in the repo, ever** — including bootstrap.php. Check git history;
  if live keys were ever committed, rotate them.
- `config/app_local.php` IS committed — dev-stack defaults only (dev-db,
  dev-mailcatcher, env() reads for S3/reCAPTCHA).
- `config/app_local.production.php` — committed `{{PLACEHOLDER}}` template; the
  deploy cp's it over app_local.php and seds the placeholders.
- Root `.env` (gitignored) holds dev values as `op://` 1Password references,
  resolved by `op run` in `make up`.
- GitHub secrets live in the **`production` environment** (not repo-level):
  DB_HOST/USERNAME/PASSWORD/DATABASE, SES_USERNAME/PASSWORD, DEPLOY_HOST/KEY/DIR,
  SECURITY_SALT, RECAPTCHA_SITE_KEY/SECRET_KEY, S3_KEY/SECRET/BUCKET/REGION/FOLDER.

## 3. Deploy

- `.github/workflows/main.yml` — push to `main` IS the production deploy (no gate):
  composer install → cp app_local.production.php → sed secrets → rsync (exclude
  vendor/, .env) → server composer install → `migrations migrate` → `cache clear_all`.
- `.github/workflows/ci.yml` — PHPUnit vs MySQL service (schema from migrations),
  phpcs, phpstan level 8. CI does NOT gate the deploy; run gates locally first.
- Migrations run on prod automatically — guard baseline schema with `hasTable()`;
  data migrations (slug renames etc.) ride along with the code that needs them.

## 4. Public site standards

### Phones — one format everywhere
`(XXX) XXX-XXXX` in all rendered text, placeholders, emails, JSON-LD, sitemap.
Every `input[type=tel]` gets live auto-format (vanilla, in the public layout):
```js
document.querySelectorAll('input[type="tel"]').forEach(function (input) {
    input.addEventListener('input', function () {
        var d = input.value.replace(/\D/g, '').slice(0, 10);
        var out = d;
        if (d.length > 6) { out = '(' + d.slice(0, 3) + ') ' + d.slice(3, 6) + '-' + d.slice(6); }
        else if (d.length > 3) { out = '(' + d.slice(0, 3) + ') ' + d.slice(3); }
        input.value = out;
    });
});
```

### reCAPTCHA v3 — truly invisible
No widget, no badge, no note. Server-side: the §15 `verifyRecaptcha()` helper
(Cake Http Client, score ≥ 0.5). Client-side per form:
```php
<?= $this->Form->hidden('g-recaptcha-response', ['id' => 'g-recaptcha-response']) ?>
<?php $this->Form->unlockField('g-recaptcha-response') ?>
```
```html
<script src="https://www.google.com/recaptcha/api.js?render=<?= h($site_key) ?>"></script>
<script>
(function () {
    var form = document.getElementById('the_form');
    form.addEventListener('submit', function (e) {
        if (form.dataset.verified === '1') return;
        e.preventDefault();
        grecaptcha.ready(function () {
            grecaptcha.execute('<?= h($site_key) ?>', {action: 'contact'}).then(function (token) {
                document.getElementById('g-recaptcha-response').value = token;
                form.dataset.verified = '1';
                form.submit();
            });
        });
    });
})();
</script>
```
CSS: `.grecaptcha-badge { visibility: hidden !important; }`
(ToS note: Google asks for inline attribution when the badge is hidden — owner's call.)

### Dropdowns — Choices.js
Every public-form `<select>` gets Choices.js from **`cdn.csdurant.com/lib/choices/`**
(never jsDelivr): `new Choices(el, {searchEnabled:false, shouldSort:false,
itemSelectText:'', allowHTML:false})`. Site-theme overrides must OUT-RANK choices.css
(it loads after site.css) — scope them, e.g. `.form-grid .choices__inner`.
Unlock `search_terms` in FormProtection if search is enabled.

### Assets
- Fonts self-hosted at `cdn.csdurant.com/templates/<site>/fonts/` (§14c playbook).
- Shared libs at `cdn.csdurant.com/lib/` (choices, trix, sortable, …). Add missing
  libs to `s3://computerservices/lib/<name>/` rather than referencing npm CDNs.
- Cache busting: `'Asset' => ['timestamp' => 'force']` in app.php; manual `?v=N`
  on anything outside the Html helper (sitemap.xsl's css link).

### SEO head (every public layout)
- `<title>`: `Page Title — Site Name` (CMS `seo_title` feeds page titles — keep it).
- `<meta name="description">` auto-derived: strip_tags CMS body → collapse
  whitespace → ≤158 chars; site-default fallback.
- `<link rel="canonical">` = `https://<apex>` + request target.
- Full Open Graph set (type/site_name/url/title/description/image/locale) +
  Twitter summary card. og:image = the site logo on the CDN.
- JSON-LD `LocalBusiness` (or fitting type): name/url/logo/telephone/address/
  openingHours/areaServed/foundingDate/sameAs(Facebook).
- GA4 gtag at the top of `<head>` on the public layout only.
- `www` 301s to apex; robots.txt + sitemap URLs use the apex;
  HostHeaderMiddleware + `App.fullBaseUrl` in production config.

### Sitemaps
- `/sitemap` human page + `/sitemap.xml` action, both driven by one
  `publicSections()` array in HomesController.
- sitemap.xml links `/sitemap.xsl` — the fleet's styled in-browser rendering
  (masthead, count line, URL table, footer). Style with the site's own fonts/colors.

### Chrome & layout conventions
- Call strip above the header: right-aligned on desktop, centered mobile.
  **When signed in it becomes the admin bar**: "Signed in as X — Go to Admin • Log Out"
  (replaces the marketing line; fleet standard).
- Footer top row: address block far LEFT, brand/association mark right.
  Bottom bar split: copyright left; right: `Site Map` • `Site Design`
  (→ csdurant.com) • round SVG Facebook mark.
- Facebook: round ƒ SVG element (currentColor), small in the footer (~26px).
  NEVER the old timeline iframe embed — use a branded follow card.
- Public forms redirect-or-`render('thanks')` after success.
- Paginators hidden when total pages ≤ 1 (§14f).
- No inline styles (§14b); no numbered-circle legacy images — if source assets are
  circle-cropped tiny PNGs, drop them and promote the columns to tiles.

## 5. Email standards

- Every outbound mail: dedicated `Mailer` class + `MailerAwareTrait` + `process()`
  in the Form (never inline `new Mailer`), HTML + text templates.
- HTML emails carry the brand: **site logo on a dark header band with the accent
  top-rule**, field-label layout, boxed table for structured data (orders),
  branded footer with address + phone. Inline styles only (email clients).
- **"Inline styles" means literally inline — a `<style>` block does NOT count.**
  Table-based markup with every rule on its element (adarentals templates are
  the donor). Two failure modes to kill: (1) a `<style>` block + classes —
  Gmail and others strip it; (2) the stock Cake email layout wrapping a
  full-HTML template in a SECOND document, which shoves the template's
  `<head><style>` inside `<body>` where clients discard it. The html email
  layout must emit `<?= $this->fetch('content') ?>` and nothing else.
  Verify via MailCatcher: the delivered source must contain exactly one
  `<html>`. caleraok still has both bugs — fix when next touched.
- Flatten visitor strings that feed Subject/Reply-To:
  `preg_replace('/[\r\n]+/', ' ', $v)` — header-injection guard.
- Recipients: users flagged `is_contact`.
- **New users are invite-only**: admin add-user has NO password field; the system
  emails a branded invitation with a set-password link (joneslawpc pattern).
  Soft-deleted users must not block re-inviting their email.

## 6. Admin standard (the chrome spec)

Light workspace + dark sidebar, recolored per site brand (accent replaces
caleraok's gold / blackburn's flame). Barlow faces unless the site's public
display face argues otherwise. `admin.css` starts with the §14e resets.

- **Sidebar**: brand/logo on top, grouped nav (`.grp` labels) with inline SVG
  stroke icons, `.on` state in the accent; sticky, own scroll,
  `align-self:flex-start`.
- **Top bar**: page title left. Right side — THE fleet standard:
  `View Site ↗` link, then the **avatar circle with the user's initials** +
  chevron opening a dropdown: bold name over email, `Account` (own edit page),
  `Security` (only when TOTP exists), divider, red `Log Out`. Vanilla JS toggle,
  outside-click + Escape close. User entity provides `full_name` and `initials`
  virtuals.
- **Auth layout**: chrome-free centered card on the dark radial backdrop; the
  site logo sits on a dark band with accent rule at the top of the white card
  (fleet logos are built for dark grounds).
- **Tables**: `.card > table.atable`, uppercase label headers, `.pill`/`.pill.off`
  status, thumbnails for image rows. **Row actions are ICON-ONLY** — pencil +
  trash via `element/admin/row_actions.php` (aria-labels + confirm), never word
  buttons. Hide self-delete on the Users list.
- **Forms**: `.aform` card, `.abtn` buttons, form-actions bar with Save + Cancel,
  current-image preview on upload edits.
- **RTE — never a bare textarea for HTML content.** Trix via
  `webroot/js/rte.js` (auto-upgrades `textarea.rte`) + `element/admin/rte_assets.php`
  (CDN `lib/trix/`), toolbar accent matched to the admin palette.
- **Drag-to-reorder** for any user-facing collection with an order:
  `sort_order` column (migration seeds from id), `.sortable-list[data-reorder-url]`
  rows with `.drag-handle`, Sortable.js from CDN `lib/sortable/` +
  `webroot/js/admin-reorder.js`, transactional `reorder()` action
  (two-pass renumber via 100000+pos offset), `FormProtection`
  `unlockedActions: ['reorder']`, CSRF via the layout's
  `<meta name="csrf-token">`. Public queries `orderByAsc('sort_order')`.
- **Dashboard**: `.dash-grid` stat cards (accent top border) with real counts and
  Manage → links.
- **Paginator**: `element/admin/paginator.php` (p-num pills, hidden ≤ 1 page).
- **TOTP 2FA** (§18): the target for every site's admin; adds the Security menu
  item, the `_totp_required` session gate, and the padlock quick-action on Users.
- **⚠️ Auth loginUrl gotcha**: if login must work at more than one URL (e.g.
  `/login` + the `/admin/users/login` fallback), you CANNOT list them in the
  Form authenticator's `loginUrl` — `DefaultUrlChecker` feeds the config
  verbatim to `Router::url()`, so an array of URL strings reads as ONE route
  array, never matches, and auth silently stops at BOTH URLs ("Login Failed"
  with correct credentials; MissingRouteException from CLI). Use adarentals'
  `App\Authentication\MultiUrlChecker` (extends DefaultUrlChecker, tries each
  URL) with `'urlChecker' => MultiUrlChecker::class`.

## 7. CMS conventions

- `contents` table keyed by `slug` = request path; AppController.beforeRender
  loads the row for the current URL. Renaming a URL = route + 301 redirect +
  **data migration updating the slug** (rides the deploy).
- `seo_title` stays: it is the `<title>`/OG title source. Meta description is
  derived from body — no separate field needed.
- Legacy CMS body HTML carries Bootstrap-era classes — keep a compatibility layer
  in site.css (.row/.col-sm-*, .grey-bg, .pull-right, …) so DB content keeps
  rendering; restyle those classes to the new system rather than editing prod data.

## 8. Uploads

Upload behavior (josegonzalez ^8) + fleet companions: `AppWriter` (temp-then-move,
ContentType, PDF thumb best-effort) + `ImageOrientation::autorotate` in every
transformer + `upload.file` TypeFactory mapping in bootstrap + schema
`setColumnType('<field>', 'upload.file')`. Rotate the `dir` uuid **only when a
new file is actually uploaded** (else existing S3 paths break).

## 9. Kill the cake phantoms

Every site carries cakephp/app skeleton leftovers until someone hunts them.
Sweep with `grep -rli 'cakephp\|cakefoundation' templates/ webroot/` plus the
list below (adarentals cleaned 2026-07-24 — reference commit):

- `webroot/img/cake*` (cake-logo.png, cake.icon.png, cake.logo.svg,
  cake.power.gif) — delete; rmdir `webroot/img` if that empties it.
- Stock `PagesController` + `PagesControllerTest` + `templates/Pages/` —
  delete when no route references Pages (fleet sites route everything
  explicitly; the skeleton's catch-all is long gone).
- Unused stock layouts `templates/layout/error.php` and `ajax.php` — delete
  ONLY after confirming the Error templates `setLayout('default')` (fleet
  error pages are branded and use the public layout) and nothing selects
  the ajax layout.
- CakePHP-Foundation docblocks on files we keep (email default templates,
  email layouts) — replace with a one-line purpose docblock.
- `README.md` — stock skeleton readme; rewrite: site name/purpose, `make up`
  dev quickstart, quality gates, push-to-main-deploys warning.
- `composer.json` `name: cakephp/app` / `description` / `homepage` — rename to
  `csdurant/<site>-com`, real description, site homepage. Then refresh the
  lock hash: `composer update --lock` (else every install warns).
- KEEP: `webroot/index.php` (framework entry), core-referenced elements
  (`auto_table_warning` lives in vendor — the error400 reference is fine),
  `templates/element/flash/*`.
- `ci.yml` skeleton triggers — the stock workflow only fires on `5.x`/`5.next`/
  `6.x` branches, so CI silently never runs. Point `push.branches` at `main`.
- `ci.yml` skeleton testsuite job — sqlite matrix (`pdo_sqlite`,
  `DATABASE_TEST_URL: sqlite://...`) can't run fleet migrations (enums,
  `ALTER ... MODIFY`). Replace with the caleraok job: mysql:8.4 service +
  `mysql://root:root@127.0.0.1:3306/<site>_test`, single PHP job matching prod.
- Legacy-site snapshots (`old/`): NEVER commit the legacy `tmp/` — adarentals
  shipped 246k cache/session files (603M, 98% of the repo), which broke CI
  outright (GitHub `hashFiles` cannot walk a workspace that size — the
  ramsey/composer-install cache key dies with "Fail to hash files under
  directory") and rode every rsync deploy to prod. Keep legacy source +
  webroot for reference; `rm -r old/tmp`.
- While in there: fresh-DB migrate must work — `users` (or any table the
  chain later ALTERs) needs a `hasTable()`-guarded baseline creation in the
  first migration. Dev/prod got `users` from _devproxy init.sql; CI and the
  `_test` database start empty and die on the first `ALTER TABLE users`.

## 10. Bring-a-site-to-standard checklist

Work top to bottom; each line is a commit-sized unit:

1. [ ] CakePHP 5.3.* + authentication ~4.2 (run `/cakephp` §13 upgrade)
2. [ ] _devproxy dev stack: compose/Makefile/site.conf from templates; DB on dev-db
3. [ ] Route53 `dev.<domain>` A 127.0.0.1; hostname into _devproxy certs + `make cert`
4. [ ] Secrets out of repo → committed dev app_local + production placeholder
       template + `.env` op:// refs; rotate anything that was committed
5. [ ] GH `production` environment secrets complete; fleet main.yml + ci.yml
6. [ ] phpstan level 8 / phpcs / phpunit green (§14a — before every push)
7. [ ] Public design pass: keep the brand, modernize execution; self-hosted fonts;
       cache busting; one signature element grounded in the business
8. [ ] Phone format + tel auto-format everywhere
9. [ ] reCAPTCHA v3 truly invisible on all public forms
10. [ ] Choices.js on public selects (CDN lib, scoped theme)
11. [ ] SEO head: title pattern, derived description, canonical, OG/Twitter, JSON-LD, GA4
12. [ ] Sitemap trio: /sitemap, /sitemap.xml, styled sitemap.xsl; robots.txt apex
13. [ ] Footer + call-strip conventions (incl. signed-in admin bar)
14. [ ] Branded HTML+text emails via Mailer classes; header-injection flattening
15. [ ] Admin: fleet admin.css recolor, sidebar shell, top-bar avatar dropdown +
        View Site, auth card login
16. [ ] Admin lists: icon row actions, pills, thumbnails, fleet paginator
17. [ ] RTE (Trix) on every HTML content textarea
18. [ ] Drag-to-reorder on every ordered collection (sort_order migration)
19. [ ] Dashboard stat cards
20. [ ] Invite-only user creation with branded invite email
21. [ ] TOTP 2FA (migrations + gate + Security menu + padlock quick-action)
22. [ ] Uploads: AppWriter + ImageOrientation + upload.file type + dir-rotation guard
23. [ ] Local admin credentials = the site's 1Password item
24. [ ] Cake phantoms swept (§9): cake imgs, PagesController, stock layouts,
        skeleton README + composer name, foundation docblocks, fresh-DB migrate

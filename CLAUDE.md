# CLAUDE.md — compasse-site

Public marketing site for Compasse (calm companion board for families living with cognitive decline). Single goal: convert visiting family caregivers to a $29/month membership (7-day free trial) through Stripe checkout. Pure static site: hand-written HTML with all CSS/JS inline. No framework, no package.json, no build step, no tests.

## Deploy & preview
- Public repo `Compasse-Shelly/compasse-site`, served by GitHub Pages (live at compasse-shelly.github.io/compasse-site; `CNAME` sets custom domain `compasse.care`). `git push origin main` IS the deploy.
- Everything here is public the moment it lands on `main`. Never commit secrets. The one key present — the Supabase anon key in index.html — is embedded deliberately (see Backend).
- Preview locally: open the file, or `python3 -m http.server` from the repo root.

## Current state: LIVE since 2026-09-01
- Pricing is public. `index.html` still carries the `LAUNCHED` switch (true) and hidden `[data-prelaunch]` blocks as a safety default; `fit.html` has no switch anymore. Do not reintroduce waitlist copy.
- `fit.html` is the paid-ads landing page (see compasse/docs/gtm/FIT-CHECK-FUNNEL-2026-09.md): pixel base, one deduplicated Lead (never on the not-a-fit exit), a real checkout button with the `?src=` ad tag, `?h=` headline swap.
- Old homepage variants, the draft film, and `guides/*.pdf` are noindex + blocked in robots.txt; the PDFs are stale pre-launch docs, do not link them.
- The truth sheet for facts (price, voice, platform, brand language) is `compasse/docs/HEAD.md`; the Compasse Head session owns it.

## Files
- `index.html` — the live page (bento-grid design; markup + CSS + JS in one file). Contains the waitlist form (`#wl`), the launch flip, checkout button wiring, and the Meta pixel.
- `claim.html` — post-Stripe-checkout success page; reads `?session_id`, verifies it via the `create-checkout` function, fires the one `StartTrial` event, sends buyers to the App Store (app id 6785591526).
- `manage.html` — membership self-service: Supabase email+password login → cancel/pause/end-care flows via the `manage-subscription` function, plus a Stripe Billing Portal deliberately scoped to payment-method update + invoice history (cancel/pause are intentionally NOT in the portal — don't \"fix\" that).
- `reset.html` — landing page for the iOS app's forgot-password flow.
- `terms.html`, `film/` (launch-film animation at `film/index.html`, plus `reviewer/` and `setup/` sub-pages), `guides/*.pdf` (setup guide, trial notice).
- `index-bento.html`, `index-hallmark.html`, `tokens.css`, `.hallmark/log.json` — design variants and Hallmark design-log history; not the live page. Don't edit these expecting site changes.

## Backend (Compasse Supabase project `cklagdabffzbikvtnnzo`; function/table source is NOT in this repo)
- Waitlist: `#wl` form POSTs to `/rest/v1/waitlist_signups` using the embedded anon (publishable) key. RLS is insert-only with no select policy — public reads return empty, so the key exposes nothing. Do not \"fix\" the embedded key, and never add a select policy. HTTP 409 = duplicate email, handled as \"already on the list\".
- Edge functions called from the site: `create-checkout` (Stripe Checkout session + claim verification), `capi-event` (server-side Meta CAPI copy), and `manage-subscription` (billing portal + cancel/pause, from manage.html).

## Hard rules
- Brand language: say \"cognitive decline\", NEVER \"memory loss\" — everywhere, no exceptions.
- Copy style (Aidan, 2026-08-04): no em dashes in customer-facing page copy — periods, commas, or colons instead.
- Meta pixel is privacy-disciplined by design: `autoConfig` false, intentionally NO PageView, no automatic form scraping. Only explicit `Lead` / `InitiateCheckout` / `StartTrial` events go through `metaEvent()`, which sends value/currency + `_fbp`/`_fbc` cookies only — never email/name/phone, and `event_source_url` is stripped of query strings. Do not add tracking or \"restore\" PageView.
- Honest content only (comment in index.html): real copy, real video, live clock — no fabricated metrics, no fake device chrome.
- Support/fallback contact used in error paths: hello@compasse.care.

## Related
- Compasse iOS app project: `~/Documents/Claude/compasse` (the product this site sells).
- Privacy policy is a separate repo/page: compasse-shelly.github.io/compasse-privacy.

---
name: childcare-leads
description: >-
  Build qualified lead lists of independent, for-profit childcare centers
  (daycares / preschools / early-learning centers), by state, using Aidan's exact
  qualification rules. Use this skill whenever the user asks to "find childcare
  centers", "build a daycare list", "qualify childcare / preschool /
  early-learning prospects", "run the next state", "run [city]", or "add [state]
  to the childcare list" — even if they don't say the word "skill". It encodes
  the inclusion rules (licensed capacity 100+, independent/local only, for-profit
  only, NO Montessori, 10 locations or fewer), where to pull licensed capacity
  (official state child-care licensing databases) and owners (Secretary of State
  business registry), and the output convention (ONE master workbook, ONE sheet
  per state, appended to on every run). Always apply this skill so the rules are
  applied identically on every run instead of being re-explained.
---

# Childcare lead scrubbing

Build a clean, consistently-qualified list of independent, for-profit childcare
centers. **Runs are scoped by state.** A city may still be run on its own, but a
city is never how the output is organized — see Output.

## Inclusion rules

### Rule 1 — Licensed capacity ≥ 100 children
Pull **licensed capacity** (the legal maximum on the facility's license, not current
enrollment) from the **official state child-care licensing database**. Under 100 is
out. See `references/licensing-portals.md`.

### Rule 2 — Independent and local only
Exclude national and regional chains — **KinderCare**, **Goddard**, **Primrose**,
**The Learning Experience**, **Childtime**, **La Petite Academy**, **Cadence
Education** (Cadence Academy), **Endeavor Schools**, and any similar multi-state
brand. If a location is operated by a chain, exclude it even under a local-sounding
name.

### Rule 3 — For-profit only
Exclude non-profits (501(c)(3)), church-operated, school-district and Head Start
programs. A `.org` domain is a hint, not proof — verify against the Secretary of
State registry.

### Rule 4 — No Montessori
If "Montessori" is in the name, or it markets itself as a Montessori program, it is
out. Different buyer profile.

### Rule 5 — 10 locations or fewer
Search the brand and cross-check licenses under the same operator. More than 10
locations is out.

### Owners
Find the owner's **first and last name** via the state license record (licensee
name), the **Secretary of State business registry**, or the center's own site.
Leave blank rather than guessing.

## Output

**Read `../../CONVENTION.md` — it governs the output and overrides any habit to
the contrary.** In short:

- **One master workbook:** `Scrubbing Docs/Childcare/Childcare Master.xlsx`
- **One sheet per state, named with the 2-letter code** (`OR`, `NC`, `TX`)
- **Never a sheet named after a city.** This is the rule that changed. Running
  Portland then Eugene produces **one `OR` sheet containing both**, not two sheets.
  If a run is scoped to a city, the rows go into that city's **state** sheet —
  creating it if absent, appending if it already exists.
- **No A-list / B-list.** Every center that fits the buy box goes in that state's
  sheet, one row each. Context goes in Notes.

Columns **A–H**, exactly:

| Col | Field | Contents |
|-----|-------|----------|
| A | Company Name | Official center name |
| B | Street | Street address only, e.g. `13050 SW Jenkins Rd` |
| C | City | City |
| D | State | 2-letter abbreviation |
| E | Licensed Capacity | From the official state DB |
| F | Owner First Name | Blank if not found |
| G | Owner Last Name | Blank if not found |
| H | Notes | Flags, units, entity name, operator relationships |

For multi-site operators, one row per physical location (each with its own address
and licensed capacity), noting the shared operator in H.

## Workflow for a run

1. **Confirm the geography.** Prefer a whole state. If the user names a city,
   run it — but note the state, because that determines the sheet.
2. **Pull every center** in scope from the official state licensing database with
   licensed capacity. Filter to **≥ 100**.
3. **Apply rules 2–5**, discarding as you go.
4. **Find owners** for survivors.
5. **Write** via the script — never by hand:

   ```bash
   cd ~/Claude/"Scrubbing Docs"
   python3 scrub_master.py add --vertical childcare --state OR --rows rows.json
   ```

   `rows.json` is a JSON list of objects keyed by the column headers above. The
   script creates or appends to the state sheet, drops duplicates, and snapshots
   the master first so the run can be reverted.
6. **Report** what landed: state, rows added, duplicates skipped, and the running
   total for that state.

Never edit the master by hand and never edit the user's source files.

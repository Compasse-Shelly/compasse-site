---
name: med-spa-leads
description: >-
  Build qualified lead lists of medical spas and aesthetic-injectable providers,
  one US state at a time, using Aidan's exact qualification rules. Use this skill
  whenever the user asks to "find med spas", "build a med spa list", "qualify
  aesthetic / injectable / Botox / filler providers", "run the next state", or
  "add [state] to the lead list", or mentions plastic surgery centers as injector
  leads — even if they don't say the word "skill". It encodes the inclusion rules
  (3+ potential injectors, 50+ Google reviews for independent med spas, ownership
  test for plastic surgery centers) and the output convention (ONE master
  workbook, ONE sheet per state, appended to on every run). Always use this skill
  so the rules are applied identically every time instead of being re-explained.
---

# Med spa lead scrubbing

Build a clean, consistently-qualified list of medical spas and aesthetic-injectable
providers, **one state at a time**.

## Inclusion rules

### Rule 1 — At least 3 potential injectors
The business must employ **3+ people who could plausibly administer aesthetic
injectables** (MD, DO, PA, NP, RN). Count from the team/staff page.

### Rule 2 — 50+ Google reviews (independent med spas)
A quality and established-business filter. Below 50 → leave it off, unless it is a
genuine edge case worth flagging. **Record the actual review count in Notes (M)**
regardless.

### Rule 3 — Ownership test for plastic surgery centers
Plastic surgery centers qualify only when independently owned. Exclude
**state-, hospital-, or health-system-owned** practices (e.g. Central Maine
Healthcare, Northern Light). Flag genuine edge cases in Notes rather than guessing.

## Output

**Read `../../CONVENTION.md` — it governs the output.** In short:

- **One master workbook:** `Scrubbing Docs/MedSpa/MedSpa Master.xlsx`
- **One sheet per state, named with the 2-letter code** (`TN`, `NY`, `ME`)
- **Never create a new tab for a state that already has one.** This is the rule
  that changed — the old instruction said "write to a new tab", which is why the
  current list was impossible to find. A second run against a state **appends**.
- **No A-list / B-list, and no fit tiers.** Every business that fits the buy box
  goes in that state's sheet, one row each. Record the raw review count and
  injector count in Notes; do not sort into good / great / excellent buckets.

Columns **A–M** only, exactly:

| Col | Field | Contents |
|-----|-------|----------|
| A | Business Name | Official name |
| B | Units | Total number of locations |
| C | Salutation | "Dr." only if owned by a doctor; otherwise blank |
| D | First name | Owner's first name |
| E | Last name | Owner's last name |
| F | Street address | Street only, e.g. `412 Woodburn Rd` |
| G | Suite / unit | e.g. `Suite 203` or `#6` |
| H | City | City/town |
| I | State | 2-letter abbreviation |
| J | Zip code | ZIP |
| K | Mailer sent | Leave blank |
| L | Date | Leave blank |
| M | Notes | Injector count, Google review count, plastic-surgery / flagged context |

Do **not** add other columns — no Source, Website, Phone, Ownership, or Business
Type columns. That detail goes in **Notes (M)** only.

## Workflow for a run

1. Confirm the state.
2. Pull candidate businesses across the state.
3. Apply rules 1–3, discarding as you go.
4. Find owner names for survivors.
5. **Write** via the script — never by hand:

   ```bash
   cd ~/Claude/"Scrubbing Docs"
   python3 scrub_master.py add --vertical medspa --state TN --rows rows.json
   ```

   The script creates or appends to the state sheet, drops duplicates on business
   name + city + state, and snapshots the master first so the run can be reverted.
6. Report: state, rows added, duplicates skipped, running total for that state.

Never edit the master by hand and never edit the user's source files.

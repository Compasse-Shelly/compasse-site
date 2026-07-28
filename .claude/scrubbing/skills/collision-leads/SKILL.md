---
name: collision-leads
description: >-
  Build qualified lead lists of collision repair / auto body shops, one US state
  at a time. Use this skill whenever the user asks to "find collision shops",
  "build a collision list", "run the collision scrub", "qualify body shops / auto
  body / collision repair prospects", "run the next state", or "add [state] to the
  collision list" — even if they don't say the word "skill". It fixes the output
  convention: ONE master workbook, ONE sheet per state named with the 2-letter
  code, appended to on every run, so runs stack into one findable list instead of
  creating a new sheet each time.
---

# Collision lead scrubbing

Build a clean, consistently-qualified list of collision repair / auto body shops,
**one state at a time**.

---

## THE OUTPUT RULES — these are the point of this skill

These four rules are not negotiable and override any other habit. The previous
collision scrubs had no skill at all, which is why they created a new sheet
everywhere they went and the current list became impossible to find.

1. **One master workbook.** `Collision Master.xlsx`. Never a second file, never a
   dated copy, never "v2". If a master already exists, use it.
2. **One sheet per state, named with the 2-letter code** — `NY`, `TX`, `NC`.
   Nothing else. Not a city. Not `NY (2)`. Not `NY Run 7-28`. Not `Sheet1`.
3. **If the state's sheet already exists, APPEND to it.** Running Buffalo, then
   Albany, then Rochester produces **one `NY` sheet containing all three** — not
   three sheets. A run scoped to a city still writes to that city's *state* sheet.
4. **No A-list / B-list / tiers.** Every shop that fits the buy box goes in that
   state's sheet, one row each. Context that would have justified a tier goes in
   the Notes column.

Before adding rows, **check whether a sheet for that state already exists** and
append to it. Creating a second sheet for a state that already has one is the
single failure this skill exists to prevent.

### Columns — A–M, exactly

| Col | Field | Contents |
|-----|-------|----------|
| A | Business Name | Official name |
| B | Units | Total number of locations |
| C | Salutation | "Dr." only if applicable; otherwise blank |
| D | First name | Owner's first name |
| E | Last name | Owner's last name |
| F | Street address | Street only, e.g. `412 Woodburn Rd` |
| G | Suite / unit | e.g. `Suite 203` or `#6` |
| H | City | City/town |
| I | State | 2-letter abbreviation |
| J | Zip code | ZIP |
| K | Mailer sent | Leave blank |
| L | Date | Leave blank |
| M | Notes | Bay count, DRP relationships, review count, flags, operator context |

Do not add other columns. Extra detail goes in **Notes (M)** only. This matches
the med spa layout so mailers are produced the same way.

### Duplicates

Two rows are the same shop when **business name + city + state** match after
ignoring case, punctuation, and legal suffixes — "Gerber Collision Inc." and
"gerber collision" are one shop. Do not add a shop that is already in the sheet.

### Before overwriting a master, back it up

Copy the existing master to `_versions/Collision Master — YYYY-MM-DD HHMMSS.xlsx`
before writing, so a bad run can be reverted.

---

## Buy box — TO BE FILLED IN

> **This section is a placeholder.** These are client qualification criteria and
> have to come from Aidan — they must not be inferred from what similar clients
> look for. Until filled in, this skill produces a correctly-structured workbook
> from a set of businesses that may be wrong.
>
> Needed, at minimum:
>
> - **Size floor** — bays, DRP relationships, annual revenue, or technician count
> - **Independence test** — which MSOs/consolidators are excluded (Caliber,
>   Gerber, Crash Champions, Classic Collision, Joe Hudson), and whether
>   franchisees count
> - **Unit ceiling** — maximum number of locations
> - **Quality filter** — the collision equivalent of the med spa 50-review rule
> - **Exclusions** — dealership-owned body shops, glass-only, fleet-only,
>   mechanical-only
> - **Owner sourcing** — Secretary of State registry, license records, or site

Apply the rules identically on every run. Flag genuine edge cases in Notes rather
than guessing.

---

## Workflow for a run

1. **Confirm the state.** If the user names a city, run it — but note the state,
   because that determines the sheet.
2. **Pull candidate shops** across the geography.
3. **Apply the buy box**, discarding as you go.
4. **Find owner names** for survivors. Leave blank rather than guessing.
5. **Open the existing master**, find the state's sheet, and **append**. Create the
   sheet only if that state has none. Back up the master first.
6. **Report**: state, rows added, duplicates skipped, running total for the state,
   and the full list of sheet names now in the workbook.

## Optional: the deterministic writer

If `scrub_master.py` is available alongside the master, prefer it — it enforces
every rule above in code rather than relying on them being remembered:

```bash
python3 scrub_master.py add    --vertical collision --state NY --rows rows.json
python3 scrub_master.py import --vertical collision --file "some scrub.xlsx"
python3 scrub_master.py status --vertical collision
python3 scrub_master.py revert --vertical collision
```

`import` folds a workbook that already scattered sheets into the master, routing
every row by its State column and ignoring the source sheet names.

Never edit the user's source files.

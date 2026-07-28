---
name: collision-leads
description: >-
  Build qualified lead lists of collision repair / auto body shops, one US state
  at a time, using the client's buy box. Use this skill whenever the user asks to
  "find collision shops", "build a collision list", "run the collision scrub",
  "qualify body shops / auto body / collision repair prospects", "run the next
  state", or "add [state] to the collision list" — even if they don't say the word
  "skill". It encodes the output convention (ONE master workbook, ONE sheet per
  state, appended to on every run) so runs stack into one findable list instead of
  spraying a new sheet each time.
---

# Collision lead scrubbing

Build a clean, consistently-qualified list of collision repair / auto body shops,
**one state at a time**.

## Buy box — TO BE FILLED IN

> **This section is a placeholder and must be completed before the skill is
> trusted.** These are client qualification criteria; they have to come from
> Aidan, not be inferred from what similar clients look for. Until they are
> filled in, this skill will produce a correctly-shaped workbook containing the
> wrong set of businesses.
>
> Fill in, at minimum:
>
> - **Size floor** — bays, DRP relationships, annual revenue, technician count, or
>   whatever the actual threshold is
> - **Independence test** — which MSOs and consolidators are excluded (Caliber,
>   Gerber, Crash Champions, Classic Collision, Joe Hudson, etc.), and whether
>   franchisees count
> - **Unit ceiling** — maximum number of locations
> - **Quality / establishment filter** — the collision equivalent of the med spa
>   50-review rule, if there is one
> - **Any exclusions** — dealership-owned body shops, glass-only, fleet-only,
>   mechanical-only
> - **Owner sourcing** — Secretary of State registry, license records, or site

Once filled in, apply the rules exactly and identically on every run. Flag genuine
edge cases in Notes rather than guessing.

## Output

**Read `../../CONVENTION.md` — it governs the output.** In short:

- **One master workbook:** `Scrubbing Docs/Collision/Collision Master.xlsx`
- **One sheet per state, named with the 2-letter code** — running New York means
  **one sheet named `NY`**, containing every qualifying shop in the state.
- **Never a sheet per city, per run, or per date.** Buffalo, Albany and Rochester
  all land in `NY`. This is the behavior that was broken.
- **No A-list / B-list.** Every shop that fits the buy box goes in that state's
  sheet, one row each. Context goes in Notes.

Columns **A–M**, matching the med spa layout so mailers can be produced the same way:

| Col | Field | Contents |
|-----|-------|----------|
| A | Business Name | Official name |
| B | Units | Total number of locations |
| C | Salutation | "Dr." only if applicable; otherwise blank |
| D | First name | Owner's first name |
| E | Last name | Owner's last name |
| F | Street address | Street only |
| G | Suite / unit | Suite or unit number |
| H | City | City/town |
| I | State | 2-letter abbreviation |
| J | Zip code | ZIP |
| K | Mailer sent | Leave blank |
| L | Date | Leave blank |
| M | Notes | Bay count, DRP relationships, review count, flags, operator context |

## Workflow for a run

1. Confirm the state.
2. Pull candidate shops across the state.
3. Apply the buy box, discarding as you go.
4. Find owner names for survivors.
5. **Write** via the script — never by hand:

   ```bash
   cd ~/Claude/"Scrubbing Docs"
   python3 scrub_master.py add --vertical collision --state NY --rows rows.json
   ```

6. Report: state, rows added, duplicates skipped, running total for that state.

### First run against an existing master

If the master already has city-named sheets from earlier runs, fold them into
proper state sheets once, before adding anything new:

```bash
python3 scrub_master.py status      --vertical collision
python3 scrub_master.py consolidate --vertical collision
```

Never edit the master by hand and never edit the user's source files.

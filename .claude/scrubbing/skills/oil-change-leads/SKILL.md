---
name: oil-change-leads
description: >-
  Build qualified lead lists of quick lube / oil change businesses (small-box oil
  change, SBOC), one US state at a time, using the client's buy box. Use this
  skill whenever the user asks to "find oil change shops", "build an oil list",
  "run the oil scrub", "qualify quick lube / SBOC prospects", "run the next
  state", or "add [state] to the oil list" — even if they don't say the word
  "skill". It encodes the output convention (ONE master workbook, ONE sheet per
  state, appended to on every run) so runs stack into one findable list instead of
  spraying a new sheet each time.
---

# Oil change / quick lube lead scrubbing

Build a clean, consistently-qualified list of quick lube and small-box oil change
(SBOC) businesses, **one state at a time**.

## Buy box — TO BE FILLED IN

> **This section is a placeholder and must be completed before the skill is
> trusted.** These are client qualification criteria; they have to come from
> Aidan, not be inferred. Until they are filled in, this skill will produce a
> correctly-shaped workbook containing the wrong set of businesses.
>
> Fill in, at minimum:
>
> - **Format** — small-box oil change only, or does quick lube inside a car wash,
>   tire, or general-repair operation count?
> - **Bay count floor** and any car-count / revenue threshold
> - **Independence test** — which brands and franchise systems are excluded
>   (Jiffy Lube, Valvoline, Take 5, Grease Monkey, Havoline xpress), and whether
>   franchisees are in or out
> - **Unit ceiling** — maximum number of locations
> - **Real estate** — owned vs. leased, and whether that decides inclusion
> - **Exclusions** — dealership-owned, fleet-only, mobile-only
> - **Owner sourcing** — Secretary of State registry or site
>
> Note: `/Xpand/Accelerated Brands/Team Resources/Oil Change Brokerage Research/`
> already holds purchased datasets and a "Not a Fit" database. Those are likely
> the fastest source for both the buy box and a starting universe — worth reading
> before writing this section from scratch.

Once filled in, apply the rules exactly and identically on every run. Flag genuine
edge cases in Notes rather than guessing.

## Output

**Read `../../CONVENTION.md` — it governs the output.** In short:

- **One master workbook:** `Scrubbing Docs/Oil/Oil Change Master.xlsx`
- **One sheet per state, named with the 2-letter code** (`TX`, `NC`, `AL`)
- **Never a sheet per city, per run, or per date.** Every qualifying shop in a
  state lands in that state's single sheet.
- **No A-list / B-list.** Every business that fits the buy box goes in that
  state's sheet, one row each. Context goes in Notes.

Columns **A–M**, matching the other verticals:

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
| M | Notes | Bay count, brand/franchise status, real estate, flags |

## Workflow for a run

1. Confirm the state.
2. Pull candidate businesses across the state.
3. Apply the buy box, discarding as you go.
4. Find owner names for survivors.
5. **Write** via the script — never by hand:

   ```bash
   cd ~/Claude/"Scrubbing Docs"
   python3 scrub_master.py add --vertical oil --state TX --rows rows.json
   ```

6. Report: state, rows added, duplicates skipped, running total for that state.

Never edit the master by hand and never edit the user's source files.

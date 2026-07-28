# Scrubbing Docs — the shared output convention

One convention for all four scrubbers: **Childcare, MedSpa, Collision, Oil.**
Every skill points here instead of restating it, so the rule can only be changed
in one place.

## Folder layout

`Scrubbing Docs` lives inside the **Claude folder in Finder**. Default:
`~/Claude/Scrubbing Docs`. If it sits elsewhere, export the real path once:

```bash
echo 'export SCRUBBING_ROOT="$HOME/Claude/Scrubbing Docs"' >> ~/.zshrc
```

```
Claude/
└── Scrubbing Docs/
    ├── scrub_master.py
    ├── Childcare/   Childcare Master.xlsx      + _versions/
    ├── MedSpa/      MedSpa Master.xlsx         + _versions/
    ├── Collision/   Collision Master.xlsx      + _versions/
    └── Oil/         Oil Change Master.xlsx     + _versions/
```

## The four rules

1. **One master workbook per vertical.** Never a second file, never a dated
   copy, never "v2". The master is the only deliverable.
2. **One sheet per state, named with the 2-letter code** — `NY`, `TX`, `NC`.
   Never a city name. Never `NY (2)`. Never a run date.
3. **A state that already has a sheet gets appended to.** Running Buffalo, then
   Albany, then Rochester produces **one `NY` sheet with all three**, not three
   sheets. If a run is scoped to a city, the sheet is still the state that city
   is in.
4. **No A-list / B-list.** Every business that fits the buy box goes in that
   state's sheet, one row each. No tiering, no ranking, no separate sheets for
   "strong" versus "maybe". Context that used to justify a tier goes in **Notes**.

## Never hand-edit the master

All writes go through `scrub_master.py`. It is the thing that makes the rules
above true — a model can forget a rule in a prose skill; the script cannot.

```bash
cd ~/Claude/"Scrubbing Docs"

# add a run's qualified rows (JSON list of objects keyed by column header)
python3 scrub_master.py add --vertical collision --state NY --rows rows.json

# --state also accepts "New York" or "Buffalo, NY" — a city resolves to its state
```

It refuses a city as a sheet name, appends when the state sheet exists, drops
duplicates on business name + city + state (so "Gerber Collision Inc." will not
land twice as "gerber collision"), and keeps sheets in alphabetical order.

## Revert

Before every write the master is copied into `_versions/`. Last 20 kept.

```bash
python3 scrub_master.py versions --vertical collision   # list restore points
python3 scrub_master.py revert   --vertical collision   # undo the last run
python3 scrub_master.py revert   --vertical collision --version "2026-07-28 1455"
```

Reverting is itself snapshotted first, so an accidental revert is also undoable.

## Cleaning up a master that already sprayed sheets

The Collision master currently has a sheet per city. One command folds them into
proper state sheets, merging duplicates:

```bash
python3 scrub_master.py status      --vertical collision   # see the damage
python3 scrub_master.py consolidate --vertical collision   # fix it
python3 scrub_master.py status      --vertical collision   # confirm
```

Run `consolidate` once per vertical. It snapshots first, so if the merge looks
wrong, `revert` puts it back exactly as it was.

## Installing the skills

The four `SKILL.md` files in `skills/` replace the current scrubbers. Skills are
stored on your Claude account, not in any one session — editing them inside a
cloud session does nothing lasting. Install them from **Settings → Capabilities →
Skills**: update `childcare-leads` and `med-spa-leads`, and add
`collision-leads` and `oil-change-leads` as new skills.

## Still needed

`collision-leads` and `oil-change-leads` carry the correct output machinery but
their **buy box sections are placeholders**. Those are client qualification
criteria — they have to come from you, not be inferred. Until they are filled in,
those two skills will produce correctly-shaped workbooks from the wrong set of
businesses.

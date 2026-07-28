#!/usr/bin/env bash
# Creates the Scrubbing Docs folder tree inside your Claude folder and installs
# the writer script. Safe to re-run — it never overwrites an existing master.
#
#   bash setup.sh                       # -> ~/Claude/Scrubbing Docs
#   bash setup.sh "/path/to/Claude"     # if your Claude folder is elsewhere
set -euo pipefail

CLAUDE_FOLDER="${1:-$HOME/Claude}"
ROOT="$CLAUDE_FOLDER/Scrubbing Docs"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$CLAUDE_FOLDER" ]; then
  echo "No Claude folder at: $CLAUDE_FOLDER"
  echo "Pass the real path, e.g.  bash setup.sh \"\$HOME/Documents/Claude\""
  exit 1
fi

for v in Childcare MedSpa Collision Oil; do
  mkdir -p "$ROOT/$v/_versions"
done

cp "$SRC/scrub_master.py" "$ROOT/scrub_master.py"
cp "$SRC/CONVENTION.md"   "$ROOT/CONVENTION.md"
chmod +x "$ROOT/scrub_master.py"

python3 -c "import openpyxl" 2>/dev/null || {
  echo "Installing openpyxl…"; python3 -m pip install --quiet openpyxl; }

echo "Ready:  $ROOT"
printf '  %s\n' Childcare MedSpa Collision Oil

if ! grep -q "SCRUBBING_ROOT" "$HOME/.zshrc" 2>/dev/null; then
  printf '\nexport SCRUBBING_ROOT="%s"\n' "$ROOT" >> "$HOME/.zshrc"
  echo "Added SCRUBBING_ROOT to ~/.zshrc (open a new terminal to pick it up)."
fi

cat <<EOF

Next:
  cd "$ROOT"
  python3 scrub_master.py status --vertical collision
EOF

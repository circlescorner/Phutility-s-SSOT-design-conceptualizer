#!/usr/bin/env bash
set -euo pipefail
PATCH_DIR="${PATCH_DIR:-patches}"
MASTER_FILE="${MASTER_FILE:-MASTER.md}"
HISTORY_FILE="${HISTORY_FILE:-HISTORY.md}"

title="${1:-}"
scope="${2:-doctrine}"
[[ -z "$title" ]] && { echo "missing title"; exit 1; }

slug="$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"

mkdir -p "$PATCH_DIR"
max=0
shopt -s nullglob
for f in "$PATCH_DIR"/[0-9][0-9][0-9]-*.md; do
  n="$(basename "$f")"; n="${n%%-*}"
  [[ "$n" =~ ^[0-9]{3}$ ]] && ((10#$n>max)) && max=$((10#$n))
done
shopt -u nullglob
num=$(printf "%03d" $((max+1)))

patch_path="$PATCH_DIR/${num}-${slug}.md"
date="$(date +%Y-%m-%d)"

cat > "$patch_path" <<EOF
# Patch ${num} — ${title}

Date: ${date}
Scope: ${scope}

## Context
(What triggered this change?)

## Change
(What is changing?)

## Affected Sections
- ${MASTER_FILE} §...

## Rationale
(Why this is better.)

## Deprecates / Replaces
(What is now obsolete?)

## Rollback Plan
(How to revert.)

EOF

# HISTORY.md append
{
  echo "## ${date} — Patch ${num}: ${title}"
  echo ""
  echo "- Patch file: \`${patch_path}\`"
  echo "- Scope: ${scope}"
  echo ""
} >> "$HISTORY_FILE"

# MASTER.md Patch Index
if ! grep -qE '^## Patch Index' "$MASTER_FILE"; then
  echo "" >> "$MASTER_FILE"
  echo "## Patch Index" >> "$MASTER_FILE"
  echo "" >> "$MASTER_FILE"
fi
echo "- Patch ${num}: ${title} (\`${patch_path}\`)" >> "$MASTER_FILE"

echo "$patch_path" > .patch_created

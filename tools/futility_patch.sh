#!/usr/bin/env bash
set -euo pipefail

PATCH_DIR="${PATCH_DIR:-patches}"
MASTER_FILE="${MASTER_FILE:-MASTER.md}"
HISTORY_FILE="${HISTORY_FILE:-HISTORY.md}"

title="${1:-}"
scope="${2:-doctrine}"

if [[ -z "$title" ]]; then
  echo "Missing title"
  exit 2
fi

# slugify
slug="$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"

mkdir -p "$PATCH_DIR"

# Safe next number (works when directory is empty)
max=0
shopt -s nullglob
for f in "$PATCH_DIR"/[0-9][0-9][0-9]-*.md; do
  base="${f##*/}"
  num="${base%%-*}"
  if [[ "$num" =~ ^[0-9]{3}$ ]]; then
    ((10#$num > max)) && max=$((10#$num))
  fi
done
shopt -u nullglob

n=$(printf "%03d" $((max + 1)))
patch_path="$PATCH_DIR/${n}-${slug}.md"
date="$(date +%Y-%m-%d)"

cat > "$patch_path" <<EOF
# Patch ${n} — ${title}

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

# HISTORY entry
{
  echo "## ${date} — Patch ${n}: ${title}"
  echo ""
  echo "- Patch file: \`${patch_path}\`"
  echo "- Scope: ${scope}"
  echo ""
} >> "$HISTORY_FILE"

# Ensure Patch Index exists in MASTER then append
if ! grep -qE '^## Patch Index' "$MASTER_FILE"; then
  echo "" >> "$MASTER_FILE"
  echo "## Patch Index" >> "$MASTER_FILE"
  echo "" >> "$MASTER_FILE"
fi
echo "- Patch ${n}: ${title} (\`${patch_path}\`)" >> "$MASTER_FILE"

echo "$patch_path" > .patch_created

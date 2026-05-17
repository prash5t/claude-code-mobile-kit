#!/usr/bin/env bash
# Hook: sync-release-history.sh
# Fires on:  PostToolUse where edited file is pubspec.yaml AND the version: line changed
# Purpose:   append a row to docs/release-history.md
# Idempotent: yes (dedupes by version string)

set -euo pipefail

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
HISTORY="$PROJECT_ROOT/docs/release-history.md"
PUBSPEC="$PROJECT_ROOT/pubspec.yaml"

if [[ ! -f "$PUBSPEC" ]]; then
  exit 0
fi

# Extract current version
VERSION=$(grep -m1 '^version:' "$PUBSPEC" | awk '{print $2}' || true)
if [[ -z "$VERSION" ]]; then
  exit 0
fi

# Init file if it doesn't exist
if [[ ! -f "$HISTORY" ]]; then
  cat > "$HISTORY" <<'EOF'
# Release history

| Version | Date | Track | Notes | Commit |
|---|---|---|---|---|
EOF
fi

# Idempotency: if this version is already at the top, do nothing
if head -10 "$HISTORY" | grep -q "| $VERSION |"; then
  exit 0
fi

# Append a row above any existing rows (newest at top is convention)
TODAY=$(date '+%Y-%m-%d')
SHA=$(cd "$PROJECT_ROOT" && git rev-parse --short HEAD 2>/dev/null || echo "uncommitted")

# Insert after the table header
NEW_ROW="| $VERSION | $TODAY | (pending) | (auto-generated; fill notes via deployer) | \`$SHA\` |"
awk -v new_row="$NEW_ROW" '
  /^\| --- \| --- \|/ { print; print new_row; next }
  { print }
' "$HISTORY" > "$HISTORY.tmp" && mv "$HISTORY.tmp" "$HISTORY"

exit 0

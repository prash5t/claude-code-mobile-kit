#!/usr/bin/env bash
# Hook: sync-analytics.sh
# Fires on:  PostToolUse where edited file is *.dart and contains logEvent/track/setUserProperty
# Purpose:   re-sync docs/analytics-events.md from current code state
# Idempotent: yes (writes a fresh catalog every time)

set -euo pipefail

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CATALOG="$PROJECT_ROOT/docs/analytics-events.md"
LIB="$PROJECT_ROOT/lib"

# Bail quietly if the project isn't set up for analytics yet
if [[ ! -d "$LIB" ]]; then
  exit 0
fi

# Pull every analytics call's event name from .dart files
# Matches: logEvent("foo"), logEvent('foo'), track("foo"), Mixpanel().track("foo"), etc.
mapfile -t events < <(
  grep -rhoE '(logEvent|track|setUserProperty|recordEvent)\s*\(\s*["'"'"'][^"'"'"']+["'"'"']' "$LIB" 2>/dev/null \
    | grep -oE '["'"'"'][^"'"'"']+["'"'"']' \
    | tr -d "\"'" \
    | sort -u
)

# If nothing found, write a minimal stub rather than an empty file
if [[ ${#events[@]} -eq 0 ]]; then
  cat > "$CATALOG" <<EOF
# Analytics events

_Auto-synced by .claude/hooks/sync-analytics.sh on $(date '+%Y-%m-%d %H:%M %Z')._

No analytics events found in \`lib/\`. Add \`logEvent(...)\`, \`track(...)\`, or \`setUserProperty(...)\` calls and this catalog will populate on next save.
EOF
  exit 0
fi

# Write fresh catalog
{
  echo "# Analytics events"
  echo ""
  echo "_Auto-synced by .claude/hooks/sync-analytics.sh on $(date '+%Y-%m-%d %H:%M %Z')._"
  echo "_Do not edit by hand. Add \`logEvent(...)\` calls in code; the catalog refreshes on every save._"
  echo ""
  echo "## Events (${#events[@]})"
  echo ""
  for e in "${events[@]}"; do
    echo "- \`$e\`"
  done
} > "$CATALOG"

# Silent success — hooks should only chatter on actionable findings
exit 0

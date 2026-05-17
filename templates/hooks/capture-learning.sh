#!/usr/bin/env bash
# Hook: capture-learning.sh
# Fires on:  PostToolUse after significant deployer/compliance-checker bash commands
#            (the deployer/compliance subagent triggers this script explicitly)
# Purpose:   capture a structured learning entry without requiring the agent to remember
# Idempotent: idempotency is on the caller — they must pass a unique fingerprint

set -euo pipefail

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LEARNINGS="$PROJECT_ROOT/docs/learnings.md"

# Required env vars from caller:
#   LEARNING_SOURCE  — which agent / command produced this (e.g. "deployer", "compliance-checker")
#   LEARNING_TITLE   — short title (e.g. "Released v1.3.0", "AdMob policy notice")
#   LEARNING_BODY    — Markdown body of the entry
#   LEARNING_FINGERPRINT — unique id to dedupe (e.g. "RELEASE-v1.3.0+46")

: "${LEARNING_SOURCE:?LEARNING_SOURCE required}"
: "${LEARNING_TITLE:?LEARNING_TITLE required}"
: "${LEARNING_BODY:?LEARNING_BODY required}"
: "${LEARNING_FINGERPRINT:?LEARNING_FINGERPRINT required}"

# Init learnings file if missing
if [[ ! -f "$LEARNINGS" ]]; then
  cat > "$LEARNINGS" <<'EOF'
# Learnings

> Cross-session memory. Newest entries at the top. Subagents read this before acting.

---

EOF
fi

# Idempotency check
if grep -qF "<!-- fingerprint: $LEARNING_FINGERPRINT -->" "$LEARNINGS"; then
  exit 0
fi

TODAY=$(date '+%Y-%m-%d')

# Build entry
TMP=$(mktemp)
{
  echo ""
  echo "## $TODAY — $LEARNING_SOURCE: $LEARNING_TITLE"
  echo ""
  echo "<!-- fingerprint: $LEARNING_FINGERPRINT -->"
  echo ""
  echo "$LEARNING_BODY"
  echo ""
  cat "$LEARNINGS"
} > "$TMP"

# Position new entry right after the intro/separator
python3 - "$LEARNINGS" "$TMP" <<'PY'
import sys, re, pathlib
old = pathlib.Path(sys.argv[1])
candidate = pathlib.Path(sys.argv[2])
new_content = candidate.read_text()

# Strip the duplicate header (since we prepended one to the candidate)
# Find the second occurrence of "# Learnings" and keep only from there onward for the body
parts = new_content.split("# Learnings", 2)
if len(parts) >= 3:
    new_content = parts[0] + "# Learnings" + parts[2]

old.write_text(new_content)
PY

rm -f "$TMP"
exit 0

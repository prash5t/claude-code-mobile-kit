#!/usr/bin/env bash
# Hook: flag-policy-impact.sh
# Fires on:  PostToolUse where edited file is AndroidManifest.xml OR pubspec.yaml (new SDK lines)
# Purpose:   write a "policy review needed" marker to docs/learnings.md
#            so the compliance-checker subagent picks it up on next invocation
# Idempotent: yes (uses a stable date+file fingerprint to dedupe)

set -euo pipefail

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LEARNINGS="$PROJECT_ROOT/docs/learnings.md"
EDITED_FILE="${CLAUDE_TOOL_FILE_PATH:-unknown}"

# Init learnings file if missing
if [[ ! -f "$LEARNINGS" ]]; then
  cat > "$LEARNINGS" <<'EOF'
# Learnings

> Cross-session memory. Newest entries at the top. Subagents read this before acting.

---

EOF
fi

TODAY=$(date '+%Y-%m-%d')
FINGERPRINT="POLICY-IMPACT-$TODAY-$(basename "$EDITED_FILE")"

# Idempotency: if today's fingerprint for this file is already there, skip
if grep -qF "$FINGERPRINT" "$LEARNINGS"; then
  exit 0
fi

# Build a marker entry
{
  echo ""
  echo "## $TODAY — Policy review needed (auto-flagged)"
  echo ""
  echo "<!-- fingerprint: $FINGERPRINT -->"
  echo ""
  echo "Edited \`$EDITED_FILE\` may have Play Store policy implications:"
  case "$(basename "$EDITED_FILE")" in
    AndroidManifest.xml)
      echo "- Manifest changed. Check permissions list, exported activities/services, and intent filters."
      ;;
    pubspec.yaml)
      echo "- pubspec.yaml changed. If a new SDK was added, verify it's not on Play's restricted list and that its data-handling matches your privacy policy."
      ;;
    *)
      echo "- File changed. Run /compliance-check to verify nothing was inadvertently introduced."
      ;;
  esac
  echo ""
  echo "**Next step:** run \`/compliance-check\` to verify."
  echo ""
} >> "$LEARNINGS"

# Move the new entry to the top (newest-first convention)
# Naive but correct: read file, extract latest entry, prepend
python3 - "$LEARNINGS" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
text = p.read_text()
# Split on H2 headers, find the most recent one, move it after the intro
parts = re.split(r'(?m)^(?=## )', text)
if len(parts) >= 2:
    header_block = parts[0]
    entries = parts[1:]
    # Find the one we just appended (last in list)
    latest = entries.pop()
    new_order = [header_block, latest] + entries
    p.write_text("".join(new_order))
PY

exit 0

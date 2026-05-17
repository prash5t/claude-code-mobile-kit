#!/usr/bin/env bash
# bootstrap.sh — copy kit templates into a target Flutter project.
#
# Usage:
#   ./scripts/bootstrap.sh /path/to/your-flutter-app
#
# What it does:
#   1. Verifies the target is a Flutter project
#   2. Copies CLAUDE.md template (only if not present — won't clobber yours)
#   3. Copies subagent templates to .claude/agents/
#   4. Copies hook scripts to .claude/hooks/ (made executable)
#   5. Copies slash-command templates to .claude/slash-commands/
#   6. Copies Python helpers to .claude/scripts/
#   7. Merges .claude/settings.json (preserves your existing hooks if any)
#   8. Initializes empty docs/ scaffolding (spec/, policy/, learnings.md, etc.)
#   9. Prints concrete next steps
#
# Idempotent: re-running is safe. Existing customized files are not overwritten
# unless --force is passed.

set -euo pipefail

FORCE=0
TARGET=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    -h|--help)
      sed -n '2,/^set -euo/p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) TARGET="$1"; shift ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <path-to-flutter-project> [--force]"
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "✗ Not a directory: $TARGET"
  exit 1
fi

KIT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
TARGET="$( cd "$TARGET" && pwd )"

# --- Verify target is a Flutter project ---
if [[ ! -f "$TARGET/pubspec.yaml" ]]; then
  echo "✗ $TARGET has no pubspec.yaml — doesn't look like a Flutter project."
  echo "  Run \`flutter create <name>\` first, then point bootstrap.sh at the result."
  exit 1
fi
if ! grep -q "^flutter:" "$TARGET/pubspec.yaml"; then
  echo "! pubspec.yaml has no flutter: section — proceeding anyway, but verify this is a Flutter app."
fi

echo "→ Bootstrapping kit into: $TARGET"
echo ""

# --- Helpers ---
copy_safe() {
  local src="$1" dst="$2" label="$3"
  if [[ -e "$dst" && $FORCE -eq 0 ]]; then
    printf "  \033[33m·\033[0m  %s already exists — skipped (use --force to overwrite)\n" "$label"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  printf "  \033[32m✓\033[0m  %s\n" "$label"
}

copy_tree_safe() {
  local src_dir="$1" dst_dir="$2" label="$3"
  mkdir -p "$dst_dir"
  local count=0
  for f in "$src_dir"/*; do
    [[ -f "$f" ]] || continue
    local base
    base="$(basename "$f")"
    if [[ -e "$dst_dir/$base" && $FORCE -eq 0 ]]; then
      continue
    fi
    cp "$f" "$dst_dir/$base"
    count=$((count+1))
  done
  printf "  \033[32m✓\033[0m  %s (%d file(s) copied)\n" "$label" "$count"
}

# --- 1. CLAUDE.md (only if not present) ---
copy_safe "$KIT_ROOT/templates/CLAUDE.md" "$TARGET/CLAUDE.md" "CLAUDE.md (customize after bootstrap)"

# --- 2. Subagents ---
copy_tree_safe "$KIT_ROOT/templates/agents" "$TARGET/.claude/agents" ".claude/agents/"

# --- 3. Hooks (make executable) ---
copy_tree_safe "$KIT_ROOT/templates/hooks" "$TARGET/.claude/hooks" ".claude/hooks/"
chmod +x "$TARGET"/.claude/hooks/*.sh 2>/dev/null || true

# --- 4. Slash commands ---
copy_tree_safe "$KIT_ROOT/templates/slash-commands" "$TARGET/.claude/slash-commands" ".claude/slash-commands/"

# --- 5. Python scripts (made executable) ---
copy_tree_safe "$KIT_ROOT/templates/scripts" "$TARGET/.claude/scripts" ".claude/scripts/"
chmod +x "$TARGET"/.claude/scripts/*.py "$TARGET"/.claude/scripts/*.sh 2>/dev/null || true

# --- 6. Merge .claude/settings.json ---
SETTINGS="$TARGET/.claude/settings.json"
SETTINGS_TEMPLATE="$KIT_ROOT/templates/.claude-settings.json"

if [[ -f "$SETTINGS" ]]; then
  printf "  \033[33m·\033[0m  .claude/settings.json exists — merging hooks (preserves yours)\n"
  python3 - "$SETTINGS" "$SETTINGS_TEMPLATE" <<'PY'
import json, sys, pathlib
target, template = map(pathlib.Path, sys.argv[1:3])
t = json.loads(target.read_text())
m = json.loads(template.read_text())
t.setdefault("hooks", {})
for event, entries in m.get("hooks", {}).items():
    t["hooks"].setdefault(event, [])
    existing_commands = {e.get("command") for e in t["hooks"][event]}
    for e in entries:
        if e.get("command") not in existing_commands:
            t["hooks"][event].append(e)
target.write_text(json.dumps(t, indent=2) + "\n")
PY
else
  python3 - "$SETTINGS" "$SETTINGS_TEMPLATE" <<'PY'
import json, sys, pathlib
target, template = map(pathlib.Path, sys.argv[1:3])
m = json.loads(template.read_text())
m.pop("_comment", None)
target.parent.mkdir(parents=True, exist_ok=True)
target.write_text(json.dumps(m, indent=2) + "\n")
PY
  printf "  \033[32m✓\033[0m  .claude/settings.json (created from template)\n"
fi

# --- 7. docs/ scaffolding ---
mkdir -p "$TARGET/docs/spec" "$TARGET/docs/policy"

init_doc() {
  local path="$1" stub="$2"
  if [[ -f "$path" ]]; then
    return
  fi
  echo "$stub" > "$path"
}

init_doc "$TARGET/docs/learnings.md" "# Learnings

> Cross-session memory. Newest entries at the top. Subagents read this before acting.

---
"

init_doc "$TARGET/docs/analytics-events.md" "# Analytics events

_Auto-synced by .claude/hooks/sync-analytics.sh. Will populate once you add \`logEvent(...)\` calls in lib/._
"

init_doc "$TARGET/docs/release-history.md" "# Release history

| Version | Date | Track | Notes | Commit |
|---|---|---|---|---|
"

init_doc "$TARGET/docs/store-listing.md" "# Play Store listing

_Fill this in as you prepare for release. The deployer subagent reads from here._

## Short description (under 80 chars)

## Full description

## Asset paths
- Icon: assets/icon/icon.png
- Feature graphic: assets/store/feature-graphic.png
- Screenshots:
"

printf "  \033[32m✓\033[0m  docs/ scaffolding (spec/, policy/, learnings.md, analytics-events.md, release-history.md, store-listing.md)\n"

# --- 8. .gitignore additions (only if not present) ---
if [[ -f "$TARGET/.gitignore" ]] && ! grep -q "^# claude-code-mobile-kit" "$TARGET/.gitignore"; then
  cat >> "$TARGET/.gitignore" <<'EOF'

# claude-code-mobile-kit additions
.env
.env.local
*.keystore
*-service-account.json
android/key.properties
EOF
  printf "  \033[32m✓\033[0m  .gitignore (kit-specific lines appended)\n"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "✓ Bootstrap complete."
echo "════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo ""
echo "  1. Open the project's CLAUDE.md and fill in your app's details:"
echo "       cd \"$TARGET\""
echo "       \$EDITOR CLAUDE.md"
echo ""
echo "  2. Launch Claude Code from the project root:"
echo "       claude"
echo ""
echo "  3. Try your first slash command (safe place to start — generates policy drafts):"
echo "       /policy-sync"
echo ""
echo "  4. Then explore the rest: /new-feature, /implement, /compliance-check, /publish"
echo ""
echo "Read $KIT_ROOT/QUICKSTART.md for the 5-minute path, or"
echo "the full docs at $KIT_ROOT/docs/ for in-depth understanding."
echo ""

# 04 — Hooks

PostToolUse hooks are how the kit keeps the workspace coherent without nagging the developer. This doc explains the pattern and walks through the hooks the kit ships with.

---

## What PostToolUse hooks are

Claude Code lets you register scripts that run after specific tool invocations (file writes, bash commands, etc.). The hook receives metadata about what just happened and can do anything a shell script can: read other files, write to docs, append to a log, trigger another command.

The kit uses hooks for one thing: **keeping derived state in sync with primary state.**

Primary state = the source code, the configs, the specs. The things you actually edit.
Derived state = docs that describe the primary state. Analytics catalog, release history, policy pages, the learnings file.

Without hooks, derived state drifts. With hooks, it stays current automatically.

---

## What the kit hooks do

| Hook | Trigger | Action |
|---|---|---|
| `sync-analytics.sh` | Edit to any `.dart` file containing `logEvent` or `track` calls | Scan the project for all event names, update `docs/analytics-events.md` with current list |
| `sync-release-history.sh` | Edit to `pubspec.yaml` that bumps version | Append a row to `docs/release-history.md` with the new version, date, and a placeholder for release notes |
| `flag-policy-impact.sh` | Edit to permissions in `AndroidManifest.xml` or new SDK in `pubspec.yaml` | Write a "🟡 policy review needed" entry to `docs/learnings.md` so the compliance-checker picks it up next session |
| `capture-learning.sh` | After significant deployer or compliance-checker actions | Append a structured entry to `docs/learnings.md` capturing what happened and what the outcome was |

---

## Hook structure

Every hook in the kit is a small shell script in `.claude/hooks/`. The pattern:

```bash
#!/usr/bin/env bash
# Hook: sync-analytics.sh
# Fires on: PostToolUse where edited file matches *.dart with logEvent or track
# Purpose: re-sync the analytics events catalog when analytics code changes

set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
CATALOG="$PROJECT_ROOT/docs/analytics-events.md"

# Pull every logEvent / track call from .dart files
mapfile -t events < <(
  grep -rhoE '(logEvent|track)\(["'"'"'][^"'"'"']+["'"'"']' "$PROJECT_ROOT/lib" 2>/dev/null \
    | grep -oE '["'"'"'][^"'"'"']+["'"'"']' \
    | tr -d "\"'" \
    | sort -u
)

# Write fresh catalog
{
  echo "# Analytics events"
  echo ""
  echo "_Auto-synced by .claude/hooks/sync-analytics.sh on $(date '+%Y-%m-%d %H:%M')._"
  echo ""
  for e in "${events[@]}"; do
    echo "- \`$e\`"
  done
} > "$CATALOG"

echo "[hook] synced ${#events[@]} analytics events to $CATALOG"
```

The full implementation is at `templates/hooks/sync-analytics.sh`.

---

## How to register hooks with Claude Code

Hook registration is in your Claude Code configuration. The kit's templates assume the recent `.claude/settings.json` format:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": {
          "tool": "Edit|Write",
          "file_path_glob": "lib/**/*.dart"
        },
        "command": ".claude/hooks/sync-analytics.sh"
      },
      {
        "matcher": {
          "tool": "Edit|Write",
          "file_path_glob": "pubspec.yaml"
        },
        "command": ".claude/hooks/sync-release-history.sh"
      },
      {
        "matcher": {
          "tool": "Edit|Write",
          "file_path_glob": "android/app/src/main/AndroidManifest.xml"
        },
        "command": ".claude/hooks/flag-policy-impact.sh"
      }
    ]
  }
}
```

A template for the full `settings.json` is at `templates/.claude-settings.json` (you'll merge it with whatever you already have).

---

## What makes a hook a good fit (vs a slash command)

A hook should:

- **Be fast.** Hooks run after every matching tool call. Slow hooks make the agent feel sluggish.
- **Be idempotent.** Running it twice should produce the same result. No "append-only with no dedup" bugs.
- **Be silent on success.** A hook spamming the chat with "ran successfully!" is noise. Only output when something actionable happened.
- **Be confined.** Touch a small, specific set of files. A hook that modifies the project broadly is a refactoring tool, not a hook.

If your idea doesn't pass these checks, it's probably a slash command, not a hook.

---

## Anti-patterns

**Don't put logic in hooks.** They should be deterministic file transforms. If you need decisions, the right place is a slash command that invokes a subagent.

Bad: a hook that decides whether to bump the version based on the size of the diff.
Good: a hook that updates a release-history entry given a version bump has already happened.

**Don't let hooks fail loudly.** A failing hook shouldn't block the agent's main task. Wrap with `|| true` in the hook command (or handle errors gracefully inside the script).

**Don't write hooks that depend on each other.** Hooks fire in unpredictable order. If hook A needs hook B's output, that's a slash command sequence, not a hook chain.

---

## Debugging hooks

When a hook misbehaves:

1. **Check execute permissions:** `chmod +x .claude/hooks/*.sh`.
2. **Run it manually** with the same env vars Claude Code would set. The hook should work as a standalone shell script.
3. **Check the matcher.** Hooks not firing usually means the `file_path_glob` doesn't match. Watch what files Claude is actually editing.
4. **Add `set -x` temporarily** to a hook to see what it's doing.
5. **Check `.claude/hooks/` is at the project root** that Claude Code was invoked in. Hooks aren't recursive across parent directories.

---

## Examples from the kit

See:
- `templates/hooks/sync-analytics.sh` — the canonical "sync derived state" pattern
- `templates/hooks/sync-release-history.sh` — append-on-event with idempotency check
- `templates/hooks/flag-policy-impact.sh` — write-to-learnings pattern
- `templates/hooks/capture-learning.sh` — structured learning capture

All four are short (< 100 lines each) and are designed to be read and modified.

# Quickstart

From `git clone` to your first slash command in five minutes.

---

## Prerequisites (one-line check)

```bash
git clone https://github.com/prash5t/claude-code-mobile-kit.git
cd claude-code-mobile-kit
./scripts/check-prereqs.sh
```

This verifies Flutter, Claude Code, git, python3, and a couple of optional tools are installed. Fix anything it flags as missing.

---

## Option A — Try the kit against an existing Flutter project

```bash
./scripts/bootstrap.sh /path/to/your-flutter-app
cd /path/to/your-flutter-app
$EDITOR CLAUDE.md      # fill in your app's details
claude                  # launches Claude Code
```

In the Claude Code session, try:

```
/policy-sync
```

That regenerates `docs/policy/privacy-policy.md` and `docs/policy/terms.md` drafts based on your current code state and the SDKs in your `pubspec.yaml`. It's a safe first slash command — read-mostly, writes only to `docs/policy/`.

If that worked, you have the kit running. Move on to `/new-feature <brief>`, `/implement`, `/compliance-check`, `/publish` as you need them.

---

## Option B — See what a populated workspace looks like first

If you want to see the kit's end state before adopting it, browse [example/](example/). It shows a fictional indie app (DailyStreak) after several weeks of using the kit:

- [example/CLAUDE.md](example/CLAUDE.md) — what a filled-in CLAUDE.md looks like
- [example/docs/spec/daily-streak-widget.md](example/docs/spec/daily-streak-widget.md) — an architect-generated feature spec
- [example/docs/learnings.md](example/docs/learnings.md) — accumulated learnings across sessions
- [example/docs/analytics-events.md](example/docs/analytics-events.md) — what the auto-synced catalog looks like
- [example/docs/policy/privacy-policy.md](example/docs/policy/privacy-policy.md) — generated policy doc
- [example/docs/release-history.md](example/docs/release-history.md) — release log

These are reference materials. Reading them takes ~10 minutes and gives you a much clearer picture than the abstract docs alone.

---

## Option C — Create a fresh Flutter project just to try the kit

```bash
flutter create kit_demo
./scripts/bootstrap.sh kit_demo
cd kit_demo
$EDITOR CLAUDE.md      # fill in placeholder values
claude
# > /policy-sync
```

The fresh project gives you a safe sandbox to play with all the slash commands without risking an existing codebase.

---

## What just happened during bootstrap

`bootstrap.sh` did all of this in one shot:

1. Verified the target is a Flutter project
2. Copied `CLAUDE.md` template (only if you didn't have one)
3. Copied the 7 subagent templates to `.claude/agents/`
4. Copied 4 hook scripts to `.claude/hooks/` and made them executable
5. Copied 9 slash command templates to `.claude/slash-commands/`
6. Copied 4 Python helpers to `.claude/scripts/`
7. Merged `.claude/settings.json` (preserving any existing hooks of yours)
8. Created the `docs/` scaffolding: `spec/`, `policy/`, `learnings.md`, `analytics-events.md`, `release-history.md`, `store-listing.md`
9. Appended kit-specific lines to your `.gitignore` (env files, keystore, service account)

Re-running bootstrap is safe. It won't overwrite your CLAUDE.md or other customized files. Pass `--force` only if you want to reset everything to template defaults.

---

## Verifying the kit is wired up

Inside your Claude Code session, run:

```
> /
```

You should see this list:

- `/new-feature` — refine an idea into a spec
- `/implement` — build from an approved spec
- `/compliance-check` — Play Store policy audit
- `/configure` — wire a third-party SDK
- `/refresh-assets` — regenerate store assets
- `/publish` — bump version + build + upload to Play
- `/promote` — move releases between tracks
- `/check-health` — post-launch audit
- `/policy-sync` — regenerate policy docs

If those are visible, you're set up.

---

## Where to go next

- **Read [docs/01-overview.md](docs/01-overview.md)** to understand the workflow phases and subagent topology.
- **Read [METHODOLOGY.md](METHODOLOGY.md)** for the philosophy and trade-offs — what this kit is good at, what it isn't.
- **Skim [docs/03-subagents.md](docs/03-subagents.md)** to know what each subagent does so you invoke the right slash command for the task at hand.
- **Browse [example/](example/)** for a concrete reference of a populated workspace.

If something didn't work, open an issue at https://github.com/prash5t/claude-code-mobile-kit/issues.

# Changelog

All notable changes to this kit. Versioning is informal — semver-ish but this is a reference repo, not a published library.

## [0.2.0] — 2026-05-17

Usability pass. Removes the "read 8 docs and copy files by hand" friction.

- **`scripts/bootstrap.sh`** — one-command setup. Copies templates into a target Flutter project, merges `.claude/settings.json` safely (preserves existing hooks), initializes `docs/` scaffolding, appends to `.gitignore`. Idempotent. Smoke-tested.
- **`scripts/check-prereqs.sh`** — verifies Flutter, Claude Code, git, python3, and optional Play deploy tooling are installed. Run before bootstrap.
- **`QUICKSTART.md`** — 5-minute path from `git clone` to first slash command. Replaces the previous 5-step manual setup as the recommended path.
- **`example/`** — populated reference workspace using a fictional indie app (DailyStreak). Shows a filled-in CLAUDE.md, an architect-generated feature spec, accumulated learnings.md, synced analytics catalog, generated privacy policy, release history, and store listing copy.
- **README rewrite** — leads with the bootstrap command. Stripped self-deprecating "this isn't a framework like Django" framing.
- **METHODOLOGY** — minor cleanup; removed the same "what it isn't" defensive framing.
- **docs/02-setup.md** — refocused around bootstrap.sh as the canonical setup path, with troubleshooting section.

## [0.1.0] — 2026-05-17

Initial public release.

- README + METHODOLOGY explaining the philosophy and trade-offs
- Eight doc files covering overview, setup, subagents, hooks, slash commands, deploying, maintenance, self-improving loop
- Seven subagent templates: architect, implementer, compliance-checker, configurator, asset-generator, deployer, maintainer
- Four hook templates: sync-analytics, sync-release-history, flag-policy-impact, capture-learning
- Nine slash command templates: new-feature, implement, compliance-check, configure, refresh-assets, publish, promote, check-health, policy-sync
- Three Python helpers: play-upload, play-promote, test-play-auth
- One placeholder script: generate-asset (you adapt per your chosen backend)
- Project-level CLAUDE.md template
- .claude-settings.json template for hook registration

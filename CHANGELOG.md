# Changelog

All notable changes to this kit. Versioning is informal — semver-ish but this is a reference repo, not a published library.

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

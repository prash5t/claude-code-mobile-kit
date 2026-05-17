---
name: check-health
description: Post-launch health check. Crash triage, analytics drift, policy hot-spots, version hygiene.
---

Invoke the **maintainer** subagent (`.claude/agents/maintainer.md`).

## Steps

1. Read `CLAUDE.md` to know the app, its SDKs, and which crash/analytics tools are wired.
2. Run the maintainer's checklist:
   - Crash triage (if Crashlytics/Sentry wired)
   - Analytics drift (re-run `.claude/hooks/sync-analytics.sh`, diff vs prior state)
   - Policy hot-spot review (quick subset of the full compliance check)
   - Version hygiene (released vs current, fixes pending release)
   - Open follow-ups from prior learnings
3. Append learnings for any notable findings.
4. Report per the maintainer's output format with severity-coded summary and recommended actions (each a specific slash command).

## Rules

- You diagnose; you don't fix.
- If a finding is severe, surface it loudly. Don't bury blockers in a 🟢-heavy report.
- Recommendations must be specific slash commands the user can run, not vague advice.

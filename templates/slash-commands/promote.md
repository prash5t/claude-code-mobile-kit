---
name: promote
description: Promote a release from one Play Console track to another (e.g. internal-to-production).
arguments:
  - name: transition
    description: A transition string like "internal-to-production", "internal-to-closed", "closed-to-production"
    required: true
  - name: rollout
    description: Rollout percentage 0.0-1.0 (defaults to 1.0 = full)
    required: false
    default: "1.0"
---

Invoke the **deployer** subagent (`.claude/agents/deployer.md`) to promote a release.

## Steps

1. Parse `{{transition}}` into `from_track` and `to_track`.
2. Read the current release on `from_track` via the Play API.
3. Confirm with user: show version, track transition, rollout percent. Wait for explicit OK.
4. Run `.claude/scripts/play-promote.py --from <from_track> --to <to_track> --rollout {{rollout}}`.
5. Update `docs/release-history.md` with the track change.
6. Append to `docs/learnings.md`.
7. Report the new state and any Play Console review timing expectations.

## Rules

- Always require explicit user confirmation before calling the API. No silent promotions.
- Default rollout is 1.0 (full). Staged rollouts (0.1, 0.2 etc.) are fine when user requests.
- Never promote if the from-track release is still under Play review. Verify status first.
- Production promotion is the highest-risk action in the workflow. Be extra careful.

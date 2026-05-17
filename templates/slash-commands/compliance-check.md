---
name: compliance-check
description: Audit the current codebase for Play Store policy hot-spots. Updates docs/policy/ if drift detected.
---

Invoke the **compliance-checker** subagent (`.claude/agents/compliance-checker.md`).

## Steps

1. Read `CLAUDE.md` to understand the app's domain and SDKs.
2. Read `docs/learnings.md` for prior compliance issues.
3. Run the full compliance checklist from the subagent's template (permissions, data collection, ad placement, target SDK, content rating, restricted SDKs, IAP rules).
4. Cross-reference findings against `docs/policy/privacy-policy.md` — flag any data collection that isn't disclosed.
5. Update `docs/policy/` files to reflect current code reality if drift detected.
6. Append findings to `docs/learnings.md` for any 🟡 or 🔴 entries.
7. Report findings grouped 🟢 / 🟡 / 🔴 per the subagent's output format.

## Rules

- You report; you don't fix. Recommendations only.
- Be honest about uncertainty. Play policy changes; your checklist is a useful approximation, not authoritative.
- If your findings flag a clear blocker, recommend a specific follow-up command (e.g. "`/new-feature remove-unused-permission`").

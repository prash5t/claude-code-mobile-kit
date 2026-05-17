# 07 — Maintenance

Post-launch is where most indie apps die. Crashes go untriaged. Analytics drift unnoticed. Play Console sends an email about a policy change that no one reads. Three months later the app is suspended.

This doc covers the maintainer subagent and the patterns the kit uses to prevent the slow-death scenario.

---

## What "maintenance" means in this kit

Five recurring things:

1. **Crash triage** — checking Crashlytics or Sentry for new issues, summarizing them, suggesting fixes
2. **Analytics drift check** — making sure `docs/analytics-events.md` matches the actual `logEvent(...)` calls in code
3. **Policy hot-spot review** — re-running the compliance check periodically, since Play policy moves even if your code doesn't
4. **Version hygiene** — flagging if there are unreleased fixes sitting in the repo
5. **Capturing learnings** — appending insights to `docs/learnings.md` so future sessions inherit them

The maintainer subagent does all of these on a single `/check-health` invocation.

---

## How to run a health check

```
> /check-health
```

The maintainer subagent runs through a checklist (see template) and produces a report like:

```
Health check for <App Name> — 2026-05-17

🟢 Crash-free users: 99.7% (last 7 days, Crashlytics)
🟡 New crash detected: NullPointerException in HomeScreen._loadData (12 sessions, all on Android 14)
🟢 Analytics catalog matches code (38 events tracked)
🟡 Policy hot-spot: AdMob banner SDK version is 23.0.0 — 24.x is recommended for Play target SDK
🟢 No pending unreleased fixes
3 new learnings captured to docs/learnings.md

Recommended actions:
1. /new-feature fix the null-pointer in HomeScreen._loadData
2. /configure admob 24
```

Each "recommended action" is a concrete slash command. You decide which to act on.

---

## What goes in `docs/learnings.md`

This is the kit's cross-session memory. Three kinds of entries:

### Patterns
What worked, what didn't:

```markdown
## 2026-04-12 — AdMob banner placement
Tried inside ScrollView in v1.2.0. Triggered a "non-compliant ad placement" notice in Play Console.
Moved to fixed bottom bar in 1.2.1. Notice cleared.
Lesson: never put banner inside scrollable content.
```

### Outcomes
What shipping a feature produced:

```markdown
## 2026-04-20 — Daily-streak widget
Shipped 1.3.0. Engagement metric `home_streak_widget_view` was 60% of DAU on day 1.
Crash on first launch for users with empty history fixed in 1.3.1.
Lesson: always handle the empty-state path explicitly in new widgets.
```

### Operational facts
Things you'd otherwise forget:

```markdown
## 2026-05-01 — Play Console review timing
Internal-track uploads now take 1-3 hours for review (was minutes).
Closed-track promotion can take 24-72h.
Planning: don't batch promotions into a single day.
```

The maintainer subagent adds entries automatically. You can also add them yourself.

---

## Why the learnings file matters

Without it: every Claude Code session starts cold. Past mistakes get repeated. The pattern that worked last time has to be rediscovered.

With it: the first thing every subagent reads is `docs/learnings.md`. The architect knows "don't suggest features the user tried and rejected." The compliance-checker knows "AdMob banner in scrollview is a known issue, check for it." The deployer knows "Play review is slow this week, give buffer."

This is the "self-improving" part of the workflow. Not magical. Just disciplined.

See [docs/08-self-improving.md](08-self-improving.md) for how the learnings file is integrated with hooks.

---

## Scheduling health checks

You can:

**(a) Run manually** when you remember. Realistic for a one-app indie dev who's actively iterating.

**(b) Wire to cron** for multi-app shippers who want a regular sweep:

```bash
# In your crontab
0 9 * * MON cd ~/projects/yourapp && claude-code --slash /check-health > /tmp/yourapp-health.log
```

**(c) Trigger from a top-level "shipper" repo** if you have many apps and want a Monday-morning rollup of all their health checks. The kit doesn't ship a multi-app coordinator, but the pattern is straightforward to build.

---

## Common maintenance tasks beyond what `/check-health` covers

Some things the kit doesn't try to automate, but flags in the maintainer subagent's output:

- **Reading actual user reviews on Play Store.** Some recurring themes belong as new specs. You'll need to read reviews yourself; the maintainer just reminds you.
- **Refreshing screenshots** when the UI changes meaningfully. `/refresh-assets` covers this but you have to invoke it.
- **Updating store listing copy.** The kit doesn't auto-rewrite your app description. You'll want to do this periodically based on what's working.
- **Privacy policy updates** when laws change (GDPR, COPPA, India DPDP). The compliance-checker stays current within Google Play policy but doesn't track all global privacy law shifts.

---

## What "the workflow handles maintenance" actually means (vs marketing claim)

Honest version:

- **Auto-handled:** keeping `docs/learnings.md`, `docs/analytics-events.md`, `docs/release-history.md` coherent. Surfacing new crashes if you've wired Crashlytics. Flagging known policy hot-spots.

- **Suggested but not auto-executed:** fixes to bugs, version bumps for hotfixes, policy doc regeneration, asset refreshes. The maintainer recommends; you (or another subagent invocation) acts.

- **Not handled at all:** reading user reviews, responding to support emails, dealing with Google policy ban appeals, ranking/ASO. These need a human or a dedicated tool.

If you treat the kit as "auto everything" you'll get surprised by what it doesn't do. If you treat it as "auto-tracks the boring stuff so I can focus on judgment calls," it's accurate.

---

## Files referenced

- `templates/agents/maintainer.md` — subagent definition
- `templates/slash-commands/check-health.md` — `/check-health` command
- `templates/hooks/capture-learning.sh` — auto-appends learnings from significant events

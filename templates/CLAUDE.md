# Project: <APP NAME>

> Auto-loaded by Claude Code at the start of every session in this directory.
> Read it. Apply it. The subagents and hooks rely on this file being current and accurate.

---

## Identity

- **Package ID:** com.yourorg.yourapp
- **Display name:** My App
- **Domain / niche:** <e.g. utility / productivity / health / games / consumer>
- **Target audience:** <who actually uses this>
- **Monetization:** <ads-only / ads + IAP / one-time paid / subscription / freemium>
- **Launch region:** <Worldwide / specific countries>
- **Languages supported:** <English only / list of locales>

## Tech stack

- **Flutter:** 3.x
- **State management:** <Bloc / Cubit / Riverpod / Provider / GetX>
- **Architecture pattern:** <feature-first clean architecture / MVVM / vanilla>
- **Backend:** <Firebase / custom REST / Supabase / serverless / none>
- **Auth:** <Firebase Auth / custom / Google Sign-In / Apple Sign-In / none>
- **Database (server):** <Firestore / Postgres / SQLite-only>
- **Database (client):** <Hive / SQLite / shared_preferences>
- **Analytics:** <Firebase Analytics / Mixpanel / Posthog / none>
- **Crash reporting:** <Crashlytics / Sentry / none>
- **Monetization SDKs:** <AdMob / RevenueCat / Stripe Mobile / none>
- **CI/CD:** <none (manual) / GitHub Actions / Codemagic>

## Constraints

- **Min SDK:** Android 21 / iOS 13 (adjust to your reality)
- **Target SDK:** latest stable
- **Accessibility:** <basic / WCAG AA / not in scope>
- **Privacy:** Collects <list of data types>; see `docs/policy/privacy-policy.md`
- **Network:** App must work offline for <these specific flows>
- **Performance:** Cold start under <Xs> on mid-tier device

## Rules (non-negotiable)

1. **Never commit secrets.** Use `.env` (gitignored). Reference via env vars in code.
2. **Run `flutter analyze` and `flutter test` before any commit to main.**
3. **Never bump version manually.** Use `/publish <track>`. The deployer handles version + tag + release notes.
4. **Never edit `docs/analytics-events.md` by hand.** The hook syncs it from code. If you want to add an event, add the `logEvent(...)` call; the hook does the rest.
5. **Read `docs/learnings.md` at the start of every task.** Apply rules captured there.
6. <add your own>

## Subagents available

This project uses the kit's standard subagents. See `.claude/agents/` for definitions. Quick reference:

- `architect` — refines ideas into specs (`docs/spec/*.md`)
- `implementer` — writes Flutter code
- `compliance-checker` — Play Store policy review + `docs/policy/*` maintenance
- `configurator` — Firebase / AdMob / analytics setup
- `asset-generator` — icon, screenshots, store assets
- `deployer` — Play Console submission
- `maintainer` — post-launch health checks

## Slash commands available

See `.claude/slash-commands/` for full definitions. Quick reference:

- `/new-feature <brief>` — invoke architect
- `/implement <spec-name>` — invoke implementer
- `/compliance-check` — invoke compliance-checker
- `/configure <integration>` — invoke configurator
- `/refresh-assets` — invoke asset-generator
- `/publish <track>` — invoke deployer
- `/promote <from>-to-<to>` — promotion via deployer
- `/check-health` — invoke maintainer
- `/policy-sync` — regenerate policy docs
- `/distill-learnings` — periodic cleanup of `docs/learnings.md`

## Project layout

```
.
├── CLAUDE.md                    (this file)
├── pubspec.yaml
├── lib/                         (Flutter source)
├── test/
├── assets/                      (in-app + store assets)
├── android/, ios/
├── .claude/
│   ├── agents/                  (subagent definitions)
│   ├── hooks/                   (PostToolUse hooks)
│   └── slash-commands/          (custom commands)
└── docs/
    ├── spec/                    (architect-generated feature specs)
    ├── policy/                  (privacy policy, terms — compliance-generated)
    ├── store-listing.md         (Play Console listing copy)
    ├── analytics-events.md      (auto-synced by hook)
    ├── release-history.md       (hook-maintained)
    └── learnings.md             (cross-session memory)
```

## Working notes

<Use this section for short-term context that doesn't belong in learnings — e.g. "currently working on streak feature, branch streak-v2", "Play Console review is slow this week", etc. Wipe periodically.>

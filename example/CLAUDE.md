# Project: DailyStreak

> Auto-loaded by Claude Code at the start of every session in this directory.
> Read it. Apply it.

---

## Identity

- **Package ID:** com.example.dailystreak
- **Display name:** DailyStreak
- **Domain / niche:** productivity / habit tracking
- **Target audience:** Solo users wanting to build daily habits; light gamification (streak counters, milestone badges)
- **Monetization:** ads-only (banner + occasional interstitial between habit-log sessions)
- **Launch region:** Worldwide
- **Languages supported:** English (en-US) — l10n planned for v1.5+

## Tech stack

- **Flutter:** 3.24.x (stable)
- **State management:** Riverpod 2.x
- **Architecture pattern:** feature-first clean architecture (domain / data / presentation per feature)
- **Backend:** Firebase (Firestore for sync, Anonymous Auth as default identity, optional Google Sign-In)
- **Auth:** Firebase Auth (Anonymous + Google Sign-In as upgrade)
- **Database (server):** Firestore
- **Database (client):** Hive (offline-first; syncs to Firestore when online)
- **Analytics:** Firebase Analytics
- **Crash reporting:** Crashlytics
- **Monetization SDKs:** Google Mobile Ads (AdMob)
- **CI/CD:** manual (no GitHub Actions yet)

## Constraints

- **Min SDK:** Android 21 (Android 5.0 Lollipop)
- **Target SDK:** 34 (matches current Play target requirement)
- **Accessibility:** basic — large tap targets, supports system font scaling. Full WCAG AA not in scope yet.
- **Privacy:** Collects: device identifier (anonymous), habit data, app usage events. No PII collected by default; Google account email only if user signs in. See `docs/policy/privacy-policy.md`.
- **Network:** App must work fully offline — Firestore sync resumes when online.
- **Performance:** Cold start under 1.5s on mid-tier 2022 Android device.

## Rules (non-negotiable)

1. **Never commit secrets.** Use `.env` (gitignored). Reference via env vars.
2. **Run `flutter analyze` and `flutter test` before any commit to main.**
3. **Never bump version manually.** Use `/publish <track>`. The deployer handles version + tag + release notes.
4. **Never edit `docs/analytics-events.md` by hand.** The hook syncs it from code.
5. **Read `docs/learnings.md` at the start of every task.** Apply rules captured there.
6. **AdMob banner placement:** never inside scrollable content. Use the fixed bottom-bar pattern only. (See learnings entry from 2026-04-12.)
7. **Streak reset time:** at midnight in the user's local time zone, not UTC. (See learnings entry from 2026-05-17.)

## Subagents available

Standard kit set. See `.claude/agents/` for definitions.

## Slash commands available

Standard kit set. See `.claude/slash-commands/` for definitions.

## Project layout

```
.
├── CLAUDE.md
├── pubspec.yaml
├── lib/
├── test/
├── assets/
│   ├── icon/
│   └── store/
├── android/, ios/
├── .claude/
│   ├── agents/
│   ├── hooks/
│   ├── slash-commands/
│   └── scripts/
└── docs/
    ├── spec/
    ├── policy/
    ├── store-listing.md
    ├── analytics-events.md
    ├── release-history.md
    └── learnings.md
```

## Working notes

- Currently iterating on v1.3 — adding the daily-streak-widget feature (see `docs/spec/daily-streak-widget.md`).
- Holding off on l10n until we hit 10k DAU.
- Play review times have been 1-3h for internal track in the last two weeks, which is faster than usual.

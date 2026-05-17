# Learnings

> Cross-session memory. Newest entries at the top. Subagents read this before acting.

---

## 2026-05-17 — Architect: daily-streak-widget specced

Specced the home-screen widget. Notable decisions:
- Android-only for v1.3; iOS WidgetKit deferred to a separate spec for v1.4.
- Empty-state for broken streaks shows "Streak broken — start a new one" rather than showing 0. Per user research: showing a 0 is discouraging.
- Streak time-zone: user-local midnight (not UTC). Captured as Rule 7 in CLAUDE.md.
**Rule going forward:** when adding new time-bound features, default to user-local time zone unless there's a specific reason (e.g. global leaderboards) to use UTC.
**Source:** /new-feature on 2026-05-17

## 2026-05-15 — Maintainer: Empty-state crash in HomeScreen._loadData

12 sessions affected on Android 14 builds; NullPointerException when streak history is empty.
Fixed in v1.2.4 by adding explicit empty-state branch before parsing history.
**Rule going forward:** always handle the empty path explicitly in new widgets and screens that read user state. The "no data yet" path is the most-skipped edge case.
**Source:** /check-health on 2026-05-15

## 2026-05-10 — Release v1.2.3

Internal track upload succeeded. Notes: "Added milestone celebrations. Fixed habit reorder bug on long lists."
Internal review completed in 2h. Promoted to production same day.
**Source:** /publish patch on 2026-05-10

## 2026-04-22 — Compliance: AdMob banner placement

v1.2.0 placed banner inside a SingleChildScrollView on Home. Play Console flagged it as "non-compliant ad placement" via email two days after release.
Moved to fixed bottom-bar layout in v1.2.1. Notice cleared.
**Rule going forward:** never place banner ads inside scrollable content. Captured as Rule 6 in CLAUDE.md.
**Source:** /compliance-check on 2026-04-22, after Play Console email

## 2026-04-12 — Configurator: Firebase + AdMob co-init order

Firebase and AdMob both initialize in main.dart. Order mattered: AdMob's tracking-authorization request on iOS conflicted with Firebase Analytics setup if AdMob initialized first.
Fix: always `Firebase.initializeApp()` before `MobileAds.instance.initialize()`.
**Rule going forward:** Firebase before any other SDK that may touch identifiers.
**Source:** /configure admob on 2026-04-12

## 2026-04-05 — Architect: rejected feature — social sharing

User rejected social-sharing of streaks. Privacy concern: not all users want their habits visible.
**Rule going forward:** don't re-suggest social sharing unless the user raises it. If raised, default to private-by-default with explicit opt-in.
**Source:** /new-feature on 2026-04-05

## 2026-03-28 — Operational: Play review timing

Internal-track uploads taking 1-3h for review (was minutes last quarter).
Closed-track promotion taking 24-72h.
Planning implication: schedule production rollouts mid-week so promotion + monitor window is safely before weekend.
**Source:** observation during /publish on 2026-03-28

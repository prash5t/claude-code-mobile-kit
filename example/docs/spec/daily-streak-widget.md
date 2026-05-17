# Feature spec: daily-streak-widget

**Status:** approved
**Complexity:** M
**Date:** 2026-05-17

## Goal

Add a home-screen widget that shows the user's current streak length and the next milestone, increasing return engagement on days the user hasn't opened the app yet.

## Non-goals

- Not adding an iOS WidgetKit equivalent yet (deferred to v1.4 — Android first).
- Not adding interactivity (tap-to-log) — read-only widget for v1.3. Interactivity is a separate spec.
- Not redesigning the in-app home screen.

## User-facing changes

- New Android home screen widget (HomeWidget plugin) at two sizes: 2x2 and 4x2.
- Widget shows: current streak count (large), today's habit name (if any logged), next milestone badge name.
- Tapping the widget opens the app to the Home screen.
- Updated automatically when a habit is logged in-app.

## Technical approach

- Use the `home_widget` package for Android-side widget rendering.
- Streak state is already in Hive locally. Widget reads from a small projection of that state cached to platform-level shared prefs (the widget Android side can't directly read Hive).
- Trigger widget update via `HomeWidget.updateWidget()` from the existing `StreakRepository.recordHabitLog()` callback.
- Add a service that runs on app launch to refresh widget content (in case device was rebooted or app was closed when state changed via Firestore sync).
- New widget receiver registered in `AndroidManifest.xml`.

## Data model changes

- No Firestore schema changes.
- Add `streak_widget_projection` shared-prefs key (JSON blob with: currentStreak, todayHabit, nextMilestoneName, lastUpdatedAt).

## Analytics events

- `home_streak_widget_view` — fired when widget content is updated (server-side, via app process)
- `home_streak_widget_tap` — fired when user taps widget and app opens (read from deep link parameter)

## Edge cases

- **Empty state:** if no streak yet, widget shows "Start a streak today" placeholder.
- **Offline / no Firestore:** widget reads from Hive-backed local state; nothing changes.
- **Streak just broke:** widget shows "Streak broken — start a new one" empty state until first habit logged. (Specifically: don't show the broken streak as a number; that's discouraging.)
- **User has not opened app today and streak is at risk:** widget shows "Don't lose your streak — log today" call to action when current time is past 8 PM local AND today's habits not yet logged.
- **Device locale:** widget text uses the same l10n resource as in-app strings. Defaults to en-US if locale unsupported.

## Open questions

(none — resolved during specing)

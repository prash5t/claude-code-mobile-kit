---
name: publish
description: Bump version, build signed AAB, upload to a Play Console release track. Defaults to internal track.
arguments:
  - name: bump
    description: One of "patch", "minor", "major", or an explicit version string like "1.5.0+50"
    required: true
  - name: track
    description: One of "internal", "alpha", "beta", "production". Defaults to "internal".
    required: false
    default: internal
---

Invoke the **deployer** subagent (`.claude/agents/deployer.md`) to ship a build.

## Steps

1. Run pre-flight checks:
   - `flutter analyze` clean
   - `flutter test` passing
   - Git working tree clean
   - `docs/policy/privacy-policy.md` exists
   - Signing keystore configured (`android/key.properties` exists and references a real keystore)
   - `$GOOGLE_PLAY_SERVICE_ACCOUNT_KEY_PATH` env var set and file exists
2. If any pre-flight fails, abort and report which check failed.
3. Bump `pubspec.yaml` version per `{{bump}}` argument and commit (`chore: bump version to <new>`).
4. Read `git log` and `docs/spec/` changes since last release tag. Draft release notes (3-6 short bullets, < 500 chars).
5. Save draft notes to `/tmp/release-notes.txt` and show to user. Wait for approval.
6. Build: `flutter clean && flutter pub get && flutter build appbundle --release`.
7. Verify AAB is signed via `jarsigner -verify`. Abort if unsigned.
8. Upload via `.claude/scripts/play-upload.py` to track **{{track}}** with the approved release notes.
9. Tag the commit `v<new-version>` and push.
10. Append a row to `docs/release-history.md`.
11. Append a `## YYYY-MM-DD — Release v<version>` entry to `docs/learnings.md` (use the `capture-learning.sh` hook with appropriate env vars).
12. Report: version, track, Play Console URL, suggested next step (wait for review, then `/promote`).

## Rules

- Never push directly to `production` track via this command if `{{track}}` was specified as `internal` default — to publish to production, the user must explicitly pass `production` as the track arg AND confirm a second time.
- Never skip pre-flight checks.
- Never modify code as part of a release. If issues are found, abort, fix in a new session, re-run.
- Never commit secrets.

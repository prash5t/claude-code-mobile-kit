---
name: configure
description: Wire a third-party integration (firebase, admob, mixpanel, crashlytics, sentry, etc.) into the project.
arguments:
  - name: integration
    description: One of firebase, admob, mixpanel, crashlytics, sentry, or a custom name documented in the configurator template
    required: true
---

Invoke the **configurator** subagent (`.claude/agents/configurator.md`) to set up the **{{integration}}** integration.

## Steps

1. Read `CLAUDE.md` and `pubspec.yaml` to know what's already configured.
2. Ask the user for any required secrets (API keys, project IDs) you don't already have.
3. Follow the per-integration steps in the configurator template for **{{integration}}**.
4. Add required env vars to `.env` (gitignored) and document them in `.env.example`.
5. Update `pubspec.yaml`, native config files (AndroidManifest, Info.plist, build.gradle, Podfile as relevant).
6. Initialize the SDK in `main.dart` where appropriate.
7. Run `flutter pub get`, `flutter analyze`, `flutter build apk --debug` to verify the build still works.
8. Update `CLAUDE.md`'s Tech stack section to reflect what's now wired.
9. Report files changed, env vars added, any user action still required (e.g. `pod install` for iOS).

## Rules

- Never commit secret values. Always env-var-driven.
- Never invent API keys / project IDs. Ask the user.
- Don't write business-logic code (feature usage of the SDK). That's the implementer's job.
- Don't change Min/Target SDK without the user's explicit OK.

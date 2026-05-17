---
name: refresh-assets
description: Regenerate app icon, feature graphic, and Play Store screenshots.
arguments:
  - name: which
    description: One of "all", "icon", "feature-graphic", "screenshots". Defaults to "all".
    required: false
    default: all
---

Invoke the **asset-generator** subagent (`.claude/agents/asset-generator.md`) to refresh the visual assets.

## Steps

1. Read `CLAUDE.md` for app identity (name, domain, brand notes).
2. Read `docs/store-listing.md` for current listing copy and visual style notes.
3. For the requested asset type **{{which}}** (default: all):
   a. Look at existing version in `assets/store/` or `android/app/src/main/res/`.
   b. Call the configured image-generation backend (see `.claude/scripts/generate-asset.sh`).
   c. Save the output to the canonical path.
   d. Verify size and format meet Play Console requirements.
4. Update `pubspec.yaml` asset declarations if new paths were added.
5. Update `docs/store-listing.md` with the new asset paths.
6. Append a learning entry if a generation approach worked or failed notably.
7. Report what was generated, where, and any next steps.

## Rules

- Don't put third-party trademarks or famous logos in generated assets.
- Don't show features in screenshots that aren't actually implemented (Play policy bans misleading screenshots).
- Match the app's existing visual style; don't drift to a different aesthetic without user OK.
- If no image-generation backend is configured, ask the user to either configure one (see `.claude/scripts/generate-asset.sh`) or provide static assets manually.

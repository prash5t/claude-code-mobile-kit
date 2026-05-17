# 06 — Deploying to Play Store

This doc covers the deployer subagent and how to wire it up with the Google Play Developer API so it can actually submit releases.

This is the most complex setup step in the kit. Allow ~2 hours the first time, mostly because Google's setup flow is what it is.

---

## What the deployer subagent does

When you run `/publish patch` (or `minor` or `major`):

1. Reads `pubspec.yaml` to get the current version
2. Bumps the version (patch increments build number; minor/major increments the SemVer component)
3. Reads `docs/spec/` changes since the last release to draft release notes
4. Runs `flutter build appbundle --release`
5. Authenticates to Play Console using a service account JSON key
6. Uploads the resulting `.aab` to the Internal testing track
7. Sets release notes (drafted in step 3)
8. Appends a row to `docs/release-history.md`
9. Reports the result to you with a link to Play Console

It does NOT auto-promote to higher tracks. That's separate (`/promote`).

---

## One-time Play Console setup

### 1. Create a Play Developer account

If you don't have one yet:

1. Go to https://play.google.com/console
2. Pay the USD 25 one-time registration fee (Google charges this directly)
3. Complete the account verification flow

You'll need an Android Studio project / Flutter project ready to register a package.

### 2. Create your first app entry on Play Console

In Play Console UI:

1. Click "Create app"
2. Pick your app name, default language, app type (App / Game), free/paid
3. Accept Play Developer Program Policies

Don't worry about completing the listing yet. You just need an app entry for the deployer to upload to.

### 3. Set up a service account for API access

The deployer subagent talks to Play Console via the API. That needs a service account:

1. Open the Play Console → Setup → API access
2. Click "Create new service account" — this redirects to Google Cloud Console
3. In Google Cloud Console, create the service account
4. Generate a JSON key for the service account → download it
5. Back in Play Console, grant the service account "Release apps to testing tracks" permission (or higher if you want it to promote to Production directly — generally don't, keep that manual)

Store the JSON key somewhere safe outside your git repo. **Never commit this file.**

### 4. Tell the kit where the key lives

Add to your project's `.env` (which should be in `.gitignore`):

```
GOOGLE_PLAY_SERVICE_ACCOUNT_KEY_PATH=/Users/you/keys/play-service-account.json
GOOGLE_PLAY_PACKAGE_NAME=com.yourorg.yourapp
```

The deployer subagent reads these env vars.

### 5. Create a signing keystore

Your release builds need to be signed. Once. Don't lose this file.

```bash
keytool -genkey -v -keystore ~/keys/yourapp-release.keystore -alias yourapp -keyalg RSA -keysize 2048 -validity 10000
```

Then in your Flutter project, create `android/key.properties` (gitignored):

```
storePassword=<your password>
keyPassword=<your password>
keyAlias=yourapp
storeFile=/Users/you/keys/yourapp-release.keystore
```

And in `android/app/build.gradle` (the template provides this):

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 6. Test the auth manually before trusting the deployer

Before letting the subagent do this for you, verify the credentials work:

```bash
python3 templates/scripts/test-play-auth.py
```

(See `templates/scripts/` for this helper.) If it prints "Auth OK, packages visible: [...]" you're set. If it errors, fix the credentials before anything else.

---

## How `/publish` works under the hood

Step-by-step on what the deployer subagent actually does:

1. **Version bump.** Reads `pubspec.yaml`, parses `version: <name>+<build>`, increments the right component based on the publish argument:
   - `patch`: build number only (e.g. `1.2.3+45` → `1.2.3+46`)
   - `minor`: bump minor + reset patch (`1.2.3+45` → `1.3.0+46`)
   - `major`: bump major + reset minor/patch (`1.2.3+45` → `2.0.0+46`)

2. **Release notes draft.** Reads `git log` since the last tag matching the previous version, plus any new `docs/spec/<feature>.md` files added since then. Drafts a short release-notes string.

3. **Build.** Runs `flutter build appbundle --release` from project root.

4. **Upload.** Uses the Python script `templates/scripts/play-upload.py` (which wraps `google-api-python-client`):
   ```bash
   python3 .claude/scripts/play-upload.py \
       --package "$GOOGLE_PLAY_PACKAGE_NAME" \
       --aab build/app/outputs/bundle/release/app-release.aab \
       --track internal \
       --release-notes-file /tmp/release-notes.txt
   ```

5. **Tag the commit.** `git tag v<new-version>` and push.

6. **Update release history.** Append a row to `docs/release-history.md`:
   ```
   | 1.3.0+46 | 2026-05-17 | Internal | Added daily-streak widget; fixed crash on first launch | a1b2c3d |
   ```

7. **Report.** Tells you "Uploaded to Internal track. Link: https://play.google.com/console/...". You promote manually when ready.

---

## Promotion flow

Use `/promote internal-to-production` (or `internal-to-closed`, `closed-to-production`) to move a release through tracks.

This calls the Play API to copy the release from one track to another. The deployer subagent:

1. Reads the current release on the source track
2. Confirms with you ("about to promote 1.3.0+46 from internal to production — proceed?")
3. Copies the release
4. Sets the rollout percentage (defaults to 100% for production, but you can override)
5. Updates `docs/release-history.md`

---

## Why no auto-promote to production

Two reasons:

1. **Google Play review timing is unpredictable.** A release in internal track that uploaded fine might get rejected when you promote to production. Forcing a human checkpoint before production catches this.

2. **Production rollouts are expensive to revert.** A bad release reaching production hurts. The kit deliberately makes that gate manual.

If you really want fully-automatic production releases, you can write your own slash command that chains `/publish` and `/promote`. The kit just doesn't ship one.

---

## Failure modes and how to handle them

**Build fails.** Probably a Flutter issue, not a kit issue. Run `flutter build appbundle --release` manually to see the real error.

**Auth fails on upload.** Re-run the auth test script. Common: service account doesn't have permissions, or the JSON key path is wrong.

**Play Console returns an "Invalid AAB" error.** Usually a signing config problem. Verify your release is actually signed: `jarsigner -verify -verbose build/app/outputs/bundle/release/app-release.aab`.

**"Version code must be greater than X" error.** Play Console requires monotonically increasing build numbers per track. The deployer reads the current Play Console state but sometimes a manual upload elsewhere bumped the number. Manually edit `pubspec.yaml` to skip ahead.

**Release notes too long.** Play Console limits release notes to 500 characters per language. The deployer truncates; check `release-history.md` for the full version.

---

## What's NOT in the kit

- iOS / App Store deployment. The deployer is Play-only for now. Adapting to App Store Connect uses similar patterns but a different API (App Store Connect API instead of Google Play Developer API). Not pre-built in this kit.
- Multi-language listing management. You'd want a separate subagent for that.
- Per-country pricing for paid apps. Manual via Play Console.
- A/B testing tracks. Use Play Console UI for those.

---

## Files referenced

- `templates/agents/deployer.md` — subagent definition
- `templates/slash-commands/publish.md` — `/publish` command
- `templates/slash-commands/promote.md` — `/promote` command
- `templates/scripts/play-upload.py` — actual API client
- `templates/scripts/test-play-auth.py` — credentials test

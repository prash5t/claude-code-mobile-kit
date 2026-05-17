# 02 — Setup (detailed)

For the fast path, see [QUICKSTART.md](../QUICKSTART.md). This doc is the in-depth version with all the prerequisites, edge cases, and what to do if something goes wrong.

Allow ~1-2 hours for the first time. Most of that is creating a Google Play Developer account if you don't have one and reading Play Console docs. The actual kit setup is a single command.

---

## Prerequisites

### On your machine
- **Flutter SDK** installed and `flutter doctor` happy. Tested on Flutter stable 3.x.
- **Claude Code** installed and authenticated. https://docs.claude.com/en/docs/claude-code
- **git** configured.
- **Python 3.10+** (for the Play Console helper scripts).
- A code editor of your choice.

### Accounts
- **Anthropic account** with API access enabled. Claude Code uses your Anthropic credits.
- **Google Play Console developer account.** One-time USD 25 fee. Set up at https://play.google.com/console. You only need this when you're ready to deploy; you can use the rest of the kit (specs, implementation, compliance checks, policy generation) without it.
- **Firebase project** for your app (optional, but assumed by most templates).
- A keystore for signing your Android release builds. Setup instructions in [06-deploying.md](06-deploying.md).

### Knowledge
- Comfort with: git, the command line, Markdown, YAML, basic Flutter project structure.
- You don't need: prior experience with multi-agent systems, custom Claude Code configuration, or the Play Console API.

### Quick check

From the kit's root:

```bash
./scripts/check-prereqs.sh
```

This verifies Flutter, Claude Code, git, and python3 are installed. It also looks for the Python packages the deploy scripts need. Fix anything it flags before continuing.

---

## Setup (the fast path)

```bash
# From the kit's root
./scripts/bootstrap.sh /path/to/your-flutter-app
```

That single command:

1. Verifies the target is a Flutter project
2. Copies `CLAUDE.md` template (skips if you already have one)
3. Copies subagent templates to `.claude/agents/`
4. Copies hook scripts to `.claude/hooks/` and makes them executable
5. Copies slash command templates to `.claude/slash-commands/`
6. Copies Python helpers to `.claude/scripts/`
7. Merges `.claude/settings.json` — preserves your existing hooks if any
8. Initializes the `docs/` scaffolding: `spec/`, `policy/`, `learnings.md`, `analytics-events.md`, `release-history.md`, `store-listing.md`
9. Appends kit-specific lines to `.gitignore` (env files, keystore, service-account JSON)

Re-running bootstrap is safe. It won't overwrite your customized files. Pass `--force` if you explicitly want to reset everything to template defaults.

---

## After bootstrap

### Step 1. Customize `CLAUDE.md`

Open the `CLAUDE.md` in your project root and fill in the placeholders. The architect, implementer, and compliance subagents all read this at the start of every task — accurate values here cascade to better output everywhere.

Fields you'll set:

- **Identity:** package ID, display name, niche, monetization, launch region
- **Tech stack:** state management library, backend, auth, analytics, crash reporting, monetization SDKs
- **Constraints:** min/target SDK, privacy data scope, accessibility level
- **Rules:** project-specific rules subagents must respect (e.g., "never commit secrets to git", "always run `flutter analyze` before commit")

Look at [example/CLAUDE.md](../example/CLAUDE.md) for a fully filled-in version using a fictional app (DailyStreak).

### Step 2. Launch Claude Code in the project

```bash
cd /path/to/your-flutter-app
claude
```

That drops you into a Claude Code session with the kit's slash commands loaded.

### Step 3. Try the first slash command

The safest first slash command is `/policy-sync`. It reads your CLAUDE.md and generates `docs/policy/privacy-policy.md` and `docs/policy/terms.md` drafts based on your stated monetization model and SDK list.

```
> /policy-sync
```

Read the output. The drafts are starting points, not legally vetted documents. You'll need to:
- Read them carefully
- Adjust them for your real situation
- Have them reviewed by someone qualified if you're in a high-risk niche (children's apps, fintech, health, etc.)

Look at [example/docs/policy/privacy-policy.md](../example/docs/policy/privacy-policy.md) for the kind of output to expect.

---

## Verifying the kit is wired up

Inside your Claude Code session, type:

```
> /
```

You should see all kit slash commands listed: `/new-feature`, `/implement`, `/compliance-check`, `/configure`, `/refresh-assets`, `/publish`, `/promote`, `/check-health`, `/policy-sync`.

If they don't appear, see "Troubleshooting" below.

You can also try a subagent invocation:

```
> Read the CLAUDE.md and tell me what app this is.
```

Claude should respond with details from the values you filled in. If it doesn't, the CLAUDE.md isn't being read — fix that before going further.

---

## Setting up Play Console deploys (when you're ready)

Don't tackle this on day one. Come back when you have a build you're ready to ship.

The deployer subagent uses the Google Play Developer API. You'll need:

1. A service account with Play Console access (created via Play Console → Setup → API access)
2. A JSON key file for that service account
3. The key file referenced by an environment variable

Full instructions in [06-deploying.md](06-deploying.md).

For now, just be aware this is the gate between "can use kit locally" and "can actually submit to Google."

---

## Troubleshooting

**"Claude Code doesn't see my slash commands."**
- Did bootstrap run successfully? Check `.claude/slash-commands/` exists in your project.
- Did you restart your Claude Code session after bootstrap? Recent versions auto-detect, older ones don't.
- Is your Claude Code version recent enough to read project-level slash commands?

**"Subagent invocation seems to ignore CLAUDE.md."**
- The CLAUDE.md must be at the root of the project Claude Code was invoked in. If you launched Claude Code from a parent directory, it's reading a different CLAUDE.md (or none).
- Verify the file exists at the project root, not under a subdirectory.

**"flutter analyze fails on a fresh template."**
- Run `flutter pub get` first. The template references some packages by default.

**"Hook scripts aren't firing."**
- Hooks need execute permissions: `chmod +x .claude/hooks/*.sh`. Bootstrap should have done this; if it didn't, do it manually.
- Check that your Claude Code version supports PostToolUse hooks (recent versions do; very early versions don't).
- Check `.claude/settings.json` to see whether the hooks are registered. Bootstrap merges these in.

**"Bootstrap says target isn't a Flutter project."**
- Verify `pubspec.yaml` exists at the path you passed.
- Verify `pubspec.yaml` has a `flutter:` section.

---

## What `bootstrap.sh` did NOT do for you

- It didn't fill in your `CLAUDE.md` values. You do that.
- It didn't configure Firebase, AdMob, or any other third-party SDK. Use `/configure <integration>` for those.
- It didn't generate icon/screenshots. Use `/refresh-assets`.
- It didn't set up Play Console API auth. See [06-deploying.md](06-deploying.md).
- It didn't write any Flutter code. Implementation happens via `/implement` after `/new-feature` produces a spec.

These are deliberate — the kit's job is to give you the harness, not to ship your app for you.

---

## Next steps

- [03-subagents.md](03-subagents.md) — understand what each subagent does
- [05-slash-commands.md](05-slash-commands.md) — full slash command reference
- [example/](../example/) — see what a populated workspace looks like after weeks of use

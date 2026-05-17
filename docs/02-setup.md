# 02 — Setup

This walks you from "I just cloned the kit" to "I just ran my first slash command in a real Flutter project."

Allow ~1-2 hours the first time. Most of that is creating a Google Play Developer account if you don't have one, and reading Play Console docs.

---

## Prerequisites

Before you start, you need:

### On your machine
- **Flutter SDK** installed and `flutter doctor` happy. Tested on Flutter stable 3.x.
- **Claude Code** installed and authenticated. https://docs.claude.com/en/docs/claude-code
- **git** + **gh** (GitHub CLI) configured. `gh auth status` should show you logged in.
- **Python 3.10+** (for some helper scripts).
- A code editor you like. VS Code or JetBrains both fine.

### Accounts
- **Anthropic account** with API access enabled. The kit runs entirely via Claude Code which uses your Anthropic credits.
- **Google Play Console developer account.** One-time USD 25 fee. Set up at https://play.google.com/console.
- **Firebase project** for your app (optional but assumed by most templates; you can skip Firebase-specific subagents if you don't use it).
- A keystore for signing your Android release builds. Instructions in [docs/06-deploying.md](06-deploying.md).

### Knowledge
- Comfort with: git, the command line, Markdown, YAML, basic Flutter project structure.
- You don't need: existing experience with multi-agent systems, custom Claude Code configuration, or Play Console API.

---

## Step 1. Clone the kit

```bash
git clone https://github.com/prash5t/claude-code-mobile-kit.git
cd claude-code-mobile-kit
```

Skim the top-level files (`README.md`, `METHODOLOGY.md`) so you know what to expect.

---

## Step 2. Choose your Flutter project

You can either:

**A) Use an existing Flutter app** — fine, just be aware that the kit assumes a specific folder layout. If your project deviates, you'll need to adapt template paths.

**B) Create a fresh Flutter project** — recommended for your first run, so you can verify the kit works before integrating with anything you care about.

```bash
flutter create my_first_kit_app
cd my_first_kit_app
```

---

## Step 3. Copy templates into the project

From inside your Flutter project root, run (adjust the path to where you cloned the kit):

```bash
KIT=~/path/to/claude-code-mobile-kit
cp "$KIT/templates/CLAUDE.md" ./CLAUDE.md
mkdir -p .claude
cp -r "$KIT/templates/agents" .claude/agents
cp -r "$KIT/templates/hooks" .claude/hooks
cp -r "$KIT/templates/slash-commands" .claude/slash-commands
mkdir -p docs/{spec,policy}
touch docs/learnings.md docs/analytics-events.md docs/release-history.md docs/store-listing.md
```

What you should now have inside your Flutter project:

```
your-flutter-app/
├── CLAUDE.md
├── .claude/
│   ├── agents/
│   ├── hooks/
│   └── slash-commands/
└── docs/
    ├── spec/
    ├── policy/
    ├── learnings.md           (empty, ready to grow)
    ├── analytics-events.md    (empty)
    ├── release-history.md     (empty)
    └── store-listing.md       (empty)
```

---

## Step 4. Customize `CLAUDE.md`

This is the most important file. Open it and fill in the placeholders for your app:

```markdown
# Project: <APP NAME>

## Identity
- Package ID: com.yourorg.yourapp
- Display name: My First Kit App
- Domain / niche: <e.g. utility / productivity / consumer>
- Monetization: <ads-only / ads + IAP / subscription / paid>
- Min SDK: 21 (Android 5.0)
- Target SDK: latest stable

## Tech stack
- Flutter: 3.x
- State management: <your choice — Bloc / Cubit / Provider / Riverpod>
- Backend: <Firebase / custom / none>
- Analytics: <Firebase Analytics / Mixpanel / none>
- Crash reporting: <Crashlytics / Sentry / none>
- Monetization SDKs: <AdMob / RevenueCat / etc.>

## Constraints
- Target launch region: <Worldwide / specific countries>
- Languages supported: <English only / l10n list>
- Accessibility level required: <basic / WCAG AA>

## Rules
1. Never commit secrets to git. Use .env files and add them to .gitignore.
2. Never push to main without running `flutter analyze` and `flutter test`.
3. <add your own>
```

The full template has more sections — go through them all once, fill in honestly. The architect, implementer, and compliance subagents all read this file at the start of every task.

---

## Step 5. Verify Claude Code sees the configuration

Inside your project, run:

```bash
claude
```

That should drop you into a Claude Code session. Test that the slash commands are loaded:

```
> /
```

You should see a list including `/scaffold-feature`, `/policy-sync`, `/publish`, etc. If you don't see those, check that you copied them into `.claude/slash-commands/` correctly.

Test a subagent invocation:

```
> Read the CLAUDE.md and tell me what app this is.
```

Claude should respond with details from your customized CLAUDE.md. If it doesn't, that's a setup issue worth debugging before going further.

---

## Step 6. Try the first slash command

The safest first slash command is `/policy-sync`. It reads your CLAUDE.md and generates `docs/policy/privacy-policy.md` and `docs/policy/terms.md` drafts based on your stated monetization model and SDK list.

```
> /policy-sync
```

Read the output. The drafts are **starting points**, not legally vetted documents. You'll need to:
- Read them carefully
- Adjust them for your real situation
- Have them reviewed by someone qualified if you're in a high-risk niche (children's apps, fintech, health, etc.)

Once you have policy docs, the `/publish` command will reference them when generating the Play Console listing.

---

## Step 7. Set up Play Console secrets (for deploy later)

Don't do this on day 1. Do it when you're actually ready to ship.

The deployer subagent uses the Google Play Developer API. You'll need:

1. A service account with Play Console access
2. A JSON key file for that service account
3. The key file referenced by an environment variable

Full instructions in [docs/06-deploying.md](06-deploying.md). For now, just be aware this is the gate between "can run kit locally" and "can actually submit to Google."

---

## Common setup issues

**"Claude Code doesn't see my slash commands."**
Check: are they at `.claude/slash-commands/` (with the leading dot)? Did you restart your Claude Code session after copying them in?

**"Subagent invocation seems to ignore CLAUDE.md."**
The CLAUDE.md must be at the root of the project Claude Code was invoked in. If you launched Claude Code from a parent directory, it might be reading a different CLAUDE.md (or none).

**"flutter analyze fails on a fresh template."**
The template uses some Flutter packages by default. Run `flutter pub get` first.

**"Hook scripts aren't firing."**
Hooks need execute permissions: `chmod +x .claude/hooks/*.sh`. Also check that your Claude Code version supports PostToolUse hooks (recent versions do).

---

## You're set up. What now?

Go to [03-subagents.md](03-subagents.md) to understand what each subagent does and when to invoke them. Or jump to [05-slash-commands.md](05-slash-commands.md) if you'd rather learn by running things.

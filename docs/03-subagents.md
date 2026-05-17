# 03 — Subagents

The kit ships seven role-specific subagents. Each owns one phase of the workflow and a narrow scope of files. This doc explains what each does, when it fires, and where its templates live.

For the underlying philosophy ("why many small subagents instead of one generalist"), see [METHODOLOGY.md](../METHODOLOGY.md#1-many-small-specialized-subagents--one-big-generalist).

---

## Cheat sheet

| Subagent | Owns | Reads | Writes | Fires when |
|---|---|---|---|---|
| **architect** | Idea refinement, spec writing | `CLAUDE.md`, `docs/learnings.md`, existing spec docs | `docs/spec/<feature>.md` | You type a brief into `/new-feature` |
| **implementer** | Flutter code | `docs/spec/`, `lib/`, `CLAUDE.md` | `lib/`, `test/` | `/implement <feature>` |
| **compliance-checker** | Play Store policy review | `lib/`, `pubspec.yaml`, `docs/policy/` | `docs/policy/`, `docs/learnings.md` | Hook fires on relevant code change, or `/compliance-check` explicit |
| **configurator** | Firebase / AdMob / SDK setup | `android/app/build.gradle`, `lib/main.dart`, `.env` | env configs, native config files | `/configure <integration>` |
| **asset-generator** | Icons, screenshots, store assets | `lib/` (for current screen shapes), `assets/`, `docs/store-listing.md` | `assets/`, `android/app/src/main/res/`, store listing files | `/refresh-assets` |
| **deployer** | Play Console submission | `pubspec.yaml`, build artifacts, `docs/release-history.md` | `pubspec.yaml` (version bump), Play Console API | `/publish <track>` |
| **maintainer** | Post-launch ops | Crashlytics/Sentry feeds (if configured), `docs/analytics-events.md`, `docs/learnings.md` | `docs/learnings.md`, fix proposals | `/check-health` or scheduled |

---

## architect

**Purpose:** turn vague user input into a precise spec the implementer can build from.

**Why it exists:** without this, the implementer has to guess. Guessing leads to scope creep and rework.

**Behavior:**
- Reads `CLAUDE.md` for app constraints (monetization model, target audience, tech stack)
- Reads `docs/learnings.md` for prior patterns ("last time we tried X, it failed because Y")
- Reads any existing `docs/spec/` to maintain consistency
- Produces `docs/spec/<feature>.md` with: goal, non-goals, user-facing changes, technical approach, data model changes, analytics events to emit, edge cases, and an estimated complexity rating
- Will ask clarifying questions if the brief is too vague — does not silently fill in assumptions

**Template:** `templates/agents/architect.md`

---

## implementer

**Purpose:** write the code described in the spec.

**Behavior:**
- Reads the approved spec
- Reads `CLAUDE.md` rules (e.g. "always run flutter analyze before commit")
- Implements in small commits when possible
- Writes tests for non-trivial logic if the project's testing convention is established in `CLAUDE.md`
- Runs `flutter analyze` and `flutter format` before finishing
- Does NOT decide architecture; the spec governs

**Scope limit:** doesn't touch `docs/`, `assets/`, or platform-specific config unless the spec explicitly asks. If a feature requires those, the spec should call them out and the implementer should delegate (e.g., suggest a follow-up `/configure` invocation).

**Template:** `templates/agents/implementer.md`

---

## compliance-checker

**Purpose:** catch Play Store policy issues before submission, not after rejection.

**Behavior:**
- On a `/compliance-check` invocation OR when a PostToolUse hook detects a relevant change (e.g. new permission added, new analytics event collecting PII, new SDK in pubspec.yaml)
- Reads the changed files
- Cross-references against a checklist of common Play policy hot-spots: permissions, data collection disclosure, ad placement rules, content rating, target SDK requirements, accessibility, restricted content
- Reads `docs/policy/` to check if those docs reflect the current code
- Reports findings to the user: 🟢 looks fine / 🟡 review needed / 🔴 will block submission
- Updates `docs/learnings.md` if it flags something the workflow should remember (e.g. "AdMob banner inside scrollable list triggered a policy notice last time; avoid")
- Optionally regenerates `docs/policy/privacy-policy.md` and related docs from current code state

**What it is NOT:** a substitute for actually reading Play Console policy. The checklist gets outdated as Google updates rules. Always sanity-check.

**Template:** `templates/agents/compliance-checker.md`

---

## configurator

**Purpose:** handle one-time integration setup work — Firebase, AdMob, analytics, etc.

**Behavior:**
- Invoked via `/configure firebase`, `/configure admob`, `/configure mixpanel`, etc.
- Reads what's already configured (build.gradle, GoogleService-Info.plist if iOS, main.dart, .env)
- Asks you for the missing pieces (API keys, project IDs) and adds them to `.env`
- Wires the SDK into main.dart and any necessary native config
- Updates `CLAUDE.md` to reflect the new integration
- Never commits secret values; only references env vars

**Template:** `templates/agents/configurator.md`

---

## asset-generator

**Purpose:** produce the visual assets the store listing needs.

**Behavior:**
- Generates app icon (1024×1024 source + Android/iOS variants) using whatever image-generation pipeline you've configured. The template supports plugging in DALL-E, SDXL, or just using a static icon you provide.
- Generates Play Store feature graphic (1024×500) per the same pipeline
- Captures or generates screenshots — can drive `flutter drive` or `integration_test` to take real screenshots from the running app, or compose them from designed templates
- Writes asset paths into `docs/store-listing.md` so the deployer subagent can find them

**Important:** the kit doesn't include an image generation backend. You wire in whichever you prefer. The template documents the interface but doesn't ship pre-configured.

**Template:** `templates/agents/asset-generator.md`

---

## deployer

**Purpose:** ship a build to Play Console.

**Behavior:**
- Bumps `pubspec.yaml` version (semantic — major/minor/patch based on `/publish` argument)
- Builds an AAB (Android App Bundle): `flutter build appbundle --release`
- Authenticates to Play Console with the configured service account
- Uploads the AAB to the Internal testing track by default
- Drafts release notes by reading commit messages or `docs/spec/` changes since the last release
- Appends an entry to `docs/release-history.md`
- Does NOT auto-promote to Production — that's a separate explicit step (`/promote internal-to-production`)

**Template:** `templates/agents/deployer.md`

---

## maintainer

**Purpose:** keep the workspace coherent and the app healthy after launch.

**Behavior:**
- Reads Crashlytics / Sentry feeds (if you've configured them) and summarizes new issues
- Cross-checks `docs/analytics-events.md` against actual `logEvent(...)` calls in the code; flags drift
- Checks if any policy hot-spots have changed since last `compliance-check`
- Suggests version bumps if there are bug fixes pending
- Appends interesting findings to `docs/learnings.md`

Invoke via `/check-health` weekly, or wire it into a cron via `tools/scripts/scheduled-health-check.sh` (if you want true automation).

**Template:** `templates/agents/maintainer.md`

---

## How a subagent is defined (template structure)

Each agent template is a Markdown file with three parts:

```markdown
---
name: architect
description: Refines vague app/feature ideas into precise specs the implementer can build from.
model: <small | medium | large>   # cost/speed tradeoff — most subagents are fine on the small model
---

# System prompt

<the persistent instructions that make this subagent specialized>

# Tools allowed

<a constrained list of tools this subagent can use — typically file read/write within a scope>

# Termination criteria

<what "done" looks like for this subagent's task>
```

Look at `templates/agents/architect.md` for a full filled-in example.

---

## Extending: writing your own subagent

If you find yourself doing the same multi-step thing repeatedly and it doesn't fit one of the existing subagents, that's a signal to write a new one. Steps:

1. Define the role in one sentence. If you can't, it's too broad — narrow it.
2. List its inputs (files / state it reads) and outputs (files / state it writes).
3. Copy `templates/agents/architect.md` as a starting point.
4. Write its system prompt with: role, principles, tools allowed, termination criteria.
5. Add a slash command in `.claude/slash-commands/` that invokes it.
6. Add an entry in your own version of this doc so future-you (or collaborators) remember why it exists.

---

## When to NOT create a subagent

- One-off tasks: just use the main Claude Code session, no need for a subagent
- Things that benefit from full-conversation context (refactoring across many files, debugging mysterious bugs): the main session has more context than a subagent fork
- Anything where you'd manually validate the output anyway every time: the subagent's value is in autonomy; if you're going to babysit it, just do it yourself

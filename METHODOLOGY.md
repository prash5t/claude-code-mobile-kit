# Methodology

The thinking behind this kit. Read this before adopting the templates — the templates make a lot more sense once you understand the principles.

---

## The premise

A single indie developer can ship and maintain multiple Flutter apps to the Google Play Store, **without dropping ball on compliance, analytics, asset quality, or release cadence**, if they delegate the boring-but-essential lifecycle work to a fleet of specialized agents instead of doing it by hand.

This isn't about Claude writing your code for you. It's about Claude **running your boring stuff** so you can focus on the parts that actually require your judgment: what to build, how to position it, what to drop.

---

## Three principles that shape every part of the kit

### 1. Many small specialized subagents > one big generalist

Generalist agents have to context-switch on every step. Specialized subagents do one thing and do it well.

Concretely, this kit defines roles like:

- **Architect** — refines a rough idea into a spec
- **Implementer** — writes the actual Flutter code
- **Compliance-checker** — audits a feature or release against Play Store policies
- **Configurator** — wires Firebase, analytics, AdMob, etc.
- **Asset-generator** — produces icon, feature graphic, screenshots
- **Deployer** — handles Play Console submission (Internal → Closed → Production tracks)
- **Maintainer** — periodic post-launch tasks (analytics catalog sync, policy regeneration, version bumps, crash triage)

Each subagent has a focused system prompt and a narrow scope of files/tools it touches. Specialization reduces context drift and lets each subagent be tuned cheaply with the smaller model when appropriate.

### 2. Make state durable, then orchestrate over it

Agents are stateless. You are not. The kit puts every important fact about your app into Markdown files that both you and the agents can read:

- `CLAUDE.md` — the master file: app identity, monetization model, tech stack, constraints
- `docs/spec/*.md` — feature specs once the architect finalizes them
- `docs/learnings.md` — accumulated lessons (rejected by Play Store last time? Why? Don't repeat.)
- `docs/analytics-events.md` — canonical list of analytics events the app emits
- `docs/release-history.md` — version history with what shipped in each

Subagents read these at the start of every task and write to them at the end. Sessions can die, machines can be swapped, weeks can pass — the next session picks up where the last left off because the state is in files, not in an LLM's head.

### 3. Hooks keep the workspace coherent

Files drift. Code changes a Firebase event name; the analytics catalog doc doesn't get updated; six weeks later a question about that event takes 20 minutes to resolve.

The kit uses Claude Code's `PostToolUse` hooks to attach small "after-the-fact" jobs to file edits:

- After editing a file containing `analytics.logEvent(...)` calls → re-sync the analytics catalog doc
- After bumping `pubspec.yaml` version → append to release history
- After editing privacy-affecting code → flag for policy page regen
- After adding a new asset to `assets/` → check it's listed in `pubspec.yaml` AND in the Play Console listing

These run silently. They keep the human-facing state coherent without needing the developer to remember.

---

## When this pattern works

- You're a solo dev or 2-3 person indie team
- You ship multiple small-to-medium apps (not one huge app)
- The apps share patterns (same auth, same monetization shape, same analytics conventions)
- You're willing to spend 1-2 weeks setting up the kit for your first app — the second app is fast, the third is faster
- You're already comfortable with Flutter + Claude Code + git
- You're OK with the API costs (~$5-30/app/cycle, see README caveats)

## When this pattern doesn't work

- **Single-app shipping with no plans for more.** Setup cost dominates if you're only shipping one thing. Just use Claude Code without all this scaffolding.
- **Massive monorepo with many engineers.** The pattern scales horizontally across many small apps, not vertically into one large codebase with many contributors. For team-scale, see frameworks built for that.
- **Strict regulatory environments.** Healthcare, finance, defense — the compliance subagent's "best-effort policy match" approach isn't appropriate. Get human compliance review.
- **You hate reading docs / writing markdown.** The whole kit is text-driven. If that feels like overhead instead of leverage, it'll feel like overhead the entire time you use it.
- **You're allergic to LLM costs.** API tokens cost money. If your indie app revenue is $0 and your Claude budget is $0, this is the wrong order of operations — make some revenue first, then invest in tooling.

---

## What this kit deliberately is NOT

- **An installable framework.** No `pip install`, no `flutter pub global activate`. Templates are copy-paste because that's honest — you'll customize half of them anyway.
- **A scaffolder CLI.** I considered it. Decided against. A `kit init` command would hide the structure that you actually need to understand to debug your own setup.
- **A general agentic dev framework.** This is mobile-and-Play-Store specific. The patterns generalize but the templates don't. Don't try to use this for web SaaS — you'll fight the templates.
- **Anthropic-neutral.** Claude Code is the assumed runtime. You can adapt the patterns to other agent runtimes (Aider, Cursor, Continue) but it'll be real work. The kit doesn't pretend otherwise.

---

## How the self-improving angle actually works (sober version)

"Self-improving" sounds magical. In practice it's three boring patterns:

1. **The learnings file.** A single `docs/learnings.md` that subagents read at the start of every task and append to when they finish. Mistakes don't get repeated because they're in the file the next agent reads.

2. **PostToolUse hooks that capture context.** When an agent does something significant — submits a feature for Play review, fixes a crash, refactors a flow — a hook captures the before/after delta into the learnings file. No human action needed.

3. **Stable file structure across apps.** Because all your apps follow the same kit layout, an agent working on app B can read learnings from app A. Cross-app pattern transfer is just a `grep` away.

That's it. No reinforcement learning, no model fine-tuning, no agent self-modification. Just disciplined state management across sessions. The "self-improving" label is honest because the workflow's behavior measurably gets better over weeks of use — but the mechanism is plumbing, not magic.

See [docs/08-self-improving.md](docs/08-self-improving.md) for the implementation.

---

## What you'll actually need to invest

To get value out of this kit:

- **Read time:** ~2 hours through README + METHODOLOGY + the 8 docs
- **Setup time per first app:** ~1-2 weekend afternoons (8-12 hours)
- **Setup time per subsequent app:** ~1-2 hours (you've already customized the templates once)
- **Ongoing per-cycle cost:** ~$5-30 in Claude API usage per major release of an app
- **Cognitive overhead:** non-zero. You have to understand the subagent topology to debug it when something goes wrong. The kit doesn't hide this from you.

If that investment doesn't match your goals, this isn't your tool — and that's fine. Better to know up front.

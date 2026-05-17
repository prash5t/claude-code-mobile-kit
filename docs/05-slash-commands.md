# 05 — Slash commands

Slash commands are how you (the human) drive the workflow. Each one wraps a multi-step flow that would otherwise need typing out a long instruction. This doc lists the commands the kit ships and explains how to write your own.

---

## What the kit ships

| Command | Purpose | Subagent invoked |
|---|---|---|
| `/new-feature <brief>` | Take a rough idea, refine into a spec | architect |
| `/implement <spec-name>` | Build from an approved spec | implementer |
| `/compliance-check` | Run a Play policy audit on current state | compliance-checker |
| `/configure <integration>` | Wire a third-party SDK (firebase, admob, mixpanel, etc.) | configurator |
| `/refresh-assets` | Regenerate icon, feature graphic, screenshots | asset-generator |
| `/publish <track>` | Bump version, build AAB, upload to Play Console | deployer |
| `/promote <from>-to-<to>` | Move a release through tracks (internal → closed → production) | deployer |
| `/check-health` | Run weekly post-launch audit | maintainer |
| `/policy-sync` | Regenerate privacy policy and terms from current code | compliance-checker |
| `/sync-analytics-doc` | Manually trigger the analytics catalog refresh (normally a hook) | (no subagent — direct) |

---

## Command definition structure

A slash command in Claude Code is a Markdown file in `.claude/slash-commands/`. The pattern the kit uses:

```markdown
---
name: new-feature
description: Refine a vague feature brief into a precise spec, written to docs/spec/<name>.md.
arguments:
  - name: brief
    description: A short description of what you want
    required: true
---

You are invoking the **architect** subagent to refine a feature brief.

## Steps

1. Read `CLAUDE.md` and `docs/learnings.md`.
2. Read any existing files in `docs/spec/` to maintain consistency.
3. Take the user's brief: `{{brief}}`
4. Ask clarifying questions if the brief is too vague. Stop and wait for the user's answers.
5. Once you have enough information, produce `docs/spec/<derived-name>.md` with:
   - Goal (one sentence)
   - Non-goals
   - User-facing changes
   - Technical approach
   - Data model changes
   - Analytics events to emit
   - Edge cases
   - Estimated complexity (S / M / L)
6. Append a one-line entry to `docs/learnings.md` recording what was specced.
7. Report back to the user with a link to the new spec doc and ask if they want to proceed to implementation.

## Rules

- Never invent assumptions silently. Ask.
- Don't write Flutter code in this command. That's the implementer's job.
- Keep the spec under 500 words. Long specs are unread specs.
```

Look at the template files for full filled-in examples.

---

## How to invoke commands

From a Claude Code session inside your project:

```
> /new-feature add a daily-streak widget to the home screen
```

Claude reads the slash command definition, then follows its instructions with the argument filled in. The subagent invocation, file reads/writes, and follow-up questions all flow from the command's "Steps" section.

---

## Composing commands

It's tempting to chain `/new-feature` → `/implement` → `/publish` into one mega-command. Resist.

Each command should have **exactly one decision point** for you: do I approve what this just produced, or do I want to change something? A mega-command that does idea → ship in one shot removes your judgment from the loop and produces things you regret.

The kit's commands are deliberately sized so that:
- Each one finishes in 1-15 minutes
- You see a clear deliverable before the next one fires
- Mistakes are caught early (cheap to fix at spec stage; expensive after deploy)

---

## Writing your own slash command

Start by asking: **is this a slash command, or is it a hook?**

- Slash command: you initiate it deliberately. It might require your judgment to complete.
- Hook: triggered by something the agent already does. Runs silently. No judgment.

If slash command, then:

1. Copy `templates/slash-commands/new-feature.md` as a starting point.
2. Change `name`, `description`, `arguments`.
3. Rewrite the "Steps" section to describe what you want done.
4. Add clear "Rules" — what the agent must not do during this command. (Slash commands without rules sprawl.)
5. Save to `.claude/slash-commands/<your-name>.md`.
6. Restart your Claude Code session (or some versions auto-reload).
7. Test it on a low-risk task before trusting it on something important.

---

## Anti-patterns

**Do-everything commands.** "/ship-the-app" that takes an idea and produces a Play Store listing. Too much surface area, too many failure modes, you'll regret it.

**Commands that hide what they're doing.** Each step in the "Steps" section should be readable enough that you can predict the outcome before invoking.

**Commands with too many optional arguments.** If a command needs 6 flags to be useful, it's actually 6 different commands.

**Commands that don't update `docs/learnings.md`.** If something interesting happens during the command's run, capture it. Otherwise the workflow doesn't learn.

---

## Files in this kit

- `templates/slash-commands/new-feature.md`
- `templates/slash-commands/implement.md`
- `templates/slash-commands/compliance-check.md`
- `templates/slash-commands/configure.md`
- `templates/slash-commands/refresh-assets.md`
- `templates/slash-commands/publish.md`
- `templates/slash-commands/promote.md`
- `templates/slash-commands/check-health.md`
- `templates/slash-commands/policy-sync.md`

All sit at < 100 lines each. They're meant to be read in full when you adopt them.

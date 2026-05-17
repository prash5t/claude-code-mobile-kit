---
name: new-feature
description: Refine a vague feature brief into a precise spec, written to docs/spec/<slug>.md.
arguments:
  - name: brief
    description: A short description of what you want
    required: true
---

Invoke the **architect** subagent (`.claude/agents/architect.md`) to refine the following brief into a feature spec.

## Steps

1. Read `CLAUDE.md` and `docs/learnings.md`.
2. Read every existing file in `docs/spec/` to maintain consistency.
3. Take the user's brief: `{{brief}}`
4. If the brief is too vague to produce a precise spec, ask 1-3 specific clarifying questions and wait for answers. Do not silently invent assumptions.
5. Once you have enough information, write `docs/spec/<derived-slug>.md` following the architect template's output format.
6. Append a one-line entry to `docs/learnings.md` under a `## YYYY-MM-DD — Architect: <feature name>` header recording any non-obvious decisions made.
7. Report back with: link to the new spec, complexity estimate (S / M / L), any open questions remaining, suggested next command (`/implement <slug>`).

## Rules

- This command produces a spec only. Do not write Flutter code.
- Keep the spec under 500 words.
- If the brief is trivial (typo, color tweak, single-line fix), say "this doesn't need a spec; recommend doing it directly" and stop.
- If the brief should be split into multiple features, say so and propose the split before writing anything.

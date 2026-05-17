---
name: implement
description: Implement an approved spec by writing Flutter code.
arguments:
  - name: spec
    description: The spec slug (filename without .md) under docs/spec/
    required: true
---

Invoke the **implementer** subagent (`.claude/agents/implementer.md`) to build from an approved spec.

## Steps

1. Read `docs/spec/{{spec}}.md` in full. If status is not `approved`, ask the user to approve first (or update the spec).
2. Read `CLAUDE.md` for project conventions.
3. Read `docs/learnings.md` for anti-patterns to avoid in this domain.
4. Implement in small commits. After each commit, run `flutter analyze` and `flutter format`.
5. Write tests for non-trivial logic, matching the project's testing conventions.
6. Run `flutter test` before finishing.
7. Update the spec's status to `in-progress` while working, then `shipped` once committed and analyze-clean.
8. Report back per the implementer's output format.

## Rules

- Stay within the spec's scope. Note out-of-scope opportunities; don't do them.
- Don't bump version. That's `/publish`.
- Don't touch `docs/`, `.claude/`, or native config unless the spec explicitly requires it.
- If the spec is ambiguous mid-implementation: stop, ask, don't improvise.

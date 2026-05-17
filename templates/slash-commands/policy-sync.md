---
name: policy-sync
description: Regenerate privacy policy and terms of use from current code state. Drafts are starting points; review carefully.
---

Invoke the **compliance-checker** subagent (`.claude/agents/compliance-checker.md`) to regenerate policy docs.

## Steps

1. Read `CLAUDE.md` for monetization model, SDKs in use, and data collection scope.
2. Scan `lib/` for analytics calls, identifier collection, sensitive permission usage.
3. Scan `pubspec.yaml` for SDKs that have privacy implications (ads, analytics, crash reporting, social SDKs).
4. Scan `AndroidManifest.xml` for declared permissions.
5. Generate `docs/policy/privacy-policy.md` reflecting current state, including:
   - What data is collected
   - Why each data type is collected
   - Who it's shared with (third-party SDK list)
   - User rights (access, deletion)
   - Contact for privacy requests
   - Effective date
6. Generate `docs/policy/terms.md` with standard sections adapted for the app's monetization model.
7. Report the generated docs and remind the user:
   - These drafts are NOT legally vetted
   - Review carefully before publishing
   - For high-risk niches (children's apps, health, fintech), get legal review
   - The Play Console "Data safety" form must be kept in sync separately

## Rules

- Never claim the generated docs are legal advice or compliant by default.
- Be explicit about data types: name each one rather than using vague "we collect usage data" language.
- Match the disclosed data to the actual code state. Don't over-disclose (annoys users) or under-disclose (Play violation).

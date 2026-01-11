# Feature Index

This directory contains the specifications for all features in the Holy application.

## Features

| ID | Feature Name | Status | Documentation |
|----|--------------|--------|---------------|
| 001 | Download Progress Indicator | Draft | [spec.md](./001-download-progress/spec.md) |
| 002 | Firebase Distribution in GitHub Actions | Draft | [spec.md](./002-firebase-dist-gh-actions/spec.md) |
| 003 | Advanced Multiple Search Joins | Draft | [spec.md](./003-multiple-search-joins/spec.md) |
| 004 | Verse Comparison | Draft | [spec.md](./004-verse-comparison/spec.md) |
| 005 | Verse Search | Draft | [spec.md](./005-verse-search/spec.md) |
| 006 | Search State Persistence | Draft | [spec.md](./006-search-state-persistence/spec.md) |
| 007 | Download Loader | Unknown | [spec.md](./007-download-loader/spec.md) |
| 008 | User Profile Screen | Draft | [spec.md](./008-user-profile/spec.md) |
| 009 | Feature Documentation Support | Completed | [spec.md](./009-feature-documentation-support/spec.md) |
| 010 | User Documentation | Completed | [spec.md](./010-user-documentation/spec.md) |
| 011 | Bottom Navigation Bar | Unknown | [spec.md](./011-bottom-navigation-bar/spec.md) |
| 012 | Lazy Load Database | Completed | [spec.md](./012-lazy-load-database/spec.md) |
| 013 | Premium Search Filters | Draft | [spec.md](./013-premium-search-filters/spec.md) |
| 014 | User Feedback Loop | Draft | [spec.md](./014-user-feedback/spec.md) |
| 015 | Verse of the Day | Draft | [spec.md](./015-verse-of-the-day/spec.md) |
| 016 | Firebase APK Distribution | Draft | [spec.md](./016-firebase-apk-distribution/spec.md) |
| 017 | Bible SQLite Cache | Draft | [spec.md](./017-bible-sqlite-cache/spec.md) |
| 018 | GitHub Actions CI/CD Pipeline | Draft | [spec.md](./018-github-actions-cicd/spec.md) |
| 019 | Bible Reading Sync | Draft | [spec.md](./019-bible-reading-sync/spec.md) |
| 020 | Rich Verse Action Modal & Image Creator | Clarified | [spec.md](./020-rich-verse-modal/spec.md) |

### Assigning New Feature IDs

- Review the table above to identify the highest assigned ID (currently 020).
- Use the next sequential three-digit ID when adding a new specification directory.
- Update this index (table and guidance) immediately after creating or renaming a spec to keep numbering authoritative.
- Before scaffolding new docs, confirm no pending renames exist in open branches or PRs that could affect numbering.
- Agents MUST consult this index before generating new specs to avoid duplicate or skipped numbers.

## Documentation Template

All new features must follow the [spec-template.md](../.specify/templates/spec-template.md).

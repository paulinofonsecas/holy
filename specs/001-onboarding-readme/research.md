# Research: Onboarding Process & Dependencies

## Decision: Documentation Structure
**Decision**: Root README for Quick Start + `doc/SETUP_GUIDE.md` for deep dives.
**Rationale**: Keeps the main entry point clean while providing all necessary details for different OS environments.
**Alternatives considered**: All-in-one README (too long), README + Platform-specific files (too fragmented).

## Findings: Bible Server (FR-004)
**Decision**: Treat Bible Server as an optional/external dependency.
**Rationale**: The `bible_server` code is not in the monorepo and references absolute paths on a specific user's desktop. The Flutter app should probably have a fallback or the server should be cloned from a known URL (to be clarified).
**Action**: Add a "Bible Server (Optional)" section to the guide.

## Findings: Monorepo Management (FR-002)
**Decision**: Use `flutter pub get` in root and `pub get` in packages.
**Rationale**: Standard Flutter monorepo practice.
**Action**: Include a "Monorepo Setup" section.

## Findings: Windows SQLite (Edge Case)
**Decision**: Document `sqlite3.dll` requirement.
**Rationale**: Windows doesn't always have `sqlite3` installed. The presence of `sqlite3.dll` in `bible_handler` suggests it might need to be in the executable path or project root.
**Action**: Add Windows-specific troubleshooting for SQLite.

## Research Task: bible_handler initialization
**Finding**: Initialization is standard. `bible_handler` is a local path dependency in `pubspec.yaml`.
**Action**: Instruct developers to run `flutter pub get` in both root and `packages/bible_handler` during first setup.

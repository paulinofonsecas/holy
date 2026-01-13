# Implementation Plan: Web Support for Holy App

**Branch**: `001-web-support` | **Date**: 2026-01-11 | **Spec**: [specs/001-web-support/spec.md](spec.md)
**Input**: Feature specification from `specs/001-web-support/spec.md`

## Summary

Enable the Holy App to run on Web platforms (Desktop and Mobile browsers). The strategy relies on **Option B: Embedded Local Database**, where Bible data is bundled as internal assets and persisted in the browser's IndexedDB using `sqflite_common_ffi_web`. The UI will be responsive, switching to a `NavigationRail` or `Permanent Drawer` on larger screens.

## Technical Context

**Language/Version**: Dart 3.6+ / Flutter (Web)  
**Primary Dependencies**: `flutter_bloc`, `firebase_core_web`, `sqflite_common_ffi_web`, `sqlite3` (wasm), `url_launcher`  
**Storage**: SQLite persisted via IndexedDB (browser)
**Testing**: `flutter test --platform chrome`, `flutter analyze`
**Target Platform**: Web (Chrome, Firefox, Safari, Edge)
**Project Type**: Flutter Mobile App expanded to Web Support
**Performance Goals**: <5s LCP, 60fps scrolling, instant search results after DB load.
**Constraints**: Offline-capable (PWA), limited use of mobile-only plugins.
**Scale/Scope**: Responsive UI for resolutions from 360px to 2560px.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Impact/Adherence |
| :--- | :--- |
| **I. Monorepo & Modularization** | Ensure `bible_handler` tests pass on web via `flutter test --platform chrome`. |
| **II. Bible Version Abstraction** | No change; `bible_handler` remains the source of truth. |
| **III. AI-Ready Architecture** | Data models must remain platform-agnostic for future semantic search. |
| **IV. Flutter Best Practices** | Use `LayoutBuilder` or `ResponsiveValue` for navigation switching. |
| **V. Test-Driven Development** | MUST write unit tests for the web database initialization logic. |
| **VI. Consistent Navigation** | **ADAPTATION REQD**: Navigation MUST be consistent but accessible via high-level drawer/rail on desktop. |

## Project Structure

### Documentation (this feature)

```text
specs/001-web-support/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── checklists/
│   └── requirements.md  # Specification quality check
└── contracts/           # Phase 1 output
```

### Source Code (repository root)

```text
lib/
├── main.dart            # Web-conditional initialization
├── core/
│   └── services/        # Platform-specific service fallbacks
└── features/
    └── search/          # Web search optimizations

packages/
└── bible_handler/
    └── lib/src/         # Web-compatible SQLite provider
```

## Phase 0: Outline & Research

### Research Tasks
- [ ] **IndexedDB Search Performance**: Validate if FTS5 (Full Text Search) performance in `sqlite3_wasm` is acceptable for large Bible databases.
- [ ] **Bundle Size Optimization**: Research ways to minimize the initial WASM/JS/SQLite file download size.
- [ ] **Firebase Web Setup**: Find best practices for secure Firebase config on public web apps.

## Phase 1: Design & Contracts

### 1. Data Model Enhancement (`data-model.md`)
- Define `WebDatabaseStatus`: {loading, downloading, ready, error, progress}.
- Define `ResponsiveLayoutState`: {mobile, desktop}.

### 2. API/Contract Updates (`contracts/`)
- `DatabaseLoaderInterface`: Method `initialize(String assetPath)` with progress callbacks.

## Phase 2: Implementation Roadmap

### Setup & Core Infrastructure (Priority: P1)
- [ ] **T001**: Add `sqflite_common_ffi_web` and web-wasm dependencies to `pubspec.yaml`.
- [ ] **T002**: Implement `WebSqliteProvider` in `bible_handler` using `databaseFactoryFfiWeb`.
- [ ] **T003**: Create a `SplashLoader` screen that shows database download progress.
- [ ] **T004**: Configure Firebase Web (API keys, project setup).

### Responsive UI & Navigation (Priority: P2)
- [ ] **T005**: Refactor `MainScreen` to use `NavigationRail` for `constraints.maxWidth > 900`.
- [ ] **T006**: Add responsive padding/max-width to Bible text readers.
- [ ] **T007**: Implement web fallbacks for `gal` (save image) and `share_plus`.

### Validation & Quality (Priority: P3)
- [ ] **T008**: Run `flutter analyze` and fix platform-specific warnings.
- [ ] **T009**: Write integration test: "Search should work after Web DB init".
- [ ] **T010**: Deploy to Firebase Hosting for UAT.

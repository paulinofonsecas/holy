# Tasks: Onboarding README for Windows and macOS

**Input**: Design documents from /specs/001-onboarding-readme/
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Tests**: No automated tests requested for this documentation feature. Validation will be manual walkthroughs.

**Organization**: Tasks are grouped by environment (Windows, macOS) and build processes to allow parallel development of documentation sections.

## Format: [ID] [P?] [Story] Description

- **[P]**: Can run in parallel (different files/sections, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Initialize documentation structure and project root templates
- [X] T002 Create .env.example in repository root with required keys (API_BASE_URL, FIREBASE_OPTIONS)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core documentation infrastructure

- [X] T003 [P] Create doc/ directory if missing and initialize doc/SETUP_GUIDE.md
- [X] T004 [P] Define global prerequisites (Flutter ^3.6.0, Git) in doc/SETUP_GUIDE.md

**Checkpoint**: Foundation ready - Environment-specific documentation can now begin in parallel

---

## Phase 3: User Story 1 - Windows Development (Priority: P1)

**Goal**: Complete step-by-step guide for Windows setup.

**Independent Test**: A fresh Windows user can follow the guide to run the app on Windows Desktop or Android Emulator.

### Implementation for User Story 1

- [X] T005 [P] [US1] Document Windows prerequisites (Visual Studio 2022 with C++, Android Studio) in doc/SETUP_GUIDE.md
- [X] T006 [US1] Add Windows-specific Monorepo setup steps (path resolution for ible_handler) in doc/SETUP_GUIDE.md
- [X] T007 [US1] Document Windows-specific troubleshooting (missing SQLite DLLs, SDK paths) in doc/SETUP_GUIDE.md

**Checkpoint**: Windows onboarding is functional and testable.

---

## Phase 4: User Story 2 - macOS Development (Priority: P1)

**Goal**: Complete step-by-step guide for macOS setup.

**Independent Test**: A fresh macOS user can follow the guide to run the app on iOS Simulator or macOS Desktop.

### Implementation for User Story 2

- [X] T008 [P] [US2] Document macOS prerequisites (Xcode, CocoaPods, Android Studio) in doc/SETUP_GUIDE.md
- [X] T009 [US2] Add macOS-specific dependency resolution steps (pod install) in doc/SETUP_GUIDE.md
- [X] T010 [US2] Document macOS-specific troubleshooting (Xcode permissions, CocoaPods conflicts) in doc/SETUP_GUIDE.md

**Checkpoint**: macOS onboarding is functional and testable.

---

## Phase 5: User Story 3 - Building for Production (Priority: P2)

**Goal**: Clear instructions for generating release artifacts.

**Independent Test**: Running the documented commands produces a valid release APK/AAB or Desktop binary.

### Implementation for User Story 3

- [X] T011 [P] [US3] Document Android release build commands and signing prerequisites in doc/SETUP_GUIDE.md
- [X] T012 [P] [US3] Document Desktop (Windows/macOS) release build commands in doc/SETUP_GUIDE.md
- [X] T013 [US3] Document Makefile usage for automation (make build, make test, make distribute) in doc/SETUP_GUIDE.md

**Checkpoint**: All build processes are documented.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Root README update and final integration.

- [X] T014 Update root README.md with High-level Quick Start (3-step) and cross-links to detailed guides
- [X] T015 [P] Add "Architecture Overview" and "Monorepo Structure" sections to root README.md
- [X] T016 [P] Add "Firebase Distribution" summary link (pointing to doc/firebase-distribution-guide.md) in README.md
- [X] T017 Final proofread and link validation (ensuring all markdown links point to existing files)

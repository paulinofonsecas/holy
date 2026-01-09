# Tasks: Firebase Distribution in GitHub Actions (001-firebase-dist-gh-actions)

**Input**: Design documents from `specs/001-firebase-dist-gh-actions/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create GitHub Actions workflow file `.github/workflows/firebase-distribution.yml`
- [x] T002 [P] Update `scripts/distribute-apk.sh` to support AAB files and custom release notes
- [x] T003 [P] Verify development environment (Flutter version compatibility in workflow)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure for build and auth

- [x] T004 Implement Android signing logic in the workflow (secret decoding)
- [x] T005 [P] Setup dependency caching (`actions/cache`) for faster Flutter builds
- [x] T006 [P] Configure Firebase CLI installation and authentication step

**Checkpoint**: Foundation ready - build and auth steps are scaffolded

---

## Phase 3: User Story 1 - Automated Distribution on Main/Develop (Priority: P1) 🎯 MVP

**Goal**: Automatically build and distribute AAB when code is pushed to `main` or `develop`

**Independent Test**: Push a test commit to `develop` and verify Firebase App Distribution receives a new build.

### Implementation for User Story 1

- [x] T007 [US1] Define `push` triggers for `main` and `develop` in workflow
- [x] T008 [US1] Implement `flutter build appbundle --release` step
- [x] T009 [US1] Integrate `scripts/distribute-apk.sh` (renamed or adapted for AAB) into the workflow
- [x] T010 [US1] Add build success/failure summaries to GitHub Actions output

**Checkpoint**: Automated distribution for core branches is functional

---

## Phase 4: User Story 2 - Manual Distribution (Priority: P2)

**Goal**: Trigger distribution for any branch via `workflow_dispatch`

**Independent Test**: Manually run the workflow from the Actions tab and verify distribution.

### Implementation for User Story 2

- [x] T011 [US2] Add `workflow_dispatch` trigger with inputs for `release_notes` and `groups`
- [x] T012 [US2] Map manual inputs to the distribution script parameters
- [x] T013 [US2] Add branch selection logic for manual runs

**Checkpoint**: Developers can now manually push any branch to testers

---

## Phase 5: User Story 3 - Release Notes Integration (Priority: P3)

**Goal**: Automatically extract commit messages for Firebase release notes

**Independent Test**: Verify that the "Release Notes" in Firebase contains the latest commit messages.

### Implementation for User Story 3

- [x] T014 [US3] Add a step to extract git log (last 10 commits) as fallback notes
- [x] T015 [US3] Ensure release notes are escaped properly for Firebase CLI
- [x] T016 [US3] Test the release notes flow with multiple commits

---

## Phase 6: Polish and Validation

**Purpose**: Final cleanup and verification

- [x] T017 [P] Clean up temporary files (keystore) after build finishes
- [x] T018 [P] Update [docs/SPECIFICATION_GUIDE.md](docs/SPECIFICATION_GUIDE.md) if infrastructure patterns changed
- [x] T019 Final end-to-end verification of all triggers

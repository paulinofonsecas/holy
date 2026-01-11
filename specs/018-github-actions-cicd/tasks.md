---

description: "Task list for GitHub Actions CI/CD Pipeline implementation"
---

# Tasks: GitHub Actions CI/CD Pipeline

**Input**: Design documents from `specs/018-github-actions-cicd/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create GitHub Actions workflow directory in `.github/workflows/`
- [x] T002 [P] Configure GitHub Secrets for Android signing (if applicable) and other sensitive data

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

** CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Create a base Flutter CI action or script to handle multi-package testing in monorepo (Windows/PowerShell)
- [x] T004 [P] Setup environment configuration for CI (e.g., Flutter version, Java version, Windows runner)

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Automated QA on Pull Requests (Priority: P1)  MVP

**Goal**: Automatically run linting and unit tests on every Pull Request to ensure code quality.

**Independent Test**: Create a PR with a failing test and verify the workflow fails. Fix it and verify it passes.

### Implementation for User Story 1

- [x] T005 [P] [US1] Create `.github/workflows/pr-checks.yml` with triggers for `pull_request` to `main`
- [x] T006 [US1] Add step to install Flutter and dependencies in `pr-checks.yml`
- [x] T007 [US1] Add step to run `flutter analyze` across all packages in `pr-checks.yml`
- [x] T008 [US1] Add step to run `flutter test` across all packages in `pr-checks.yml`

**Checkpoint**: User Story 1 functional - PRs are automatically checked for quality.

---

## Phase 4: User Story 2 - Automated Build Generation on Merge (Priority: P2)

**Goal**: Automatically build Android binaries (APK/AAB) when code is merged into the main branch.

**Independent Test**: Merge a PR to main and verify that an Android build artifact is produced and downloadable.

### Implementation for User Story 2

- [x] T009 [P] [US2] Create `.github/workflows/release.yml` with triggers for `push` to `main`
- [x] T010 [US2] Add build job to `release.yml` to compile Android APK
- [x] T011 [US2] Add build job to `release.yml` to compile Android App Bundle (AAB)
- [x] T012 [US2] Add step to upload build artifacts to GitHub Actions in `release.yml` (Unsigned)

**Checkpoint**: User Story 2 functional - merges to main produce downloadable Android builds.

---

## Phase 5: User Story 3 - Automated Release Management (Priority: P3)

**Goal**: Automatically create a GitHub Release with attached binaries when a version tag is pushed.

**Independent Test**: Push a tag like `v1.0.0` and verify a GitHub Release is created with the APK/AAB attached.

### Implementation for User Story 3

- [x] T013 [P] [US3] Update `release.yml` to trigger on tag patterns (e.g., `v*`)
- [x] T014 [US3] Add step to `release.yml` to create a GitHub Release using a standard action (e.g., `softprops/action-gh-release`)
- [x] T015 [US3] Add step to `release.yml` to attach the compiled APK/AAB to the GitHub Release

**Checkpoint**: User Story 3 functional - version tags automatically trigger official GitHub Releases.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final refinements and verification

- [x] T016 Optimize workflow execution time (e.g., using caching for pub dependencies)
- [x] T017 Verify that all secrets are correctly masked in logs
- [x] T018 Document the CI/CD pipeline in the project's README or a dedicated DOC file

## Dependency Graph

`mermaid
graph TD
    T001 --> T005
    T001 --> T009
    T003 --> T007
    T003 --> T008
    T005 --> T006
    T006 --> T007
    T007 --> T008
    T009 --> T010
    T010 --> T011
    T011 --> T012
    T012 --> T013
    T013 --> T014
    T014 --> T015
`

## Parallel Execution Opportunities

- **Setup & Foundation**: T001, T002, and T004 can be done in parallel.
- **Workflows**: The PR checks workflow (US1) and the Release workflow (US2/US3) can be developed independently once the foundation is ready.

## Implementation Strategy

1. **MVP First**: Complete User Story 1 (PR Checks) to provide immediate value to the development team.
2. **Incremental Delivery**: Implement User Story 2 (Build on Merge) to ensure the main branch is always buildable.
3. **Automation**: Finalize with User Story 3 (Release on Tag) to automate the distribution process.

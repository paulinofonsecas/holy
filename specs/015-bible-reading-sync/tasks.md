---

description: "Task list for Sincronização de leitura da Bíblia"
---

# Tasks: Sincronização de leitura da Bíblia

**Input**: Design documents from `/specs/015-bible-reading-sync/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Requested by user ("crie testes de reading sync") — include contract/integration tests per story.

**Organization**: Tasks grouped by user story to keep each increment independently testable.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare tooling and skeleton for the feature

- [x] T001 Run agent context updater in .specify/scripts/powershell/update-agent-context.ps1
- [x] T002 Add RTDB emulator/database config entry to firebase.json
- [x] T003 [P] Create reading sync feature scaffolding in lib/app/features/reading_sync/ and test/features/reading_sync/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure required before any user story

- [x] T004 Add firebase_database dependency and lock version in pubspec.yaml
- [x] T005 [P] Define shared models StudyRoom/Session/VerseReference/ShareEvent/SyncState in lib/app/features/reading_sync/domain/models/
- [x] T006 [P] Implement RTDB client wrapper with emulator hook in lib/app/features/reading_sync/data/rtdb_client.dart
- [x] T007 [P] Register reading sync module/providers for DI in lib/app/features/reading_sync/reading_sync_module.dart

**Checkpoint**: Foundation ready — user stories can start in parallel.

---

## Phase 3: User Story 1 - Compartilhar versículo em tempo real (Priority: P1) 🎯 MVP

**Goal**: Host publishes ShareVerse event and participants navigate/highlight within ≤2s using local resolver.

**Independent Test**: With Firebase emulator, ShareVerse event at /studyRooms/{roomId}/events produces local verse lookup and highlight within 2s on receivers.

### Tests for User Story 1

- [x] T008 [P] [US1] Contract test for RTDB events/rules in test/features/reading_sync/rtdb_share_event_contract_test.dart
- [x] T009 [P] [US1] Integration test for ShareVerse → local lookup → highlight in test/features/reading_sync/share_verse_integration_test.dart
- [ ] T030 [P] [US1] E2E emulator test simulating host→participant ShareVerse flow in test/features/reading_sync/e2e/share_verse_emulator_test.dart

### Implementation for User Story 1

- [x] T010 [P] [US1] Implement publish/subscribe StudyRoomService for ShareVerse in lib/app/features/reading_sync/data/study_room_service.dart
- [x] T011 [US1] Create apply_share_event use case to resolve verse locally in lib/app/features/reading_sync/domain/apply_share_event_usecase.dart
- [x] T012 [US1] Wire reading sync controller to propagate events to UI state in lib/app/features/reading_sync/presentation/reading_sync_controller.dart
- [x] T013 [US1] Add highlight/banner UI for received verse in lib/app/features/reading_sync/presentation/widgets/share_verse_banner.dart
- [x] T014 [US1] Instrument latency telemetry for ShareVerse events in lib/app/features/reading_sync/telemetry/reading_sync_telemetry.dart

**Checkpoint**: User Story 1 functional and testable independently.

---

## Phase 4: User Story 2 - Controle do host e desvinculação (Priority: P2)

**Goal**: Enforce host/authorized controller writes and allow participants to follow or detach with persisted choice and audit logging.

**Independent Test**: Unauthorized user cannot write control/events; detached participant stays detached until rejoin; audit log records control events.

### Tests for User Story 2

- [ ] T015 [P] [US2] Firebase rule test for authorized_controllers on /studyRooms/{roomId}/events in test/features/reading_sync/authorization_rules_test.dart
- [ ] T016 [P] [US2] Unit test for SyncState detach/reattach transitions in test/features/reading_sync/sync_state_test.dart

### Implementation for User Story 2

- [ ] T017 [P] [US2] Extend StudyRoomService with host-lock enforcement and detach handling in lib/app/features/reading_sync/data/study_room_service.dart
- [ ] T018 [US2] Implement FollowHost toggle with persisted opt-out in lib/app/features/reading_sync/presentation/follow_host_toggle.dart
- [ ] T019 [US2] Add local audit log store for sync events in lib/app/features/reading_sync/data/reading_sync_audit_log.dart
- [ ] T020 [US2] Show fallback UI when verse version missing in lib/app/features/reading_sync/presentation/verse_resolution_fallback.dart

**Checkpoint**: User Story 1 + 2 work independently; permissions and detach flows validated.

---

## Phase 5: User Story 3 - Descoberta e presença das salas (Priority: P3)

**Goal**: List public/authorized study rooms, allow join/invite, and keep presence heartbeats.

**Independent Test**: Public rooms list excludes private ones; joining updates presence; leaving clears presence and stops events.

### Tests for User Story 3

- [ ] T021 [P] [US3] Contract test for discovery/presence paths using emulator in test/features/reading_sync/discovery_presence_contract_test.dart
- [ ] T022 [P] [US3] Integration test for join/leave with presence heartbeat in test/features/reading_sync/presence_integration_test.dart

### Implementation for User Story 3

- [ ] T023 [P] [US3] Implement StudyRoomRepository for list/join with is_public filter in lib/app/features/reading_sync/data/study_room_repository.dart
- [ ] T024 [US3] Build StudyRoomsList page with join/invite actions in lib/app/features/reading_sync/presentation/study_rooms_list_page.dart
- [ ] T025 [US3] Add presence heartbeat and onDisconnect handler in lib/app/features/reading_sync/data/presence_updater.dart
- [ ] T026 [US3] Add private room invite request flow in lib/app/features/reading_sync/presentation/study_room_detail_page.dart

**Checkpoint**: Discovery and presence flows testable independently.

---

## Final Phase: Polish & Cross-Cutting Concerns

**Purpose**: Hardening, docs, performance

- [ ] T027 [P] Update RTDB schema/rules docs after implementation in specs/015-bible-reading-sync/contracts/rtdb-schema.json
- [ ] T028 Optimize telemetry sampling and reporting in lib/app/features/reading_sync/telemetry/reading_sync_telemetry.dart
- [ ] T029 Security review of RTDB rules vs contracts/rtdb-rules.json

---

## Dependencies & Execution Order

- Setup → Foundational → User Stories (priority order P1 → P2 → P3) → Polish
- User Story dependencies:
	- US1 (P1) depends on Foundational only
	- US2 (P2) depends on US1 + Foundational
	- US3 (P3) depends on Foundational; can proceed in parallel after US1 if DI/service scaffolds ready

## Parallel Execution Examples per Story

- US1: Run T008 and T009 in parallel; implement T010 and T011 in parallel while T012 consumes their outputs.
- US2: T015 and T016 can run in parallel; T017 in parallel with T018 as long as service contracts are stable.
- US3: T021 and T022 in parallel; T023 and T025 in parallel while UI tasks T024/T026 consume repository/presence outputs.

## Implementation Strategy

- MVP first: Finish Setup → Foundational → US1, validate tests (T008, T009) before continuing.
- Incremental: Deliver US2 next for permission/detach, then US3 for discovery/presence.
- Tests-first per story; ensure contract tests fail before implementation.

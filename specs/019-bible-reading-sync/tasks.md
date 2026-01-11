# Tasks for: Sincronização de leitura da Bíblia

Phase 1: Setup

- [ ] T001 Initialize feature branch and PR draft in repo root: `specs/019-bible-reading-sync/plan.md`
- [ ] T002 [P] Add Firebase RTDB dependency to Flutter project: `pubspec.yaml`
- [ ] T003 Create RTDB rules draft file: `specs/019-bible-reading-sync/contracts/rtdb-rules.json`
- [ ] T004 [P] Add placeholder UI routes and screens: `lib/app/features/study_rooms/README.md`

Phase 2: Foundational (blocking prerequisites)

- [ ] T005 Implement `StudyRoom` data model classes: `lib/app/models/study_room.dart`
- [ ] T006 Implement `VerseReference` and resolver interfaces: `lib/app/core/verse_resolver.dart`
- [ ] T007 Create `StudyRoomService` RTDB integration (join/publish/presence): `lib/app/services/study_room_service.dart`
- [ ] T008 [P] Add unit tests for `VerseReference` lookup and mapping: `test/core/verse_resolver_test.dart`
- [ ] T009 Implement RTDB security rules (draft): `specs/019-bible-reading-sync/contracts/rtdb-rules.json`
- [ ] T010 Update CI/README with RTDB emulation instructions: `specs/019-bible-reading-sync/quickstart.md`

Phase 3: User Story US1 — Share a verse to participants (P1)
Story goal: Host shares a `VerseReference` and participants navigate locally within ≤2s.
Independent test criteria: Host emits `ShareVerse`; a joined participant applies the verse and highlights it within 2s on emulator with simulated mobile latency.

- [ ] T011 [US1] Implement event model and writer for `ShareEvent` to RTDB: `lib/app/services/study_room_service.dart`
- [ ] T012 [US1] Implement RTDB listener to receive `ShareEvent` and enqueue apply logic: `lib/app/services/study_room_service.dart`
- [ ] T013 [US1] Map incoming `verseRef` → local lookup → compute scroll offset: `lib/app/core/verse_resolver.dart`
- [ ] T014 [US1] Apply scroll & highlight UI logic on verse apply: `lib/app/features/study_rooms/study_room_view.dart`
- [ ] T015 [US1] Add telemetry for event latency and success/failure: `lib/app/services/telemetry_service.dart`
- [ ] T016 [US1] Integration E2E test: simulated host emits event; assert participant UI highlights within 2s: `test/features/study_room_e2e_test.dart`

Phase 4: User Story US2 — Follow host reading control (P2)
Story goal: Host advances verses; participants auto-advance unless detached.
Independent test criteria: When host issues `Advance`, followers update to next verse and highlight within 2s; detached participants unchanged.

- [ ] T017 [US2] Implement `Advance` event writer and ordering guarantees: `lib/app/services/study_room_service.dart`
- [ ] T018 [US2] Implement participant sync state (`following` | `detached`) persisted locally: `lib/app/core/sync_state.dart`
- [ ] T019 [US2] Add UI control `FollowHostToggle` to detach/reattach: `lib/app/features/study_rooms/widgets/follow_host_toggle.dart`
- [ ] T020 [US2] Add tests verifying detach behavior and reattach behavior: `test/features/follow_toggle_test.dart`

Phase 5: User Story US3 — Community discovery & StudyRooms list (P3)
Story goal: Users discover public study rooms and join or request invite to private rooms.
Independent test criteria: Public rooms appear in `StudyRoomsList`; joining writes presence and subscribes to events.

- [ ] T021 [US3] Implement `StudyRoomsList` UI and RTDB query for public rooms: `lib/app/features/study_rooms/study_rooms_list.dart`
- [ ] T022 [US3] Implement `StudyRoomView` join flow and presence updates: `lib/app/features/study_rooms/study_room_view.dart`
- [ ] T023 [US3] Implement host UI to mark room private and manage `authorized_controllers`: `lib/app/features/study_rooms/room_settings.dart`
- [ ] T024 [US3] Add tests for discovery and join flow with RTDB emulator: `test/features/study_rooms_list_test.dart`
- [ ] T025 [US3] Update `quickstart.md` with discovery usage and manual invite flow: `specs/019-bible-reading-sync/quickstart.md`

Final Phase: Polish & cross-cutting

- [ ] T026 [P] Add logging and diagnostics UI for sync attempts: `lib/app/features/study_rooms/debug/sync_log_view.dart`
- [ ] T027 [P] Add metrics dashboards (local/remote) to measure latency and failures: `specs/019-bible-reading-sync/metrics.md`
- [ ] T028 [P] Run pilot and collect acceptance metrics; create pilot report: `specs/019-bible-reading-sync/pilot-report.md`
- [ ] T029 [P] Accessibility and localization review for new UI strings: `lib/l10n/` and `specs/019-bible-reading-sync/quickstart.md`
- [ ] T030 [P] Prepare PR with documentation and migration notes: `specs/019-bible-reading-sync/plan.md`

Dependencies (story completion order)

- Phase 1 → Phase 2 → Phase 3 (US1) → Phase 4 (US2) → Phase 5 (US3) → Final

Parallel execution examples

- `T002`, `T004`, `T008`, `T026` are parallelizable (independent files/UI/tests).
- Backend rule drafting (`T003`/`T009`) can be done in parallel with client model implementation (`T005`/`T006`).
- UI skeletons (`T004`) and discovery screen (`T021`) can be developed in parallel by different engineers.

Implementation strategy (MVP first)

- MVP scope: Implement US1 core flow end-to-end (RTDB writer/listener, local resolver, highlight) and basic StudyRoom join. This covers T001–T016.
- Incrementally add US2 (follow toggle) and US3 (discovery) after MVP stabilizes.

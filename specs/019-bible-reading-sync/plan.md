# Implementation Plan — Sincronização de leitura da Bíblia

Overview
--------
Implement a real-time, low-latency "study room" reading sync allowing a host (and authorized guests) to share verse positions via Firebase Realtime Database. Deliverables: client RTDB integration, community discovery UI, sync control UI, local resolver/highlight, telemetry and tests.

Technical Context
-----------------
- Platform: Flutter (existing repo)
- Transport: Firebase Realtime Database (RTDB)
- Local data: existing indexed Bible database in-app
- Sync model: Hybrid (host-lock default; participants can desvincular)
- Discovery: StudyRoom list (public by default; host can mark private)

Unknowns / Constraints (marked resolved)
- Q1: Who controls sessions — Host + authorized guests (resolved)
- Q2: Sync level — Hybrid host-lock with opt-out (resolved)
- Q3: Transport — Firebase RTDB (resolved)

Constitution Check
------------------
Load `.specify/memory/constitution.md` and ensure no rules are violated by this plan (privacy, security, open-source licensing). If gates fail, list required changes.

Gates Evaluation
----------------
- Security: RTDB rules required for control paths (host/authorized only).
- Performance: client must apply events within 2s in mobile networks (measure during testing).

Phases & Artifacts
-------------------
Phase 0 — Research (deliverable: `research.md`) — COMPLETE
- Resolve remaining technical choices and document rationale.

Phase 1 — Design & Contracts (deliverables: `data-model.md`, `contracts/rtdb-schema.json`, `quickstart.md`) — TODO
- Design RTDB schema and security rules
- Define client-side contracts for events and presence
- Design UI interactions for `StudyRoom` discovery and sync controls

Phase 2 — Implementation (deliverables: code changes, tests, telemetry) — TODO
- Add RTDB integration module: `study_room_service` (join, publish event, presence)
- Add UI screens: `StudyRoomsList`, `StudyRoomView`, `FollowHostToggle`
- Add local resolver integration: map `ShareEvent` → local lookup → scroll/highlight
- Add telemetry: event latency, failure rate, join/leave counts

Phase 3 — QA & Pilot (deliverables: pilot test report) — TODO
- End-to-end tests with simulated latency
- Pilot with small user group; measure success criteria

Agent Context Update
--------------------
Run `.specify/scripts/powershell/update-agent-context.ps1 -AgentType copilot` to update agent files.

Next Actions (short)
--------------------
1. Create design artifacts (data-model, contracts, quickstart). 2. Run agent-context updater. 3. Open PR branch `019-bible-reading-sync/plan` with artifacts. 4. Start implementation tasks.

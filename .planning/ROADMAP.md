# ROADMAP

This roadmap maps v1 requirements to phased delivery and success criteria.

## Phases

### Phase 1 — Foundations
- Goals: Bootstrap app, authentication, reading/navigation basics
- Key Success: MVP auth and passage reading work
- Mapped Requirements: AUTH-01, AUTH-02, AUTH-03, READ-01, READ-02

### Phase 2 — Growth & Personalization
- Goals: Daily growth, profile, offline support
- Key Success: Reminders visible, offline mode functional
- Mapped Requirements: GROW-01, GROW-02, PROF-01, PROF-02, OFF-01, OFF-02

### Phase 3 — Reach & Refinement
- Goals: Improve UX, search, and accessibility
- Key Success: Verse search and accessible UI patterns in production
- Mapped Requirements: READ-03, (additional as identified)

## Phase Details

Phase 1: Foundations
- Objectives: Deliver core authentication and Bible reading basics
- Success Criteria:
  - Users can sign up, log in, and reset password
  - User can open a passage and navigate chapters

Phase 2: Growth & Personalization
- Objectives: Add daily growth features and user profiles with offline support
- Success Criteria:
  - Reminders display and streaks update
  - Profile edits persist and preferences are applied offline

Phase 3: Reach & Refinement
- Objectives: Improve search and accessibility; polish UX
- Success Criteria:
  - Verse search returns relevant results
  - UI accessible and responsive across targets

## Next Up

- Phase 1 kickoff notes
- Dependencies and risks
- Milestones and reviews planned

### Phase 4 — Web Migration & WASM Support
- Goals: Add first-class Web support including a WASM-capable parsing path (where beneficial), platform abstractions, and CI/web build validation
- Key Success: App builds and runs on Flutter Web (HTML and CanvasKit) and integrates an optional WASM parser module for heavy parsing tasks; offline/persistence on web functional
- Mapped Requirements: WEB-01, WEB-02, READ-01, OFF-01

---

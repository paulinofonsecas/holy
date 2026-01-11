# Research Log: Persistent Book Selection Modal

## Decision 1: Session-scoped selection state via dedicated Cubit
- **Rationale**: Spec assumption A-001 limits persistence to the active app session. A lightweight Cubit injected alongside `BibliaBloc` can track translation, book, chapter, expanded sections, and scroll offset without incurring serialization overhead. Leveraging an in-memory Cubit keeps updates synchronous with UI events and avoids conflicts with hydrated caches on cold starts.
- **Alternatives considered**:
  - Reusing `BibliaBloc` for UI state: rejected because the bloc already focuses on chapter retrieval; mixing UI-specific expansion/scroll state would violate separation of concerns and complicate testing.
  - HydratedBloc-backed persistence: rejected because cross-session restoration is out of scope and would require schema/version management for little user value.

## Decision 2: Sync selection Cubit from BibliaBloc lifecycle
- **Rationale**: External navigation triggers (search results, reading plans, swipes) already flow through `BibliaBloc`. Listening to `BibleChapterLoaded` states ensures the modal context mirrors every chapter change, including those initiated outside the modal.
- **Alternatives considered**:
  - Updating selection state only on modal taps: rejected because it would miss programmatic navigation and violate Success Criteria SC-002.
  - Polling BibleVersionCubit on modal open: rejected because it ignores chapter changes and introduces race conditions.

## Decision 3: Keep Wolt modal open while routing updates
- **Rationale**: Removing `Navigator.pop` calls from chapter taps allows the modal to remain visible while underlying content updates. Using the `modalSheetContext` only for explicit dismissals prevents accidental route pops and matches Wolt's guidance for persistent sheets.
- **Alternatives considered**:
  - Closing and immediately reopening the modal on each chapter change: rejected due to jarring UX and inability to maintain scroll/expansion state.
  - Embedding a nested Navigator for the modal: rejected as unnecessarily complex for a single-page sheet.

## Decision 4: Scroll position management with PrimaryScrollController
- **Rationale**: Providing a dedicated `ScrollController` tied to the modal page lets the Cubit capture and restore offset, satisfying Story 3 without hacking the Sliver builder. PrimaryScrollController works seamlessly with `CustomScrollView` used by `WoltModalSheet`.
- **Alternatives considered**:
  - Storing offsets via `Scrollable.ensureVisible`: rejected because it triggers jump animations and cannot maintain mid-list offsets when reopening.
  - Relying solely on item keys for auto-scroll: rejected because the sheet rebuilds fresh each time and SliverList lacks implicit remember-state support.

## Decision 5: UI performance target of <100 ms response per selection
- **Rationale**: Maintaining 60 fps requires each tap-to-highlight cycle to finish within ~16 ms for UI work. Allowing up to 100 ms end-to-end (including bloc fetch trigger) aligns with existing async fetching and ensures the modal stays responsive across mid-range devices.
- **Alternatives considered**:
  - No explicit budget: rejected because Success Criteria SC-001 needs measurable guidance for QA.
  - Aggressive <16 ms total budget: rejected as unrealistic given asynchronous chapter fetches; the user perceives responsiveness as long as tap feedback is instant and the modal stays open.

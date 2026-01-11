# Implementation Plan: Persistent Book Selection Modal

**Branch**: `021-persist-book-modal` | **Date**: 2026-01-11 | **Spec**: [specs/021-persist-book-modal/spec.md](specs/021-persist-book-modal/spec.md)
**Input**: Feature specification from `/specs/021-persist-book-modal/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Persist the user's navigation context inside the Bible book modal so chapter switches keep the sheet open, highlighting the latest location and restoring the same scroll/expansion state when reopened during the session.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Dart 3.6.0, Flutter 3.38.4  
**Primary Dependencies**: Flutter UI, flutter_bloc + hydrated_bloc for state, wolt_modal_sheet for modal presentation  
**Storage**: Session-scoped Cubit layered atop BibliaBloc; no hydrated persistence required  
**Testing**: flutter_test, bloc_test  
**Target Platform**: Android & iOS mobile clients  
**Project Type**: Mobile app (Flutter)  
**Performance Goals**: Maintain 60 fps modal interactions, zero noticeable lag when switching chapters  
**Constraints**: Must respect Eu Sou Constitution (BLoC/MVVM patterns); target <100 ms tap-to-update latency while keeping 60 fps animations  
**Scale/Scope**: Single modal flow within Bible reading feature (~2 UI components, 1 bloc)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Principle I (Monorepo & Modularization): Plan must reuse existing packages (e.g., bible_handler) and avoid duplicating business logic.
- Principle II (Bible Version Abstraction): All chapter loads must continue routing through bible_handler via BibliaBloc.
- Principle IV (Flutter Best Practices): Implementation should extend current BLoC/MVVM patterns and maintain accessible Material components.

✅ No violations identified at planning stage. Proceed to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
lib/
├── features/
│   └── biblia/
│       ├── bloc/
│       ├── modals/
│       ├── services/
│       ├── viewmodels/
│       └── widgets/
├── shared/
└── app/

packages/
└── bible_handler/

test/
└── features/
    └── biblia/
```
**Structure Decision**: Feature work stays within existing `lib/features/biblia` module, reusing BibliaBloc and modal widgets; no new top-level packages required.

## Complexity Tracking

No constitutional violations requiring waivers.


# Implementation Plan: Persistir Ultima Leitura da Biblia no Startup

**Branch**: `main` | **Date**: 2026-04-07 | **Spec**: `/specs/main/spec.md`
**Input**: Feature specification from `/specs/main/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Persistir e restaurar automaticamente a ultima posicao de leitura da Biblia entre sessoes do app, incluindo versao, livro, capitulo e scroll. A abordagem usa persistencia local em `SharedPreferences` via `ScrollPersistenceService`, restauracao inicial por `BibliaView`/`BibliaBloc` e reaplicacao de scroll em `ScreenReaderPage`, com fallback seguro para Genesis 1.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Dart ^3.6.0, Flutter >=3.38.4  
**Primary Dependencies**: flutter_bloc/bloc, shared_preferences, bible_handler  
**Storage**: SharedPreferences (contexto de leitura) e cache por chave de scroll por capitulo  
**Testing**: flutter_test, bloc_test, mocktail  
**Target Platform**: Android/iOS/Web (app Flutter)
**Project Type**: mobile (Flutter monorepo)  
**Performance Goals**: restauracao inicial sem bloqueio perceptivel; leitura de estado em <50ms no startup; restauracao de scroll em ate 1 frame apos layout  
**Constraints**: offline-first, sem regressao de navegacao existente, sem adicionar dependencia nova  
**Scale/Scope**: 1 fluxo (leitura biblica), 4-6 arquivos principais, sem migracao de banco

## Constitution Check

_GATE: Must pass before Phase 0 research. Re-check after Phase 1 design._

- O arquivo de constituicao em `.specify/memory/constitution.md` esta em formato template, sem regras normativas concretas.
- Gate de conformidade: PASS (sem violacoes detectaveis com as informacoes disponiveis).
- Gate de seguranca e privacidade: PASS (dados locais nao sensiveis; sem sincronizacao externa).
- Gate de qualidade: PASS condicional a cobertura de testes de restauracao e fallback.

### Post-Design Re-check

- Re-check apos Fase 1: PASS.
- Nenhuma violacao adicional introduzida por `data-model.md`, `contracts/` ou `quickstart.md`.

## Project Structure

### Documentation (this feature)

```text
specs/main/
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
│       │   ├── biblia_bloc.dart
│       │   ├── biblia_event.dart
│       │   └── biblia_state.dart
│       ├── views/
│       │   └── biblia_view.dart
│       └── widgets/
│           └── screen_reader_page.dart
├── core/
│   └── services/
│       └── scroll_persistence_service.dart
└── main.dart

test/
└── features/
  └── biblia/
```

**Structure Decision**: Aproveitar estrutura mobile Flutter ja existente no modulo `lib/features/biblia` e no servico transversal `lib/core/services`, sem criar novos modulos ou camadas.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ------------------------------------ |
| None      | N/A        | N/A                                  |

# Tasks: Persistir Ultima Leitura da Biblia no Startup

**Input**: Design documents from `/specs/main/`
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Preparar baseline da feature e pontos de alteracao sem mudar comportamento ainda.

- [x] T001 Revisar e documentar comportamento atual de startup em specs/main/quickstart.md
- [x] T002 Mapear chaves atuais de persistencia em lib/core/services/scroll_persistence_service.dart
- [x] T003 [P] Validar pontos de inicializacao da Biblia em lib/features/biblia/views/biblia_view.dart

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Infra compartilhada e contrato interno de persistencia, bloqueante para todas as historias.

- [x] T004 Adicionar chaves de ReadingPosition (versionId, bookId, chapterNumber, updatedAt) em lib/core/services/scroll_persistence_service.dart
- [x] T005 Implementar leitura validada de ReadingPosition com fallback nulo em lib/core/services/scroll_persistence_service.dart
- [x] T006 [P] Implementar salvamento atomico de ReadingPosition em lib/core/services/scroll_persistence_service.dart
- [x] T007 [P] Criar utilitario de validacao book/chapter com BibleBooks em lib/features/biblia/bloc/biblia_bloc.dart

**Checkpoint**: Fundacao pronta; historias podem iniciar.

---

## Phase 3: User Story 1 - Retomar leitura apos fechar app (Priority: P1) 🎯 MVP

**Goal**: Reabrir no ultimo livro/capitulo e restaurar scroll.

**Independent Test**: Fechar e reabrir app apos leitura; validar mesmo livro/capitulo e offset aproximado.

- [x] T008 [US1] Persistir ReadingPosition ao carregar capitulo com sucesso em lib/features/biblia/bloc/biblia_bloc.dart
- [x] T009 [US1] Garantir atualizacao debounce de offset por capitulo em lib/features/biblia/bloc/biblia_bloc.dart
- [x] T010 [US1] Restaurar referencia persistida no init da tela em lib/features/biblia/views/biblia_view.dart
- [x] T011 [US1] Aplicar initialScrollOffset somente apos layout pronto em lib/features/biblia/widgets/screen_reader_page.dart
- [x] T012 [US1] Sincronizar estado visual (BookSelectionCubit) apos restauracao em lib/features/biblia/views/biblia_view.dart
- [x] T013 [P] [US1] Adicionar testes do serviço de persistência em test/core/services/scroll_persistence_service_test.dart
- [x] T014 [P] [US1] Adicionar testes do bloc de restauração em test/features/biblia/bloc/biblia_bloc_test.dart

**Checkpoint**: US1 funcional e testavel de forma independente.

---

## Phase 4: User Story 2 - Retomar apos troca de versao (Priority: P2)

**Goal**: Restaurar versao salva quando valida e manter consistencia de referencia.

**Independent Test**: Trocar versao, navegar, fechar e reabrir app; validar versao e referencia restauradas.

- [x] T015 [US2] Salvar versionId ativo junto com ReadingPosition em lib/features/biblia/bloc/biblia_bloc.dart
- [x] T016 [US2] Resolver versao restaurada com fallback para versao ativa em lib/features/biblia/views/biblia_view.dart
- [x] T017 [US2] Evitar recarga redundante ao restaurar versao no listener de versao em lib/features/biblia/views/biblia_view.dart
- [x] T018 [US2] Atualizar contrato de restauracao de versao em specs/main/contracts/reading-position.openapi.yaml

**Checkpoint**: US2 funcional sem depender de US3.

---

## Phase 5: User Story 3 - Fallback seguro para estado invalido (Priority: P3)

**Goal**: Quando cache estiver ausente/corrompido, abrir Genesis 1 sem crash.

**Independent Test**: Injetar estado invalido em cache e abrir app; validar fallback silencioso para Genesis 1.

- [x] T019 [US3] Validar bookId/chapterNumber persistidos antes de restaurar em lib/features/biblia/views/biblia_view.dart
- [x] T020 [US3] Implementar fallback explicito para Genesis 1 no fluxo de startup em lib/features/biblia/views/biblia_view.dart
- [x] T021 [US3] Proteger restauracao de offset contra valores invalidos/negativos em lib/core/services/scroll_persistence_service.dart
- [x] T022 [US3] Registrar motivo de fallback para diagnostico em lib/features/biblia/bloc/biblia_bloc.dart

**Checkpoint**: US3 funcional e resiliente.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validacao final, documentacao e qualidade transversal.

- [x] T023 [P] Atualizar roteiro de validacao manual com cenarios finais em specs/main/quickstart.md
- [x] T024 Documentar decisoes finais e desvios de implementacao em specs/main/research.md
- [x] T025 [P] Ajustar modelo de dados conforme implementacao final em specs/main/data-model.md
- [x] T026 Executar validacao de feature e registrar evidencias em specs/main/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): inicia imediatamente.
- Foundational (Phase 2): depende de Setup e bloqueia historias.
- User Stories (Phase 3-5): dependem da conclusao de Foundational.
- Polish (Phase 6): depende das historias alvo concluidas.

### User Story Dependencies

- US1 (P1): inicia apos Phase 2; entrega o MVP.
- US2 (P2): inicia apos Phase 2; utiliza persistencia ja pronta.
- US3 (P3): inicia apos Phase 2; endurece o fluxo de restauracao.

### Within Each User Story

- Persistencia/validacao antes de restauracao em UI.
- Restauracao em bloc/view antes de ajustes visuais de scroll.
- Fechar sincronizacao de estado visual por ultimo.

---

## Parallel Execution Examples

### User Story 1

- T010 em lib/features/biblia/views/biblia_view.dart
- T011 em lib/features/biblia/widgets/screen_reader_page.dart

### User Story 2

- T014 em lib/features/biblia/views/biblia_view.dart
- T016 em specs/main/contracts/reading-position.openapi.yaml

### User Story 3

- T019 em lib/core/services/scroll_persistence_service.dart
- T020 em lib/features/biblia/bloc/biblia_bloc.dart

---

## Implementation Strategy

### MVP First (US1)

1. Concluir Phase 1 e Phase 2.
2. Entregar US1 (T008-T012).
3. Validar independentemente antes de avancar.

### Incremental Delivery

1. MVP: US1.
2. Consistencia de versao: US2.
3. Resiliencia/fallback: US3.
4. Finalizar polish e documentacao.

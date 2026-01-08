# Tasks: Download Progress Indicator

**Input**: Design documents from /specs/001-download-progress/
**Prerequisites**: plan.md, spec.md (required); research.md, data-model.md, contracts/ (optional if produced)

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label (US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)
**Purpose**: Prepare branch and scaffolding for download progress UX
- [X] T001 Confirm branch 001-download-progress checked out and up to date
- [X] T002 [P] Create feature directories for download UX in lib/features/download/ (viewmodels, widgets)

---

## Phase 2: Foundational (Blocking Prerequisites)
**Purpose**: Core hooks to expose download progress to UI
- [ ] T003 Define download progress model (percent, downloadedBytes, totalBytes, status) in packages/bible_handler/lib/src/models/download_progress.dart
- [ ] T004 Implement progress stream/exposure in download service (packages/bible_handler/lib/src/services/download_service.dart) emitting DownloadProgress updates every <=500ms
- [ ] T005 [P] Add persistence helper for progress state (downloadedBytes, totalBytes, status) using shared_preferences in lib/features/download/data/progress_persistence.dart

---

## Phase 3: User Story 1 - Ver progresso do download (Priority: P1) 🎯 MVP
**Goal**: Mostrar barra determinate com percentual e bytes baixados/restantes durante o download inicial
**Independent Test**: Em dispositivo sem cache, iniciar app e ver barra de 0%→100% com texto "X MB de Y MB" atualizando em tempo real

### Implementation
- [ ] T006 [US1] Create DownloadProgressViewModel (stacked) to subscribe ao progress stream e expor percent/text em lib/features/download/presentation/download_progress_viewmodel.dart
- [ ] T007 [US1] Build progress widget (barra + texto bytes) em lib/features/download/presentation/widgets/download_progress_bar.dart usando dados do ViewModel
- [ ] T008 [US1] Integrate progress widget na tela de carregamento inicial (splash/onboarding) em lib/features/onboarding/presentation/splash_page.dart (substituir spinner por barra determinate)
- [ ] T009 [P] [US1] Format bytes helper (MB/KB) e estimar restante simples em lib/features/download/utils/formatters.dart
- [ ] T010 [US1] Auto-advance flow: ao chegar 100%, acionar navegação para tela principal em splash_page.dart

---

## Phase 4: User Story 2 - Rede lenta ou instável (Priority: P2)
**Goal**: Progresso continua em rede lenta e retoma após quedas curtas ou background, sem resetar
**Independent Test**: Simular throttling/queda curta; progresso congela e retoma do mesmo percentual; ao voltar do background, valor persiste

### Implementation
- [ ] T011 [US2] Persist progress snapshots (bytes/total/status/timestamp) a cada atualização em progress_persistence.dart
- [ ] T012 [US2] Restaurar estado no ViewModel na inicialização e retomar assinatura do stream em download_progress_viewmodel.dart
- [ ] T013 [P] [US2] Handle unknown total → exibir spinner até receber total, então migrar para determinate sem perder bytes já lidos (download_service + viewmodel)
- [ ] T014 [US2] Pause/resume-friendly: se stream parar por falta de rede, manter último valor e exibir rótulo "Reconectando..." em download_progress_bar.dart

---

## Phase 5: User Story 3 - Erros e recuperação (Priority: P3)
**Goal**: Mensagem clara em falhas e ação de tentar novamente sem corromper dados
**Independent Test**: Forçar erro de rede; app exibe mensagem com botão "Tentar novamente"; retry não corrompe estado parcial

### Implementation
- [ ] T015 [US3] Propagar estados de erro no serviço (DownloadProgress.status=error + mensagem) em download_service.dart
- [ ] T016 [US3] Exibir estado de erro com CTA "Tentar novamente" em download_progress_bar.dart
- [ ] T017 [US3] Implementar ação de retry no ViewModel: limpar/retomar conforme disponibilidade, sem apagar dados íntegros em download_progress_viewmodel.dart
- [ ] T018 [P] [US3] Logging/analytics de falha e retry em lib/features/download/analytics/download_events.dart

---

## Phase 6: Polish & Cross-Cutting
**Purpose**: UX refinements, performance, e acessibilidade
- [ ] T019 [P] Acessibilidade: labels para leitores de tela no progress bar e botões em widgets/download_progress_bar.dart
- [ ] T020 [P] Performance: limitar rebuilds com selectors/debounce (<=500ms) no download_progress_viewmodel.dart
- [ ] T021 [P] Documentar fluxo e estados em docs/ ou specs/001-download-progress/quickstart.md

---

## Dependencies & Execution Order
- Setup → Foundational → User Stories (P1 antes de P2 antes de P3) → Polish
- Dentro de cada story: ViewModel antes de UI; persistência antes de restauração; erro antes de CTA de retry
- Paralelo: T002, T004, T005 podem rodar em paralelo; dentro de US1, T009 pode rodar em paralelo; dentro de US2, T013 em paralelo; dentro de US3, T018 em paralelo

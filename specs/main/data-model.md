# Data Model — Persistir Ultima Leitura da Biblia no Startup

## Entity: ReadingPosition

- Description: Snapshot da ultima posicao de leitura da Biblia para restauracao no startup.
- Fields:
  - `versionId` (string, required)
  - `bookId` (string, required)
  - `chapterNumber` (int, required, >= 1)
  - `scrollOffset` (double, required, >= 0.0)
  - `updatedAt` (string ISO-8601, required)
- Validation rules:
  - `bookId` deve existir em `BibleBooks`.
  - `chapterNumber` deve estar entre `1` e `chapterCount` do livro.
  - `scrollOffset` negativo deve ser normalizado para `0.0`.

## Entity: ReadingStartupState

- Description: Resultado de tentativa de restauracao no startup.
- Fields:
  - `status` (enum: `restored` | `fallback`)
  - `resolvedVersionId` (string, required)
  - `resolvedBookId` (string, required)
  - `resolvedChapterNumber` (int, required)
  - `resolvedScrollOffset` (double, required)
  - `reason` (string, optional)
- Validation rules:
  - `status=restored` quando todos os campos persistidos forem validos.
  - `status=fallback` quando qualquer validacao falhar.

## Entity: BibleScrollOffsetEntry

- Description: Persistencia por capitulo ja existente para offset de leitura.
- Fields:
  - `key` (string, format: `bible_scroll_{bookId}_{chapterNumber}`)
  - `offset` (double, >= 0.0)

## Relationships

- `ReadingPosition` referencia `BibleScrollOffsetEntry` via (`bookId`, `chapterNumber`).
- `ReadingStartupState` e derivado de `ReadingPosition` + validacao de dominio (`BibleBooks`).

## State Transitions

1. `idle` -> `persisted`

- Trigger: mudanca de capitulo/livro/versao ou evento de scroll.
- Effect: atualiza `ReadingPosition` e/ou `BibleScrollOffsetEntry`.

2. `persisted` -> `restored`

- Trigger: startup da tela Biblia.
- Guard: estado persistido valido.
- Effect: `GetChapter(versionId, bookId, chapterNumber)` + aplicar `scrollOffset`.

3. `persisted` -> `fallback`

- Trigger: startup com estado invalido/ausente.
- Effect: `GetChapter(versionAtual, genesis, 1)` com offset `0.0`.

## Implementation Notes

- A restauracao inicial e disparada em `BibliaView.initState()` quando `BibliaBloc` ainda esta em `BibliaInitial`.
- `resolvedVersionId` usa a versao persistida somente quando ela ainda existe em `BibleVersions`; caso contrario, usa a versao ativa atual.
- `scrollOffset` e sempre normalizado para valores `>= 0.0` antes de persistir ou restaurar.

# Research — Persistir Ultima Leitura da Biblia no Startup

## Decision 1: Persistir contexto de leitura em SharedPreferences

- Decision: Salvar `versionId`, `bookId`, `chapterNumber` e `updatedAt` em chaves dedicadas no `SharedPreferences`.
- Rationale: O app ja usa `SharedPreferences` amplamente, o custo de leitura/escrita e baixo e o dado e pequeno.
- Alternatives considered: HydratedBloc (adicionaria acoplamento ao estado completo), SQLite/ObjectBox (complexidade desnecessaria para payload simples).

## Decision 2: Manter scroll por capitulo com chave composta

- Decision: Reutilizar a estrategia atual de `ScrollPersistenceService` (`bible_scroll_{bookId}_{chapter}`) para restaurar offset.
- Rationale: Ja existe implementacao estavel e integrada ao `BibliaBloc` (`UpdateBibleScroll` + debounce).
- Alternatives considered: Salvar apenas ultimo scroll global (perde precisao ao trocar capitulo), salvar por versiculo alvo em vez de offset (nao cobre leitura parcial entre versiculos).

## Decision 3: Restauracao inicial dirigida por estado persistido

- Decision: No startup da tela da Biblia, carregar referencia persistida e disparar `GetChapter` com fallback para Genesis 1 se estado invalido.
- Rationale: Mantem a logica de carregamento centralizada no `BibliaBloc` e minimiza mudancas no fluxo atual.
- Alternatives considered: Restaurar diretamente na UI sem evento de bloc (quebra consistencia), restaurar somente ao trocar versao (nao atende startup).

## Decision 4: Politica de fallback e resiliencia

- Decision: Validar `bookId/chapterNumber/versionId`; se invalido, cair para `GetChapter(versionAtual, genesis, 1)` sem erro para o usuario.
- Rationale: Evita regressao funcional e garante inicializacao previsivel mesmo com cache inconsistente.
- Alternatives considered: Exibir erro bloqueante (piora UX), limpar todas preferencias do usuario (impacto indevido em dados nao relacionados).

## Decision 5: Testabilidade

- Decision: Cobrir restauracao e fallback com testes de bloc e widget.
- Rationale: Requisito central da feature e comportamento entre sessoes, que precisa de regressao automatizada.
- Alternatives considered: Apenas teste manual (risco de regressao silenciosa em refactors).

## Open Clarifications

- Nenhuma. Todos os itens de contexto tecnico foram resolvidos para esta iteracao.

## Implementation Outcome

- A carga inicial do capitulo saiu do bootstrap global de `BibliaBloc` e passou para `BibliaView`, permitindo restauracao do ultimo contexto persistido antes do primeiro `GetChapter`.
- A persistencia agora salva contexto de leitura (`versionId`, `bookId`, `chapterNumber`) junto com o offset por capitulo.
- A restauracao de scroll foi endurecida com clamp para evitar `jumpTo` fora dos limites do controller.
- Foram adicionados testes automatizados de servico e bloc para persistencia e restauracao.

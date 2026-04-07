# Persistir Última Leitura da Bíblia no Startup

## Resumo

Garantir que, ao abrir o app novamente, o usuário volte automaticamente para o mesmo contexto de leitura bíblica da sessão anterior: versão, livro, capítulo e posição de scroll.

## Clarifications

### Session 2026-04-07

- Q: O app deve retomar somente capítulo ou também a posição exata de leitura? → A: Retomar capítulo + posição exata de scroll.
- Q: Qual comportamento quando não houver estado salvo válido? → A: Fallback para Gênesis 1, versão ativa.
- Q: O estado deve ser salvo com qual frequência? → A: Salvar em eventos de navegação e com debounce para scroll contínuo.

## Contexto & Objetivo

Usuários perdem continuidade de leitura quando reabrem o app e retornam ao início (Gênesis 1) em vez de retomar de onde pararam. A feature deve tornar a experiência de leitura contínua entre sessões, sem exigir ação manual.

## Atores

- Usuário leitor: fecha e reabre o app esperando continuidade.
- Sistema (app): persiste e restaura o último contexto de leitura.

## User Scenarios & Testing

1. Retomar leitura após fechar o app
   - Dado que o usuário estava em um livro/capítulo com scroll avançado
   - Quando o app é fechado e aberto novamente
   - Então a tela da Bíblia deve abrir no mesmo livro/capítulo e aplicar o scroll salvo.

2. Retomar após troca de versão da Bíblia
   - Dado que o usuário trocou a versão enquanto lia
   - Quando reabrir o app
   - Então o app deve tentar restaurar a mesma versão e referência salva.

3. Estado salvo inválido
   - Dado estado corrompido/incompleto no cache
   - Quando abrir o app
   - Então usar fallback seguro (Gênesis 1) sem crash.

## Functional Requirements (testáveis)

FR-1: Persistência de contexto de leitura

- O app deve persistir `versionId`, `bookId`, `chapterNumber` e `scrollOffset` da sessão de leitura atual.

FR-2: Restauração no startup

- No próximo startup, ao entrar na tela da Bíblia, o app deve carregar automaticamente o último `bookId/chapterNumber` persistido.

FR-3: Restauração de scroll

- Após o capítulo ser carregado, o app deve aplicar `scrollOffset` salvo para aquele `bookId/chapterNumber`.

FR-4: Atualização contínua

- O `scrollOffset` deve ser salvo durante a leitura com debounce para evitar escrita excessiva.

FR-5: Fallback seguro

- Se os dados persistidos estiverem ausentes ou inválidos, o app deve abrir em Gênesis 1, sem erro visível ao usuário.

FR-6: Consistência de versão

- O app deve restaurar a versão salva quando válida; se não for válida, usar a versão ativa atual.

## Success Criteria

- SC-1: Em testes manuais de 20 ciclos de fechamento/abertura, 100% retornam ao último livro/capítulo.
- SC-2: Em 95% dos ciclos, o scroll é restaurado com tolerância de ±32 px.
- SC-3: Nenhum crash relacionado à restauração em startup.

## Key Entities

- `ReadingPosition`: `versionId`, `bookId`, `chapterNumber`, `scrollOffset`, `updatedAt`
- `ReadingStartupState`: resultado da restauração (`restored` | `fallback`)

## Assumptions

- SharedPreferences já está disponível por injeção no app.
- A tela de leitura bíblica usa `BibliaBloc` e `ScreenReaderPage` para navegação e scroll.

## Constraints & Non-Goals

- Não inclui sincronização em nuvem entre dispositivos.
- Não altera histórico de leitura do perfil; foco é apenas retomada no startup.

## Dependencies

- `ScrollPersistenceService`
- `BibliaBloc`
- `BibliaView` e `ScreenReaderPage`
- `SharedPreferences`

## Acceptance Tests (high level)

- AT-1: App reabre no último livro/capítulo.
- AT-2: App reaplica scroll salvo no capítulo restaurado.
- AT-3: Estado inválido cai em fallback para Gênesis 1.
- AT-4: Troca de versão é respeitada quando válida.

Spec Ready: sim

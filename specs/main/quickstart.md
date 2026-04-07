# Quickstart — Persistir Ultima Leitura da Biblia no Startup

## 1. Preparacao

1. Instalar dependencias:
   - `flutter pub get`
2. Confirmar que o app injeta `SharedPreferences` em `main.dart`.

## 2. Implementacao

1. Estender `ScrollPersistenceService` para salvar e ler ultimo contexto:
   - `versionId`, `bookId`, `chapterNumber`, `updatedAt`.
2. Atualizar `BibliaBloc`:
   - Persistir ultimo contexto ao carregar capitulo com sucesso.
   - Manter debounce de `UpdateBibleScroll` para escrita de offset.
3. Atualizar `BibliaView` (startup da feature):
   - Ler ultimo contexto persistido na inicializacao.
   - Disparar `GetChapter` para referencia restaurada.
   - Aplicar fallback Genesis 1 quando estado invalido.
4. Garantir em `ScreenReaderPage`:
   - Restauracao de `initialScrollOffset` apenas apos o layout estar pronto.

## 3. Testes

1. Rodar testes direcionados:
   - `flutter test test/features/biblia`
   - `flutter test test/core/services/scroll_persistence_service_test.dart`
2. Rodar analise:
   - `flutter analyze`

## 4. Validacao Manual

1. Abrir Biblia e navegar para um livro/capitulo diferente de Genesis 1.
2. Fazer scroll para uma posicao intermediaria.
3. Fechar o app completamente.
4. Reabrir o app e entrar na Biblia.
5. Validar:
   - Mesmo livro/capitulo da sessao anterior.
   - Scroll restaurado aproximadamente no mesmo ponto.
   - Versao anterior restaurada quando ainda suportada.

## 4.1 Evidencia Executada

1. `runTests` executado em 2026-04-07.
2. Resultado: 6 testes aprovados, 0 falhas.

## 5. Rollback

1. Desativar restauracao por startup (feature flag local, se adicionada) ou remover leitura do contexto persistido.
2. Manter fallback Genesis 1 como comportamento padrao.

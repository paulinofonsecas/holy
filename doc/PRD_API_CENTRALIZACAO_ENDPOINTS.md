# PRD - API de Centralizacao de Informacoes Entre Aplicativos

Status: Draft
Data: 2026-05-09
Autor: Produto/Engenharia

## 1. Contexto

Hoje o app mobile possui fontes de dados distribuidas entre:

- API Bible Server para conteudo biblico (versoes, livros, capitulos, capitulo completo)
- Integracao direta com Gemini para IA (embeddings e geracao de analise)
- Persistencia local (SQLite/SharedPreferences/Hive/ObjectBox) para historicos e preferencias

Para suportar multiplos aplicativos (mobile, web, futuros clientes), precisamos de uma API unica que concentre regras de negocio, contratos e sincronizacao de dados do usuario.

## 2. Objetivo do Produto

Criar uma API centralizada que:

- Exponha os endpoints usados pelos data sources do mobile
- Mantenha o padrao arquitetural do diagrama: Controller -> Use Cases -> Service
- Permita reutilizacao por outros aplicativos sem duplicar logica de negocio
- Prepare sincronizacao de dados de usuario entre dispositivos

## 3. Escopo

### 3.1 Escopo MVP (Fase 1)

Baseado no diagrama enviado:

- BibliaController
  - pull bible versions
  - [GET] bible version (catalogo de livros da versao)
- IAController
  - endpoint para embeddings
  - endpoint para entendimento aprofundado (Gemini LLM)

### 3.2 Escopo Fase 2 (Sincronizacao entre apps)

Com base nos repositorios/datasources atuais do mobile:

- Perfil e preferencias (cor de destaque)
- Historico de buscas
- Historico de versiculos lidos
- Versiculos marcados/favoritos
- Reflexoes diarias (feature Eu Sou)
- Sessoes de entendimento aprofundado (historico e estado)

## 4. Fora de Escopo (neste PRD)

- Migracao completa do mecanismo de busca local FTS para busca 100% remota
- Engine de recomendacao personalizada
- Painel administrativo

## 5. Arquitetura Proposta

### 5.1 Camadas

- Controllers: recebem HTTP, validam entrada, retornam contratos JSON
- Use Cases: orquestram regras de negocio por caso de uso
- Services: integram provedores externos (Gemini, repositorio biblico, cache, banco)
- Repositories: persistencia e leitura em banco

### 5.2 Mapeamento do diagrama para componentes reais

- IAController
  - GenerateEmbeddingsUseCase -> IAService -> Embedding Model
  - GenerateDeepUnderstandingUseCase -> IAService -> Gemini LLM
  - GenerateWeeklyReminderMessagesUseCase -> IAService -> Gemini LLM
- BibliaController
  - PullVersionsUseCase -> BibleService
  - GetVersionBooksUseCase -> BibleService
  - GetVersionBookChaptersUseCase -> BibleService
  - GetChapterUseCase -> BibleService

## 6. Mapeamento Mobile Datasource -> Endpoint API

### 6.1 Biblia (baseado em IBibleProvider e XmlBibleProvider)

- Mobile: getVersoes()
  - API: GET /v1/bible/versions
- Mobile: getLivros(versionId)
  - API: GET /v1/bible/versions/{versionId}/books
- Mobile: getCapitulos(versionId, bookId)
  - API: GET /v1/bible/versions/{versionId}/books/{bookId}/chapters
- Mobile: getChapter(versionId, bookId, chapterId)
  - API: GET /v1/bible/versions/{versionId}/books/{bookId}/chapters/{chapterId}

### 6.2 IA (baseado em GeminiAIService e DeepUnderstandingService)

- Mobile: getEmbeddings(texts)
  - API: POST /v1/ai/embeddings
- Mobile: generateSummary(query, context)
  - API: POST /v1/ai/deep-understanding
- Mobile: generateWeeklyReminderMessages(...)
  - API: POST /v1/ai/weekly-reminders

### 6.3 Dados de Usuario (fase 2)

- Cor de destaque (ProfileRepository)
  - GET /v1/users/{userId}/profile/preferences
  - PUT /v1/users/{userId}/profile/preferences
- Historico de busca (SearchHistoryRepository)
  - GET /v1/users/{userId}/history/search
  - POST /v1/users/{userId}/history/search
  - DELETE /v1/users/{userId}/history/search
- Historico de versiculos (VerseHistoryRepository)
  - GET /v1/users/{userId}/history/verses
  - POST /v1/users/{userId}/history/verses
  - DELETE /v1/users/{userId}/history/verses
- Versiculos marcados (MarkedVersesRepository)
  - GET /v1/users/{userId}/highlights
  - DELETE /v1/users/{userId}/highlights/{verseRef}
- Reflexoes diarias (EuSouRepository)
  - GET /v1/users/{userId}/reflections/today
  - PUT /v1/users/{userId}/reflections/today
  - GET /v1/users/{userId}/reflections/history

## 7. Contratos de API (MVP)

### 7.1 GET /v1/bible/versions

Response 200:

```json
{
  "versions": ["ACF", "NVI", "KJA"]
}
```

### 7.2 GET /v1/bible/versions/{versionId}/books

Response 200:

```json
{
  "versionId": "ACF",
  "books": [
    { "id": "GEN", "name": "Genesis" },
    { "id": "EXO", "name": "Exodo" }
  ]
}
```

### 7.3 GET /v1/bible/versions/{versionId}/books/{bookId}/chapters

Response 200:

```json
{
  "versionId": "ACF",
  "bookId": "GEN",
  "chapters": [
    { "number": 1 },
    { "number": 2 }
  ]
}
```

### 7.4 GET /v1/bible/versions/{versionId}/books/{bookId}/chapters/{chapterId}

Response 200:

```json
{
  "versionId": "ACF",
  "bookId": "GEN",
  "chapter": {
    "number": 1,
    "verses": [
      { "number": 1, "text": "No principio criou Deus..." }
    ]
  }
}
```

### 7.5 POST /v1/ai/embeddings

Request:

```json
{
  "texts": ["No principio", "Porque Deus amou"]
}
```

Response 200:

```json
{
  "embeddings": [
    [0.12, -0.09, 0.44],
    [0.08, 0.33, -0.10]
  ]
}
```

### 7.6 POST /v1/ai/deep-understanding

Request:

```json
{
  "query": "graca",
  "context": [
    "[Joao 3:16] Porque Deus amou o mundo...",
    "[Efesios 2:8] Pela graca sois salvos..."
  ]
}
```

Response 200:

```json
{
  "summary": "Resumo central..."
}
```

### 7.7 POST /v1/ai/weekly-reminders

Request:

```json
{
  "reminderLabel": "Lembrete Matinal",
  "reminderSubtitle": "Comece o dia com a Palavra",
  "moodHint": "encorajador",
  "verses": [
    { "reference": "Salmos 23:1", "text": "O Senhor e o meu pastor" }
  ]
}
```

Response 200:

```json
{
  "messages": [
    "Deus guia seus passos hoje (Salmos 23:1)"
  ]
}
```

## 8. Requisitos Funcionais

- FR-001: A API deve fornecer versoes biblicas disponiveis.
- FR-002: A API deve fornecer livros de uma versao biblica.
- FR-003: A API deve fornecer lista de capitulos de um livro.
- FR-004: A API deve fornecer o conteudo de um capitulo.
- FR-005: A API deve gerar embeddings em lote para textos enviados.
- FR-006: A API deve gerar entendimento aprofundado com base em query + contexto.
- FR-007: A API deve gerar mensagens semanais de lembrete.
- FR-008: A API deve expor endpoints de sincronizacao de dados de usuario na fase 2.

## 9. Requisitos Nao Funcionais

- NFR-001: P95 de leitura de capitulo < 400ms (com cache aquecido).
- NFR-002: P95 de GET de versoes/livros/capitulos < 200ms.
- NFR-003: Endpoints de IA devem ser assincronos ou tolerantes a timeout >= 30s.
- NFR-004: Observabilidade obrigatoria com correlation-id por request.
- NFR-005: Versionamento de API via prefixo /v1.
- NFR-006: Resposta de erro padronizada em JSON.

## 10. Seguranca e Governanca

- Autenticacao: JWT Bearer para endpoints de usuario e IA.
- Autorizacao: userId do path deve coincidir com subject do token.
- Rate limit:
  - Leitura biblica: 120 req/min por cliente
  - IA: 20 req/min por cliente
- Protecao de segredos: chaves Gemini apenas no backend.

## 11. Padrao de Erro

```json
{
  "error": {
    "code": "INVALID_ARGUMENT",
    "message": "versionId is required",
    "details": {}
  }
}
```

Codigos esperados: 400, 401, 403, 404, 409, 429, 500.

## 12. Roadmap de Entrega

### Marco 1 - Bible API Basica

- GET /v1/bible/versions
- GET /v1/bible/versions/{versionId}/books
- GET /v1/bible/versions/{versionId}/books/{bookId}/chapters
- GET /v1/bible/versions/{versionId}/books/{bookId}/chapters/{chapterId}

### Marco 2 - IA API

- POST /v1/ai/embeddings
- POST /v1/ai/deep-understanding
- POST /v1/ai/weekly-reminders

### Marco 3 - Sync de Usuario

- Profile preferences
- Search history
- Verse history
- Highlights
- Daily reflections

## 13. Criterios de Sucesso

- SC-001: 100% dos fluxos biblicos atuais do mobile funcionando via /v1/bible.
- SC-002: 100% dos fluxos de IA do mobile sem chave Gemini no cliente.
- SC-003: Reducao de 80% em duplicacao de logica de negocio entre apps.
- SC-004: Capacidade de conectar um segundo aplicativo (web ou admin) sem criar novas regras de negocio no cliente.

## 14. Riscos e Mitigacoes

- Risco: Aumento de latencia em IA.
  - Mitigacao: timeout configuravel, retries com backoff e fila assincrona para payloads grandes.
- Risco: Divergencia entre schema mobile e schema API.
  - Mitigacao: contratos versionados e testes de compatibilidade por endpoint.
- Risco: Dependencia de provedor externo Gemini.
  - Mitigacao: camada IAService desacoplada para permitir troca de provider.

## 15. Decisoes em Aberto

- A API de IA sera sincrona (resposta imediata) ou assincrona (job + polling/webhook)?
- A fase 2 usara merge de historico por timestamp ou estrategia last-write-wins?
- O endpoint de highlights deve suportar upsert (marcar/desmarcar) no mesmo contrato?

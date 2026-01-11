# Sincronização de leitura da Bíblia

Resumo
-------
Uma feature que permite a sincronização de leitura de versículos entre dois ou mais participantes durante uma chamada ou meeting (áudio/video externo). O objetivo é permitir que um pregador compartilhe um versículo ou posição de leitura e que os ouvintes localizem e abram a mesma referência localmente, em tempo real, com mínimo impacto de latência.

## Clarifications

### Session 2026-01-04
- Q: Como os ouvintes encontram salas de estudo (discovery)? → A: Option C — Híbrido: salas públicas listadas; host pode tornar privada/por convite. Rationale: equilibra descoberta e privacidade.
 - Q: Qual transporte usar para eventos de sincronização (signaling)? → A: Firebase Realtime Database — usar RTDB para publicação/subscrição de eventos, presença e replicação em tempo real. Rationale: baixa latência, offline sync, regras de segurança integradas.
 - Q: Quem pode iniciar/controlar a sessão? → A: Option C — Host + convidados explicitamente autorizados. Rationale: host mantém controle, mas pode delegar a convidados confiáveis quando necessário.

Contexto & Objetivo
---------------------
Muitas reuniões de estudo ou pregações ocorrem em plataformas de chamada externa. Queremos oferecer uma experiência complementar: quando o pregador compartilha um versículo, todos os ouvintes do meeting possam automaticamente localizar o mesmo versículo em seu app e acompanhar a leitura sem sair da chamada. A sincronização deve usar a indexação e busca local do app para garantir que a navegação seja rápida e funcionará mesmo com conexão limitada.

Actors
------
- Pregador (Host): inicia compartilhamento de versículo/página.
- Ouvinte (Participant): recebe o comando de sincronização e navega localmente.
- Sistema (App): realiza resolução local do versículo, aplica destaque/scroll e reporta estado.

User Scenarios & Testing
------------------------
1) Compartilhar um versículo durante uma chamada
   - Pré-condição: Pregador e ouvintes estão numa chamada externa (áudio/video) e todos têm o app aberto.
   - Passos: Pregador toca "Compartilhar versículo" → seleciona versículo ou posição → envia.
   - Resultado esperado: O app dos ouvintes localiza o versículo e o exibe em destaque; usuário vê o versículo em até 2s.

2) Seguir leitura com controle do pregador
   - Passos: Pregador avança para o próximo versículo → todos os ouvintes avançam automaticamente.
   - Resultado esperado: Avanços aplicados em ordem e sem conflitos; usuários podem optar por desconectar do modo sincronizado.

3) Participante tenta buscar manualmente enquanto em modo sincronizado
   - Passos: Participante busca outro versículo localmente.
   - Resultado esperado: Aplicativo preserva o modo sincronizado (se for lock-step) ou permite desvinculação manual.

Functional Requirements (testáveis)
----------------------------------
FR-1: Iniciar sessão de sincronização
  - O app deve permitir criar/entrar numa sessão de leitura identificada por `session_id` gerado pelo iniciador.

FR-2: Emitir evento de compartilhamento
  - O iniciador deve poder emitir um evento `ShareVerse(verseRef)` que contenha referências suficientes para localizar o versículo (livro, capítulo, versículo, versão de texto opcional).

FR-3: Resolução local determinística
  - Dado `verseRef`, o app receptor deve localizar a posição correspondente em seu índice local sem depender de uma chamada remota adicional.

FR-4: Aplicar navegação/realce
  - Após localizar o versículo, o app deve rolar até a posição correta e aplicar realce visual, notificando o usuário com um pequeno banner.

FR-5: Latência e confiabilidade
  - 95% dos eventos `ShareVerse` devem resultar em navegação e realce visíveis no app receptor em até 2 segundos em condições de rede móvel razoável.

FR-6: Controle de permissão
  - Apenas participantes autorizados (host ou convidados) podem iniciar ou controlar a sessão; participantes podem optar por seguir ou sair do modo sincronizado.
  - Permissão detalhada: apenas o `host` e convidados explicitamente autorizados (lista em `StudyRoom.metadata.authorized_controllers`) podem iniciar/emitir controle de sessão (`ShareVerse`, `Advance`). O `host` pode adicionar ou remover `authorized_controllers` via UI; mudanças são validadas por regras do RTDB.

Security notes (RTDB rules):
  - Escrever nas paths de controle (`/studyRooms/{roomId}/control` e `/studyRooms/{roomId}/events`) requer validação de que `auth.uid == host_id || auth.uid in metadata.authorized_controllers`.
  - Presença e join/leave paths podem ser escritas por participantes, mas controle de eventos segue regras acima.

FR-7: Conflito e desvinculação
  - Se um participante buscar manualmente enquanto em modo sincronizado, o app deve oferecer: (A) permanecer sincronizado (forçar retorno no próximo evento), ou (B) desvincular (não receber mais eventos até reentrada).
  - Comportamento híbrido (padronizado): por padrão a sessão opera em modo `host-lock` (host controla avanços). Participantes podem escolher `Desvincular` para parar de aplicar eventos automaticamente; essa escolha persiste até que o participante reative `Seguir pregador`. Se `Desvincular` não for selecionado, o próximo evento do host reaplicará a posição.

FR-8: Operação com conexão limitada
  - Se o receptor não conseguir localizar o versículo (versão ausente), o app deve apresentar uma mensagem amigável e um botão de ação para tentar mapear manualmente.

FR-9: Registro de eventos
  - O app deve registrar localmente (audit) eventos de sincronização (iniciar, compartilhar, avançar, desligar) com timestamps para diagnóstico.

  FR-10: Descoberta e salas de estudo (community)
    - O app deve oferecer uma tela de descoberta tipo "community" onde ouvintes podem ver salas públicas, entrar, ou solicitar convite para salas privadas. O `host` pode marcar uma sala como `is_public=false` para torná-la privada.

  FR-11: Transporte de eventos — Firebase Realtime Database
    - O app usará Firebase Realtime Database (RTDB) como canal de transporte para eventos `ShareEvent`, presença e estado de sessão. Recomenda-se a estrutura mínima:
      - `/studyRooms/{roomId}/events/{eventId}`: eventos `ShareVerse`, `Advance`, `Join`, `Leave`.
      - `/sessions/{sessionId}/state`: último evento aplicado e metadados de sessão.
      - `/presence/{roomId}/{participantId}`: estado online/offline e timestamp.
    - Requisitos adicionais: regras de segurança no RTDB para validar permissões (somente host/authorized can write to control paths), uso de timestamps do servidor e compactação/TTL para eventos antigos.

Success Criteria
----------------
- 95% dos eventos de compartilhamento resultam em navegação e realce em ≤ 2s (medido em amostra de 100 sessões reais).
- Usuários conseguem seguir o fluxo de leitura com no máximo 2 toques adicionais (aceitar/saír) em 90% dos casos.
- Reclamações relacionadas a "lag" ou falha de sincronização reduzem para menos de 2% das sessões após 1º mês de uso.

Key Entities
------------
- `VerseReference` (book, chapter, verse, version)
- `Session` (session_id, host_id, participants[], started_at)
- `ShareEvent` (session_id, verseReference, event_type, timestamp)
- `SyncState` (participant_id, last_applied_event_id, status)
 - `StudyRoom` (room_id, title, host_id, is_public, participants[], created_at, metadata)


Assumptions
-----------
- A chamada de áudio/video é externa ao app; o app apenas transmite/recebe eventos de sincronização por um canal paralelo (mensagem no chat, signaling server, WebSocket ou via a infraestrutura do meeting). [NEEDS CLARIFICATION: ver Q3]
- Todos os participantes têm uma cópia local indexada da Bíblia/versões suportadas; se uma versão específica faltar, o app faz um mapeamento aproximado.
- A interface de usuário terá um controle simples "Seguir pregador" / "Sair".
 - Salas de estudo são listadas publicamente por padrão; o `host` pode marcar uma sala como privada/por convite (hybrid discovery).

[NEEDS CLARIFICATION: Quem pode controlar a sessão — apenas o host ou qualquer participante pode iniciar compartilhamento? ver Q1]
[NEEDS CLARIFICATION: Nível de sincronização — lock-step (todos obrigados a seguir) ou soft-sync (melhor esforço, opcional para cada usuário)? ver Q2]

Constraints & Non-Goals
----------------------
- Não se pretende substituir a Bíblia física; a feature é um assistente de leitura compartilhada.
- Não inclui implementação de vídeo/áudio dentro do app (exceto integração mínima de signaling se necessária).

Dependencies
------------
- Index de textos bíblicos local e mecanismo de busca/lookup.
- Mecanismo de transporte para eventos de sincronização (a ser definido: signaling server/WebSocket/meeting chat). [ver Q3]

Acceptance Tests (high level)
----------------------------
- AT-1: Host envia `ShareVerse` e 9/10 participantes recebem e exibem dentro de 2s em ambiente de teste com latência simulada.
- AT-2: Participante desvincula manualmente — receber eventos futuros respeita escolha.
- AT-3: Versão ausente — app mostra ação de mapeamento e não trava.

Spec Ready: sim (pendente decisões listadas em [NEEDS CLARIFICATION])

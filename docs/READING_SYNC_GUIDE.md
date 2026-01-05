# Sincronização de Leitura da Bíblia - Guia de Implementação

## Visão Geral

A feature de sincronização de leitura permite que um pregador (host) compartilhe um versículo da Bíblia em tempo real com um ou mais ouvintes (participantes) durante uma chamada de áudio/vídeo. Quando o pregador compartilha um versículo, todos os ouvintes veem esse versículo automaticamente destacado e posicionado em suas cópias locais do aplicativo.

**Latência Alvo**: 95% dos eventos devem ser processados em ≤ 2 segundos
**Transporte**: Firebase Realtime Database (RTDB)
**Modelo de Sincronização**: Hybrid host-lock com opt-out para participantes

---

## Arquitetura

### Componentes Principais

```
┌─ ReadingSyncStudyRoomService (data/)
│  ├─ Gerencia conexão RTDB
│  ├─ Publica/subscreve eventos
│  └─ Mantém presença de participantes
│
├─ ApplyShareEventUseCase (domain/)
│  ├─ Recebe ShareEvent do RTDB
│  ├─ Resolve versículo localmente
│  └─ Retorna resultado (sucesso/erro)
│
├─ ReadingSyncController (presentation/)
│  ├─ Orquestra serviço + use case
│  ├─ Expõe stream de eventos ao UI
│  └─ Instrumenta telemetria
│
└─ ReadingSyncUI (presentation/widgets/)
   ├─ ShareVerseBanner (exibe versículo compartilhado)
   ├─ StudyRoomView (sala de estudo)
   └─ FollowHostToggle (controle de sincronização)
```

### Fluxo de Dados

```
Host publishes ShareVerse
         ↓
    [RTDB event]
         ↓
Participant receives on stream
         ↓
ApplyShareEventUseCase resolves locally
         ↓
UI updates with highlight/banner
         ↓
Telemetry records latency
```

---

## Guia de Uso

### Pré-requisitos

1. **Firebase Project** com Realtime Database habilitado
2. **Android/iOS** com Google Play Services/Firebase SDK configurados
3. **Emulator Suite** (opcional, para desenvolvimento local)

### Setup Inicial

#### 1. Configurar Firebase

```dart
// main.dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

#### 2. Habilitar Emulator (Desenvolvimento)

```dart
// main.dart
if (kDebugMode) {
  FirebaseDatabase.instance.useDatabaseEmulator('localhost', 9000);
}
```

Para rodar o emulator:
```bash
firebase emulators:start --only database
```

#### 3. Adicionar Segurança RTDB

Aplicar regras de segurança do `specs/015-bible-reading-sync/contracts/rtdb-rules.json` no Firebase Console:

```json
{
  "rules": {
    "studyRooms": {
      "$roomId": {
        ".read": "auth != null",
        "events": {
          "$eventId": {
            ".write": "auth.uid == root.child('studyRooms').child($roomId).child('host_id').val() || auth.uid in root.child('studyRooms').child($roomId).child('authorized_controllers').val()"
          }
        }
      }
    }
  }
}
```

---

## Exemplos de Uso

### Criar uma Sala de Estudo (Host)

```dart
final service = ReadingSyncStudyRoomService(
  client: rtdbClient,
  resolver: verseResolver,
);

// Criar sala
await service.publishShareVerse(
  roomId: 'room-123',
  sessionId: 'session-456',
  verseRef: const VerseReference(
    book: 'John',
    chapter: 3,
    verse: 16,
    version: 'kjv',
  ),
  authorId: currentUserId,
);
```

### Entrar em uma Sala (Participante)

```dart
// Subscribe aos eventos
await service.subscribeToShareEvents('room-123');

// Definir presença
await service.setPresence(
  roomId: 'room-123',
  participantId: currentUserId,
  displayName: 'João',
);

// Ouvir eventos
service.events.listen((event) {
  print('Versículo compartilhado: ${event.verseRef.book}');
});
```

### Aplicar Evento no UI

```dart
// Use ApplyShareEventUseCase para resolver versículo
final result = await useCase(shareEvent);

if (result.success) {
  // Navigar ou scroll para versículo
  scrollToVerse(result.verseRef);
  showHighlight(result.verseRef);
} else {
  // Mostrar erro amigável
  showErrorDialog('Versão da Bíblia não disponível');
}
```

---

## Tratamento de Erros

### Erros Comuns

| Erro | Causa | Solução |
|------|-------|---------|
| `ReadingSyncException: Invalid verse reference` | Versículo não existe | Validar entrada antes de publicar |
| `Timeout after 3 seconds` | Conexão lenta/perdida | Implementar retry com backoff exponencial |
| `Verse version not found` | Versão não instalada | Mostrar fallback e oferecer mapeamento manual |
| `Permission denied` | Não autorizado a escrever | Verificar se é host ou authorized_controller |

### Recuperação Automática

O serviço implementa:
- **Retry com backoff exponencial**: 1s, 2s, 4s (até 3 tentativas)
- **Reconnection automática**: Reconecta ao stream após erro
- **Graceful degradation**: Continua funcionando mesmo se alguma operação falha

### Logging para Debugging

```dart
// Todos os erros são logados automaticamente:
// [2026-01-05T10:30:45.123Z] [ReadingSync] ❌ ERROR: Failed to publish ShareVerse
// [2026-01-05T10:30:45.123Z] [ReadingSync] ⚠ WARNING: Reconnection failed
// [2026-01-05T10:30:45.123Z] [ReadingSync] ✓ ShareVerse published successfully
```

---

## Performance & Latência

### Medição de Latência

A telemetria automática registra:

```dart
telemetry.recordShareVerseLatency(latencyMs);
// Exemplo: 145ms
```

### Otimizações Implementadas

1. **Uso de server timestamps** - Sincroniza com servidor Firebase
2. **Stream subscriptions** - Não usa polling
3. **Local resolution** - Sem chamada remota para resolver versículo
4. **Payload compression** - Eventos mantêm-se < 1KB

### Monitoramento

```bash
# Ver latências no console
flutter logs | grep "ReadingSync.*latency"

# Integração com Firebase Analytics
FirebaseAnalytics.instance.logEvent(
  name: 'share_verse_latency',
  parameters: {'latency_ms': 145},
);
```

---

## Testes

### Testes de Contrato

```bash
flutter test test/features/reading_sync/rtdb_share_event_contract_test.dart
```

Valida:
- Eventos salvos corretamente em RTDB
- Esquema de dados conforme contrato

### Testes de Integração

```bash
flutter test test/features/reading_sync/share_verse_integration_test.dart
```

Valida:
- Fluxo completo: publish → receive → apply
- Resolução local de versículos

### Testes E2E com Emulator

```bash
firebase emulators:start --only database &
flutter test test/features/reading_sync/e2e/share_verse_emulator_test.dart
```

Valida:
- Latência ≤ 2 segundos (95% dos eventos)
- Múltiplos eventos consecutivos
- Comportamento após deixar sala

---

## Descoberta de Salas (Future)

### Listar Salas Públicas

```dart
final publicRooms = await repository.listPublicRooms();
// Retorna: List<StudyRoom> com is_public=true
```

### Entrar em Sala Privada

```dart
// 1. Host marca sala como privada
await service.updateRoomVisibility(roomId, isPublic: false);

// 2. Participante solicita convite
await repository.requestInvite(roomId, participantId);

// 3. Host aprova (via authorized_controllers)
```

---

## Troubleshooting

### Problema: Eventos não chegam ao participante

1. **Verificar conexão**: `adb logcat | grep "firebase"`
2. **Verificar regras RTDB**: Confirmar `auth.uid` está validando
3. **Verificar emulator**: Se usando emulator, confirmar está rodando
4. **Ver logs**: `flutter logs | grep "ReadingSync"`

### Problema: Latência alta (> 2s)

1. Simular latência com Android Emulator:
   ```bash
   adb emu network speed --speed dial-up
   ```
2. Verificar tamanho de payload:
   ```dart
   print('Event size: ${event.toJson().toString().length} bytes');
   ```
3. Considerar reduzir frequência de eventos

### Problema: App crasha com verse não encontrada

1. Habilitar error handling:
   ```dart
   try {
     await useCase(event);
   } catch (e) {
     showErrorUI('Versão não disponível: ${e.message}');
   }
   ```
2. Ofercer mapeamento manual para versão alternativa

---

## Checklist de Implementação

- [x] T001-T007: Setup e Foundational
- [x] T008-T014: User Story 1 - Share Verse
- [x] T030: E2E test com emulator
- [x] T031: Error handling
- [x] T033: Logging
- [x] T034: Este guia
- [ ] T015-T020: User Story 2 - Host Control
- [ ] T021-T026: User Story 3 - Discovery
- [ ] T035-T039: Polish final

---

## Referências

- [Firebase Realtime Database Docs](https://firebase.google.com/docs/database)
- [Flutter Firebase Plugin](https://pub.dev/packages/firebase_database)
- [RTDB Schema & Rules](../specs/015-bible-reading-sync/contracts/)
- [Quickstart](../specs/015-bible-reading-sync/quickstart.md)

---

## Suporte e Feedback

Para problemas ou melhorias:
1. Verificar logs: `flutter logs | grep "ReadingSync"`
2. Abrir issue no repositório com:
   - Descrição do problema
   - Logs relevantes
   - Passos para reproduzir
   - Device/emulator info

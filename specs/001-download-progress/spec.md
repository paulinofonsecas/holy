# Feature Specification: Download Progress Indicator

**Feature Branch**: `[001-download-progress]`  
**Created**: 2026-01-08  
**Status**: Draft  
**Input**: User description: "para melhorar a UX, vamos mostrar um progressbar real, onde se possa saber quanto ja se baixou e quanto resta"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ver progresso do download (Priority: P1)

Usuário vê um indicador determinate ao baixar a Bíblia (ou pacote inicial), com percentual e bytes baixados/restantes.

**Why this priority**: Remove incerteza e evita que o usuário abandone o app achando que travou.

**Independent Test**: Iniciar o app em dispositivo sem cache e verificar se o indicador mostra percentuais de 0% a 100% com bytes baixados/total.

**Acceptance Scenarios**:

1. **Given** app inicia sem dados baixados, **When** o download começa, **Then** exibe barra determinate com 0% e "0 MB de X MB".
2. **Given** download em andamento, **When** parte dos bytes é recebida, **Then** atualiza porcentagem e bytes restantes sem pular para 100%.
3. **Given** download chega ao fim, **When** 100% é alcançado, **Then** barra completa e texto muda para concluído, e o app prossegue automaticamente.

---

### User Story 2 - Rede lenta ou instável (Priority: P2)

Usuário em conexão lenta vê progresso contínuo (sem travar) e consegue retomar após breve queda de rede sem perder o progresso.

**Why this priority**: Reduz frustração em redes móveis e melhora confiança no processo.

**Independent Test**: Simular throttling/queda curta de rede; verificar que o progresso continua do ponto anterior e que a barra não reseta.

**Acceptance Scenarios**:

1. **Given** download em 45%, **When** a rede oscila por poucos segundos, **Then** a barra congela momentaneamente e retoma do mesmo percentual ao recuperar a conexão.
2. **Given** app vai para background e volta, **When** o usuário retorna à tela, **Then** o progresso mostrado corresponde ao valor real persistido (não reinicia).

---

### User Story 3 - Erros e recuperação (Priority: P3)

Usuário recebe mensagem clara em caso de falha e pode tentar novamente sem precisar reiniciar o app; nenhum dado parcialmente baixado corrompe o app.

**Why this priority**: Evita bloqueio na primeira experiência e diminui tickets de suporte.

**Independent Test**: Forçar erro de rede e verificar mensagem com ação de tentar novamente e limpeza segura do estado de download.

**Acceptance Scenarios**:

1. **Given** falha no download, **When** a conexão cai ou o servidor retorna erro, **Then** mostrar mensagem com opção "Tentar novamente" e manter o progresso salvo se possível.
2. **Given** erro recorrente, **When** usuário tenta novamente, **Then** o app não apresenta estado corrompido e, se não for possível retomar, reinicia o download após confirmar.

---

### Edge Cases

- Total do arquivo não informado pelo servidor: exibir spinner apenas até receber cabeçalho ou trocar para contador de bytes já baixados sem percentual.
- Download interrompido por falta de armazenamento: informar que o espaço é insuficiente e não corromper dados existentes.
- Usuário fecha o app durante o download: ao reabrir, retomar de onde parou ou reiniciar com aviso, mantendo consistência do estado.
- Vários downloads sequenciais (por exemplo, múltiplos pacotes): mostrar progresso de cada etapa e progresso geral sem saltos.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Mostrar barra de progresso determinate com valor de 0% a 100% enquanto o download estiver em andamento.
- **FR-002**: Exibir texto com bytes baixados e total (ex.: "12.4 MB de 35.0 MB") e um indicador claro do que já foi baixado e o que resta.
- **FR-003**: Atualizar o progresso visível pelo menos a cada 500 ms enquanto novos bytes forem recebidos.
- **FR-004**: Persistir o estado do download (bytes baixados, total e status) para retomar após background ou fechamento breve do app.
- **FR-005**: Ao completar 100%, substituir a barra por estado "Download concluído" e avançar automaticamente para a próxima etapa da experiência (ex.: abrir conteúdo).
- **FR-006**: Em caso de erro, exibir mensagem com ação de "Tentar novamente" e manter ou reiniciar o download conforme disponibilidade do servidor.
- **FR-007**: Se o total não for conhecido no início, iniciar com spinner e trocar para barra determinate assim que o total for conhecido, sem resetar o valor já baixado.
- **FR-008**: Lidar com múltiplos artefatos se houver (ex.: pacote principal + índices), mostrando progresso agregado e evitando que um artefato oculte o status do outro.

### Key Entities *(include if feature involves data)*

- **DownloadSession**: representa um download em andamento ou retomado; atributos chave: totalBytes, downloadedBytes, status (in-progress, paused, error, completed), lastUpdatedAt, source (URL/endpoint).
- **DownloadArtifact**: item específico a ser baixado (ex.: pacote bíblico, índices); atributos: id, displayName, expectedSizeBytes, sequenceOrder.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Progresso exibido com acurácia de ±5% em relação aos bytes efetivamente recebidos em 95% das medições.
- **SC-002**: Atualizações visuais de progresso ocorrem com intervalo máximo de 0,5 s enquanto houver tráfego de download.
- **SC-003**: Em 95% dos dispositivos testados, o usuário vê percentual e bytes baixados em até 1 s após o início do download.
- **SC-004**: Em testes de rede instável, 90% dos downloads retomam do ponto anterior sem reiniciar; erros exibem mensagem com ação de retry em até 2 s após a falha.

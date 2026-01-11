# Especificação da Funcionalidade: Cache da Bíblia em SQLite

**Branch da Funcionalidade**: `017-bible-sqlite-cache`  
**Criado em**: 01/01/2026  
**Status**: Rascunho  
**Entrada**: Descrição do usuário: "aplicar cache da biblia ao baixar do github, nao mais guardar em file puro"

## Cenários de Usuário e Testes *(obrigatório)*

### Caso de Uso 1 - Primeiro Download da Bíblia (Prioridade: P1)

Como usuário, quero baixar uma versão da Bíblia do GitHub para que ela seja salva diretamente no banco de dados do aplicativo para uso futuro.

**Por que esta prioridade**: Esta é a funcionalidade principal. Sem o download e o cache, o aplicativo não pode funcionar offline ou fornecer acesso rápido ao conteúdo da Bíblia.

**Teste Independente**: Pode ser testado selecionando uma nova versão da Bíblia, observando o progresso do download e verificando se os dados estão presentes no banco de dados SQLite (e não como um arquivo puro).

**Cenários de Aceitação**:

1. **Dado** que o usuário tem conexão com a internet e uma versão da Bíblia ainda não foi baixada, **Quando** o usuário seleciona a versão para baixar, **Então** o sistema baixa os dados do GitHub e os armazena no banco de dados SQLite.
2. **Dado** um download bem-sucedido, **Quando** o sistema termina o processamento, **Então** o usuário é notificado de que a Bíblia está pronta para uso.

---

### Caso de Uso 2 - Acesso Offline à Bíblia (Prioridade: P1)

Como usuário, quero acessar minhas versões baixadas da Bíblia sem conexão com a internet para poder ler a Bíblia em qualquer lugar.

**Por que esta prioridade**: O acesso offline é um requisito fundamental para um aplicativo da Bíblia.

**Teste Independente**: Pode ser testado desativando o acesso à internet e abrindo uma versão da Bíblia baixada anteriormente. O conteúdo deve carregar instantaneamente do cache SQLite.

**Cenários de Aceitação**:

1. **Dado** que uma versão da Bíblia foi baixada anteriormente e armazenada em cache no SQLite, **Quando** o usuário abre o aplicativo sem internet, **Then** o sistema carrega o conteúdo da Bíblia do banco de dados local.

---

### Caso de Uso 3 - Gerenciamento de Cache (Prioridade: P2)

Como usuário, quero saber quais versões da Bíblia já estão em cache para poder gerenciar o armazenamento do meu dispositivo.

**Por que esta prioridade**: Ajuda os usuários a entender o que está ocupando espaço e garante que eles não baixem dados desnecessariamente.

**Teste Independente**: Pode ser testado visualizando a lista de versões disponíveis da Bíblia e vendo um indicador de "Baixado" ou "Em Cache" ao lado daquelas armazenadas no SQLite.

**Cenários de Aceitação**:

1. **Dado** que várias versões da Bíblia estão disponíveis, **Quando** o usuário visualiza a lista de versões, **Então** o sistema destaca quais versões já estão armazenadas no cache SQLite local.

---

### Casos de Borda

- **Interrupção do Download**: Se a conexão com a internet for perdida durante o download, o sistema DEVE lidar com os dados parciais de forma graciosa e permitir que o usuário retome ou reinicie o download sem corromper o banco de dados.
- **Armazenamento Cheio**: Se o armazenamento do dispositivo estiver cheio, o sistema DEVE notificar o usuário e interromper o processo de cache.
- **Cache Corrompido**: Se os dados no SQLite se tornarem ilegíveis, o sistema DEVE permitir que o usuário baixe a versão novamente.

## Requisitos *(obrigatório)*

### Requisitos Funcionais

- **FR-001**: O sistema DEVE baixar os dados da Bíblia (livros, capítulos, versículos) do provedor GitHub.
- **FR-002**: O sistema DEVE converter os dados baixados para um formato compatível com o esquema SQLite.
- **FR-003**: O sistema DEVE armazenar todo o conteúdo da Bíblia baixado diretamente nas tabelas SQLite.
- **FR-004**: O sistema NÃO DEVE salvar o conteúdo da Bíblia como arquivos de texto simples ou JSON no sistema de arquivos do dispositivo.
- **FR-005**: O sistema DEVE verificar o banco de dados SQLite quanto à existência de uma versão da Bíblia antes de tentar um download pela rede.
- **FR-006**: O sistema DEVE garantir a integridade dos dados durante o processo de inserção (por exemplo, usando transações).


### Entidades Chave *(incluir se a funcionalidade envolver dados)*

- **Versão da Bíblia**: Representa uma tradução específica (ex: NVI, Almeida). Atributos: ID, Nome, Idioma, Status do Cache.
- **Livro**: Representa um livro da Bíblia. Atributos: ID, Nome, Abreviação, ID da Versão.
- **Capítulo**: Representa um capítulo dentro de um livro. Atributos: Número, ID do Livro.
- **Versículo**: Representa um único versículo. Atributos: Número, Texto, ID do Capítulo.

## Critérios de Sucesso *(obrigatório)*

- **SC-001**: 100% do conteúdo da Bíblia baixado é armazenado no SQLite, com zero arquivos puros criados para armazenamento de conteúdo.
- **SC-002**: Os usuários podem acessar as versões da Bíblia em cache em menos de 500ms quando offline.
- **SC-003**: O sistema identifica corretamente as versões "Em Cache" vs "Não Baixadas" na interface do usuário.
- **SC-004**: Uma versão completa da Bíblia (aprox. 31.000 versículos) é armazenada em cache com sucesso em menos de 30 segundos (excluindo o tempo de download) em hardware móvel padrão.

## Premissas

- O `GithubBibleProvider` retorna dados em um formato estruturado (ex: JSON) que inclui toda a hierarquia necessária (Livros -> Capítulos -> Versículos).
- O `DatabaseHelper` existente e a configuração do SQLite são capazes de lidar com o volume de dados necessário para várias versões da Bíblia.
- O usuário tem permissões suficientes para gravar no diretório do banco de dados do aplicativo.


- **[Entity 2]**: [What it represents, relationships to other entities]

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g., "Users can complete account creation in under 2 minutes"]
- **SC-002**: [Measurable metric, e.g., "System handles 1000 concurrent users without degradation"]
- **SC-003**: [User satisfaction metric, e.g., "90% of users successfully complete primary task on first attempt"]
- **SC-004**: [Business metric, e.g., "Reduce support tickets related to [X] by 50%"]

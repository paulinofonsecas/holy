import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../feedback/views/about_view.dart';
import 'tutorial_detail_page.dart';

class TutorialItem {
  final String title;
  final String description;
  final IconData icon;
  final String? markdownContent;
  final WidgetBuilder? routeBuilder;

  TutorialItem({
    required this.title,
    required this.description,
    required this.icon,
    this.markdownContent,
    this.routeBuilder,
  });
}

class TutorialsListPage extends StatelessWidget {
  const TutorialsListPage({super.key});

  List<TutorialItem> _getTutorials(BuildContext context) {
    return [
      TutorialItem(
        title: 'Bíblia',
        description:
            'Aprenda a navegar, trocar versões e usar o modo de leitura.',
        icon: CupertinoIcons.book,
        markdownContent: '''
# Guia de Leitura da Bíblia

A aba **Bíblia** é o coração do aplicativo. Aqui está como aproveitar ao máximo:

### 1. Navegação
- **Mudar Livro/Capítulo**: Toque na barra superior onde aparece o nome do livro e capítulo atual. Um menu se abrirá para você selecionar o Testamento, Livro e Capítulo desejado.
- **Próximo/Anterior**: Deslize para a esquerda ou direita para mudar de capítulo, ou use as setas na parte inferior (se habilitadas).

### 2. Versões
- Toque no ícone de tradução (ex: NVI, ARA) no topo da tela para alternar entre as versões disponíveis.
- Você pode baixar novas versões para leitura offline.

### 3. Interação com Versículos
Toque em qualquer versículo para abrir o **Menu de Ações**:
- **Marcar**: Destaque o versículo com uma cor.
- **Copiar**: Copie o texto para a área de transferência.
- **Compartilhar**: Crie uma imagem bonita ou compartilhe o texto.
- **Estudar (IA)**: Receba uma análise profunda do versículo.

### 4. Configurações de Leitura
Toque no ícone de "Aa" para ajustar o tamanho da fonte, brilho e modo de leitura.
''',
      ),
      TutorialItem(
        title: 'Pesquisa',
        description: 'Como encontrar versículos e temas específicos.',
        icon: CupertinoIcons.search,
        markdownContent: '''
# Pesquisa Avançada

Encontre qualquer passagem rapidamente com nossa ferramenta de busca.

### Como Pesquisar
1. Vá para a aba **Pesquisa** (ícone de lupa).
2. Digite uma palavra-chave, frase ou referência (ex: "amor", "Salmos 23").
3. Os resultados aparecerão instantaneamente.

### Filtros
- **Testamento**: Filtre por Velho ou Novo Testamento.
- **Livros**: Restrinja a busca a um livro específico.

### Histórico
Suas últimas pesquisas ficam salvas para acesso rápido. Basta tocar em um termo anterior para pesquisar novamente.
''',
      ),
      TutorialItem(
        title: 'Estudos',
        description: 'Entenda profundamente a palavra com auxílio de IA.',
        icon: Icons.auto_awesome,
        markdownContent: '''
# Estudos e Deep Understanding

A funcionalidade **Estudos** utiliza inteligência artificial para trazer clareza e profundidade à sua leitura.

### Como usar
1. Ao ler a Bíblia, toque em um versículo.
2. Selecione a opção **Estudar** ou o ícone de brilho.
3. A IA analisará o versículo trazendo:
   - **Contexto Histórico**: Quem escreveu, para quem e quando.
   - **Significado Teológico**: Explicação dos termos originais.
   - **Aplicação Prática**: Como aplicar isso na sua vida hoje.
   - **Referências Cruzadas**: Versículos relacionados.

### Histórico de Estudos
Todos os seus estudos ficam salvos na aba **Estudos** (terceira aba na barra de navegação) para você revisitar a qualquer momento.
''',
      ),
      TutorialItem(
        title: 'Versículos Marcados',
        description: 'Gerencie seus destaques e versículos favoritos.',
        icon: Icons.bookmark,
        markdownContent: '''
# Versículos Marcados

Mantenha seus versículos favoritos organizados.

### Como Marcar
- Toque em um versículo na leitura e selecione uma cor de destaque.
- O versículo será sublinhado ou destacado na sua leitura.

### Acessando seus Marcadores
1. Vá para a aba **Perfil**.
2. Toque em **Versículos Marcados**.
3. Aqui você vê todos os seus destaques organizados por cor e data.
4. Toque em um item para ir diretamente para a passagem na Bíblia.
''',
      ),
      TutorialItem(
        title: 'Histórico de Versículos',
        description: 'Revisite versículos lidos recentemente.',
        icon: Icons.history,
        markdownContent: '''
# Histórico de Leitura

Esqueceu onde estava lendo? O Histórico ajuda você a retomar.

### Acessando o Histórico
1. Vá para a aba **Perfil**.
2. Toque em **Histórico de Versículos**.
3. Uma lista dos últimos versículos que você interagiu ou leu será exibida.

Isso é útil para continuar um estudo de onde parou ou relembrar uma passagem que tocou seu coração recentemente.
''',
      ),
      TutorialItem(
        title: 'Versículo do Dia',
        description: 'Inspiração diária e configurações de notificação.',
        icon: Icons.notifications_active,
        markdownContent: '''
# Versículo do Dia

Comece o seu dia com uma palavra de inspiração.

### Funcionamento
- Todos os dias, um novo versículo é selecionado para você.
- Você pode visualizá-lo na tela inicial ou através da notificação.

### Configurações
1. Vá para a aba **Perfil**.
2. Toque em **Versículo do Dia**.
3. Aqui você pode:
   - **Ativar/Desativar** notificações.
   - **Definir o Horário** que deseja receber a mensagem.
   - **Escolher a Versão** bíblica preferida para o versículo diário.
''',
      ),
      TutorialItem(
        title: 'Customização',
        description: 'Personalize o tema e aparência do aplicativo.',
        icon: Icons.palette,
        markdownContent: '''
# Personalização e Temas

Deixe o aplicativo com a sua cara e confortável para sua visão.

### Cores e Tema
1. Vá para a aba **Perfil**.
2. Toque em **Cores e Tema**.

### Opções Disponíveis
- **Modo Escuro/Claro**: Escolha entre o tema claro (ideal para o dia) ou escuro (confortável para a noite), ou deixe automático conforme o sistema.
- **Cor de Destaque**: Selecione a cor principal do aplicativo (botões, ícones, destaques).
- **Tipografia**: Em breve, opções de fonte estarão disponíveis aqui.
''',
      ),
      TutorialItem(
        title: 'Sobre o App',
        description: 'Conheça nossa missão, equipe e comunidade.',
        icon: Icons.info_outline,
        routeBuilder: (context) => const AboutView(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tutorials = _getTutorials(context);

    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              title: const Text('Central de Ajuda'),
              centerTitle: true,
            ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tutorials.length,
        separatorBuilder: (context, index) => const Gap(12),
        itemBuilder: (context, index) {
          final item = tutorials[index];
          return _buildTutorialCard(context, item);
        },
      ),
    );
  }

  Widget _buildTutorialCard(BuildContext context, TutorialItem item) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          if (item.routeBuilder != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: item.routeBuilder!),
            );
          } else if (item.markdownContent != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TutorialDetailPage(
                  title: item.title,
                  content: item.markdownContent!,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Gap(4),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

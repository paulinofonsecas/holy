# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1+24] - 2026-02-16

### ✨ Novas Funcionalidades
- **Navegação Flutuante Animada**: Novos botões laterais para avançar e recuar capítulos com animação de "hint" horizontal.
- **Auto-Ocultar Inteligente**: Botões de navegação desaparecem automaticamente durante o scroll ou após 5 segundos de inatividade.
- **Configurações de Leitura em Tempo Real**: Novo painel para ajustar tamanho da fonte, entrelinha, espaçamento de letras e alinhamento (Justificado por padrão).
- **Suporte a Google Fonts**: Agora é possível escolher entre fontes locais e uma seleção das melhores Google Fonts (Roboto, Montserrat, Poppins, etc).
- **Persistência de Scroll**: O aplicativo agora lembra exatamente onde você parou em cada capítulo da Bíblia e na tela de busca, mesmo após fechar o app.

### 🎨 Design e UI/UX
- **AppBar Responsiva**: O seletor de livros e busca agora se ajustam dinamicamente para evitar sobreposição em telas menores.
- **Novo Ícone de Formatação**: Adicionado ícone de texto na barra superior para acesso rápido às configurações de leitura.

### 🐞 Correções e Melhorias
- **Fix na Busca**: Corrigido erro onde o campo de busca desaparecia em certos estados de carregamento ou erro.
- **Filtro de Versão**: Corrigida a lógica de filtragem por versão quando a busca global (todas as versões) está ativa.
- **Estabilidade de Scroll**: Resolvido crash de "Multiple ScrollControllers" na tela de busca.

## [1.0.1+22] - 2026-02-16

### ✨ Novas Funcionalidades
- **Seleção Múltipla de Resultados**: Agora é possível selecionar vários versículos na tela de busca (pressão longa) para ações em massa.
- **Exportação Profissional**: Adicionada a capacidade de exportar resultados de busca para **PDF**, **Markdown (.md)** e **Texto (.txt)**.
- **Títulos de Exportação Contextuais**: Arquivos exportados agora incluem o termo da busca, data e hora da geração.
- **Pesquisa Randômica (Inspiração)**: Novo botão "Descobrir Novo Versículo" que seleciona termos bíblicos aleatórios para inspiração diária.
- **Sugestão de Busca Avançada**: Card inteligente que sugere a Pesquisa Avançada quando termos compostos não retornam resultados exatos.
- **Navegação Fluida**: Implementado "Scroll to Top" ao tocar na barra de status do dispositivo na tela de busca.

### 🎨 Design e UI/UX
- **Campo de Busca Moderno**: Redesign completo do `SearchInputBar` com bordas de 14px, fundo sutil e ícones otimizados.
- **Animações de Entrada**: O `ActionRowWidget` (barra de ações de versículos) agora possui transições suaves de fade e slide ao entrar/sair.
- **Checkbox Compacto**: Otimização do seletor de versões para um layout mais limpo e profissional.

### 🐞 Correções e Melhorias
- **Suporte Unicode no PDF**: Correção de erro de fontes ao exportar versículos com aspas ou caracteres especiais, utilizando fontes TrueType locais.
- **Otimização de Exportação**: O botão de exportar agora é visível por padrão, permitindo exportar todos os resultados ou apenas os selecionados.

## [1.0.1+20] - 2026-02-16

### ✨ Novas Funcionalidades
- **Criador de Imagens Inteligente**: Agora textos longos são automaticamente divididos em várias imagens (carrossel) para garantir legibilidade.
- **ToastService Global**: Sistema de notificações elegante e customizado para feedbacks de sucesso, erro e alertas em todo o app.
- **Busca na Seleção de Livros**: Nova barra de pesquisa com suporte a termos sem acento (ex: "joao" -> "João") e otimização de performance para listagens grandes.
- **Página de Seleção de Livros**: O seletor de livros agora é uma página completa com animação fluida e interface aprimorada.
- **Tutorial Interativo**: Exibição automática do guia de uso apenas na primeira abertura do aplicativo.
- **Cópia Avançada**: Função de copiar versículos agora inclui referência completa e formatação profissional.

### 🚀 Otimizações de Performance
- **Zero "Flicker" no Boot**: Unificação de loaders. O app agora inicia diretamente no Splash Nativo e transiciona sem telas brancas para a tela principal.
- **Lazy Loading de Capítulos**: Livros na lista de seleção só carregam seus capítulos quando expandidos, economizando memória e CPU.
- **Boot Precoce**: Inicialização de Firebase, DB e Tema movida para a fase de pré-execução (main).

### 🐞 Correções e Melhorias
- **Robustez em Notificações**: Adicionado tratamento de erros global para serviços de notificação Android, evitando crashes por falta de ícones ou permissões.
- **Estabilidade de Navegação**: Correção de erros de contexto (unmounted) ao alternar rapidamente entre modais de comparação.
- **Layout de Imagens**: Nova lógica de dimensionamento automático (FittedBox) garante que o texto nunca ultrapasse os limites do card.

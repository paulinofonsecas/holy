# Changelog

All notable changes to this project will be documented in this file.

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

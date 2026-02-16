# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1+20] - 2026-02-16

### ✨ Novas Funcionalidades
- **ToastService Global**: Implementação de um serviço de notificações estilizadas (Sucesso, Info, Alerta, Erro) acessível de qualquer parte do app sem necessidade de contexto manual.
- **Página de Seleção de Livros**: O antigo modal foi convertido na `BookSelectionPage`, uma tela completa com animação de deslize (Slide Up) e interface otimizada para navegação entre livros e capítulos.
- **Copiar Versículos**: Implementada a função de cópia formatada para a área de transferência, incluindo números dos versículos, texto e referência completa com versão.
- **Lógica de Tutorial Inteligente**: O tutorial interativo agora é disparado automaticamente apenas na primeira abertura do aplicativo, persistindo o estado via `SharedPreferences`.

### 🚀 Otimizações de Performance
- **Inicialização Fluida**: Migração da carga pesada de serviços (Firebase, Banco de Dados, Preferências e Tema) para a fase de boot nativa, eliminando os múltiplos loaders genéricos que apareciam na inicialização.
- **Sincronia de Tema**: O sistema de temas agora é carregado antes do `runApp()`, evitando o "flash" ou troca perceptível de cores durante a abertura.
- **Splash Integrado**: Uso do `FlutterNativeSplash` para segurar a tela de abertura até que todos os recursos essenciais estejam prontos para uso.

### 🐞 Correções e Melhorias
- **Notificações Android**: Melhoria na robustez com blocos `try-catch` em todas as chamadas de notificação, evitando crashes por falhas de recursos nativos e exibindo feedback visual via Toast quando o serviço estiver indisponível.
- **Notificações Android (Ícones)**: Correção de crash (`PlatformException`) ao inicializar e exibir notificações devido à ausência do ícone de recurso nas pastas `drawable`.
- **Estabilidade em Modais**: Correção do erro *"Looking up a deactivated widget's ancestor"* ao abrir o modal de comparação de versões, através da captura prévia de instâncias do `IBibleRepository`.
- **Interface de Seleção**: Adição de botões de fechamento explícitos e melhor espaçamento (padding) para evitar sobreposição com barras de sistema.
- **Limpeza de Código**: Unificação de chaves de preferência (`tutorialShownKey`) e remoção de imports duplicados no ponto de entrada principal (`main.dart`).

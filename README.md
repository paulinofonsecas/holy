# Holy - Eu Sou

A modern Bible application built with Flutter, focusing on speed, offline access, and user experience.

![coverage][coverage_badge]
[![License: MIT][license_badge]][license_link]

# Guia do Usuário - Holy App

Bem-vindo ao guia oficial do usuário do Holy App. Este documento ajudará você a aproveitar ao máximo todas as funcionalidades do aplicativo .

---

## Sumário

1. [Introdução](#introdução)
2. [Primeiros Passos](#primeiros-passos)
3. [Lendo a Bíblia](#lendo-a-bíblia)
4. [Pesquisando Versículos](#pesquisando-versículos)
5. [Gerenciando Downloads](#gerenciando-downloads)
6. [Perfil e Configurações](#perfil-e-configurações)
7. [Resolução de Problemas (FAQ)](#resolução-de-problemas-faq)

---

## Introdução

O Holy App é um aplicativo bíblico moderno focado em velocidade, acesso offline e uma experiência de leitura limpa.

---

## Primeiros Passos

Para começar a usar o Holy App:

1. **Escolha uma Versão**: Ao abrir o app pela primeira vez, você poderá selecionar sua versão bíblica preferida.
2. **Navegação**: Use a barra inferior para alternar entre a Leitura, Pesquisa e seu Perfil.

---

## Lendo a Bíblia

A tela principal de leitura permite que você mergulhe na Palavra:

- **Seleção de Livro e Capítulo**: Toque no nome do livro no topo para abrir o seletor.
- **Rolagem Fluida**: Leia os versículos de forma contínua.
- **Troca de Versão**: Alterne rapidamente entre as versões baixadas usando o seletor de versão.
- **Marcar Versículos**: Toque e segure em um versículo para marcá-lo. Ele ficará salvo na sua tela de Perfil.

---

## Pesquisando Versículos

Encontre exatamente o que você procura:

- **Palavras-chave**: Digite termos como "amor", "fé" ou "esperança" para ver todos os versículos relacionados.
- **Filtros**: Refine sua busca por Testamento (Antigo ou Novo) ou por livros específicos.
- **Histórico**: O app mantém suas buscas recentes para facilitar o acesso. Você pode visualizar e limpar seu histórico na tela de Perfil.

---

## Gerenciando Downloads

O Holy App funciona offline. Para isso:

- **Baixar Versões**: Vá em configurações e escolha as versões que deseja baixar para uso sem internet.
- **Gerenciar Espaço**: Você pode remover versões baixadas a qualquer momento para liberar espaço no dispositivo.

---

## Perfil e Configurações

Personalize sua experiência na tela "EU":

- **Versículos Marcados**: Acesse rapidamente todos os versículos que você salvou durante a leitura.
- **Histórico de Pesquisas**: Veja suas buscas recentes e limpe-as se desejar.
- **Personalização de Cores**: Mude a cor de destaque do aplicativo para combinar com seu estilo.
- **Temas**: Escolha entre o modo claro ou escuro.
- **Tamanho da Fonte**: Ajuste o tamanho do texto para uma leitura mais confortável.
- **Sincronização em Nuvem** _(Em Breve)_: Em futuras atualizações, você poderá sincronizar suas preferências e histórico entre dispositivos.

---

## Resolução de Problemas (FAQ)

**P: O download da versão falhou. O que fazer?**
R: Verifique sua conexão com a internet e se há espaço suficiente no dispositivo. Tente reiniciar o download nas configurações.

**P: Como mudo o idioma do aplicativo?**
R: O app segue o idioma do seu sistema. Você pode alterar as preferências de idioma nas configurações do seu dispositivo.

**P: Minhas buscas não retornam resultados.**
R: Certifique-se de que as palavras estão escritas corretamente ou tente termos mais genéricos. Verifique também se os filtros aplicados não estão restringindo demais a busca.

---

_Última atualização: 02 de Janeiro de 2026_

## Project Overview

Holy is a monorepo project that provides a comprehensive Bible reading and study experience. It features offline caching, verse search, and user profile management.

## Documentation

- [Setup Guide](./doc/SETUP_GUIDE.md): Detailed environment setup for Windows and macOS.
- [User Guide](./doc/USER_GUIDE.md): Official guide for end-users.
- [Architecture Overview](./doc/ARCHITECTURE.md): High-level system design and C4 Model (C4-PlantUML).
- [Feature Index](./specs/README.md): Detailed specifications for all application features.
- [Specification Guide](./doc/SPECIFICATION_GUIDE.md): How to document new features.
- [Firebase Distribution Guide](./doc/firebase-distribution-guide.md): How to distribute test versions.
- [Microsoft Clarity Setup](./doc/CLARITY_SETUP.md): How to configure user behavior analytics.

## Monorepo Structure

This project is organized as a monorepo to separate core logic from the UI layer:

- **`lib/`**: The main Flutter application (Holy - Eu Sou).
- **`packages/bible_handler/`**: Core package for Bible parsing, SQLite caching, and searching.
- **`specs/`**: Feature specifications and design documents.
- **`doc/`**: Technical documentation and architecture guides.

## 🚀 Quick Start

1. **Prerequisites**: [Flutter SDK](https://docs.flutter.dev/get-started/install), [Git](https://git-scm.com/downloads).
2. **Setup**:
   ```bash
   git clone https://github.com/paulinofonsecas/holy.git
   cd holy
   cp .env.example .env
   ```
3. **Initialize**:
   ```bash
   flutter pub get
   cd packages/bible_handler && flutter pub get && cd ../..
   ```
4. **Run**: `flutter run`

For detailed setup instructions for **Windows** and **macOS**, see the **[Setup Guide](./doc/SETUP_GUIDE.md)**.

### Architecture Visualization

To view the C4 architecture diagrams, open the `.puml` files in [doc/architecture/](./doc/architecture/) in VS Code with the **PlantUML** extension installed and press `Alt + D`.

---

Generated by [Flutter Bunny CLI][flutter_bunny_cli_link]

[coverage_badge]: https://img.shields.io/badge/coverage-80%25-green
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[flutter_bunny_cli_link]: https://github.com/paulinofonsecas/flutter_bunny
[flutter_bunny_cli_guide_link]: https://github.com/paulinofonsecas/flutter_bunny/blob/main/GUIDE.md

<!--
Sync Impact Report:
- Version change: 1.0.0 -> 1.1.0
- List of modified principles:
  - Added: VI. Consistent Navigation (Bottom Bar)
- Added sections: None
- Removed sections: None
- Templates requiring updates:  updated (checked, no changes needed as they are generic)
- Follow-up TODOs: None
-->

# Eu Sou Constitution

## Core Principles

### I. Monorepo & Modularization
The project follows a monorepo structure. Core business logic and shared functionality must be encapsulated in standalone packages (e.g., \packages/bible_handler\). The main application (\eu_sou\) acts as a consumer of these packages. This ensures separation of concerns and facilitates code reuse.

### II. Bible Version Abstraction
All access to Bible texts and versions must be mediated through the \ible_handler\ package. The application layer must not contain logic for parsing Bible files or managing version differences directly. This abstraction allows for seamless addition of new versions and sources without modifying the UI.

### III. AI-Ready Architecture
The system architecture must be designed to accommodate future AI integration. This implies maintaining clean data interfaces, well-structured data models, and separation of data retrieval from presentation. Components should be extensible to support AI-driven features like semantic search or personalized insights.

### IV. Flutter Best Practices
Adhere to established Flutter development patterns. Use BLoC or MVVM (via \stacked\) for state management as established in the project dependencies. Ensure the UI is responsive, accessible, and follows Material Design guidelines where appropriate.

### V. Test-Driven Development
Critical logic, especially within internal packages like \ible_handler\, must be tested. Write unit tests for data parsing and business logic. Integration tests should verify the interaction between the app and its internal packages.

### VI. Consistent Navigation (Bottom Bar)
The application MUST use a Bottom Navigation Bar for primary top-level navigation (Reading, Search, Profile). This ensures a consistent and accessible user experience across all screens. Top-level screens MUST be reachable within a single tap from the bottom bar.

## Governance

### Amendment Process
This constitution supersedes all other project practices. Amendments require a pull request with a clear rationale and must be approved by the project maintainers.

### Compliance
All code reviews must verify compliance with these principles. Deviations must be justified and documented.

**Version**: 1.1.0 | **Ratified**: 2026-01-01 | **Last Amended**: 2026-01-02
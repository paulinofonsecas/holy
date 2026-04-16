# Coding Conventions

**Analysis Date:** 2026-04-16

## Overview

This codebase uses Flutter with Dart and follows established Flutter patterns. Linting is configured in `analysis_options.yaml` at the project root, which extends `flutter_lints` with additional const/final preferences.

## Naming Patterns

**Files:**
- Pattern: `snake_case.dart`
- Examples: `biblia_bloc.dart`, `screen_reader_page.dart`, `local_notification_service.dart`
- Enforced by: `file_names` lint rule in `analysis_options.yaml`

**Directories:**
- Pattern: `snake_case` (lowercase with underscores)
- Example: `lib/features/biblia/bloc/`, `lib/core/services/`

**Classes:**
- Pattern: `PascalCase`
- Examples: `BibliaBloc`, `LocalNotificationService`, `ScreenReaderPage`

**Functions/Methods:**
- Pattern: `camelCase`
- Examples: `addOnNotificationTapListener`, `saveReadingPosition`, `_onGetChapter`

**Variables:**
- Pattern: `camelCase`
- Private variables prefixed with underscore: `_scrollPersistenceService`, `_bibleRepository`

**Constants:**
- Pattern: `camelCase` or `kCamelCase` (for Flutter constants)
- Example: `const Duration(milliseconds: 500)`

## Code Style

**Formatting Tool:**
- Uses `flutter_lints` as the base linting configuration
- No explicit formatting tool (e.g., dartfmt or flutter format runs in CI)

**Active Lint Rules:**
From `analysis_options.yaml`:

```yaml
linter:
  rules:
    - prefer_const_constructors          # Use const constructors where possible
    - prefer_const_literals_to_create_immutables  # const for List/Map literals
    - prefer_const_declarations       # Use const for compile-time constants
    - prefer_final_fields             # Use final for instance fields
    - use_super_parameters           # Use super in extends clauses
    - file_names                      # Enforce snake_case file names
    - avoid_unnecessary_containers    # Avoid wrapping widgets unnecessarily
    - avoid_print                     # Avoid print statements
```

**Analyzer Settings:**
```yaml
analyzer:
  errors:
    invalid_return_type_for_catch_error: ignore
    depend_on_referenced_packages: ignore
    deprecated_member_use: ignore
  exclude:
    - "*.md"
    - "lib/gen/**"
    - "lib/core/localization/generated/**"
```

## Import Organization

**Order (observed patterns):**

1. **Dart built-ins** (`dart:`)
   ```dart
   import 'dart:async';
   import 'dart:developer';
   ```

2. **External packages** (`package:`)
   ```dart
   import 'package:bloc/bloc.dart';
   import 'package:flutter/material.dart';
   import 'package:equatable/equatable.dart';
   import 'package:google_fonts/google_fonts.dart';
   ```

3. **Internal packages** (`package:`)
   ```dart
   import 'package:eu_sou/core/services/scroll_persistence_service.dart';
   import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
   ```

4. **Relative imports** (within same package)
   ```dart
   import '../widgets/biblia_app_bar.dart';
   import 'reading_settings_state.dart';
   ```

5. **Part files**
   ```dart
   part 'biblia_event.dart';
   part 'biblia_state.dart';
   ```

**Path Aliases:**
- Uses `package:` specifier for all internal imports (not relative paths)
- Example: `import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';`

## Error Handling

**Patterns:**

1. **Try-catch with emit pattern** (BLoC pattern):
   ```dart
   try {
     final result = await _bibleRepository.getChapter(...);
     emit(BibleChapterLoaded(result, ...));
   } catch (e) {
     emit(state);
     emit(BibleError(e.toString()));
   }
   ```

2. **CatchError for Fire-and-forget:**
   ```dart
   _bibleRepository.getChapter(...).catchError((_) => null);
   ```

3. **Null-safe checks:**
   ```dart
   if (parsedChapter == null || parsedChapter <= 0) {
     developer.log('Invalid request: ${event.book}', name: 'BibliaBloc');
     return;
   }
   ```

## Logging

**Framework:** `dart:developer` (imported as `developer`)

**Pattern:**
```dart
developer.log(
  'Ignoring invalid chapter restore request: ${event.book} ${event.chapter}',
  name: 'BibliaBloc',
);
```

**Notes:**
- `avoid_print` lint is enabled, so avoid using `print()` statements
- Use `developer.log()` for development debugging

## Comments

**When to Comment:**
- Use `@meta` annotations for BLoC documentation:
  ```dart
  import 'package:meta/meta.dart';

  /// Describes an event that triggers chapter loading
  @immutable
  class GetChapter extends BibliaEvent {
    final String version;
    final String book;
    final String chapter;
    // ...
  }
  ```

**State Classes:**
- Use Equatable for value equality:
  ```dart
  import 'package:equatable/equatable.dart';

  abstract class BibliaState extends Equatable {
    const BibliaState();
  }
  ```

## Function Design

**BLoC Pattern Guidelines:**

1. **Event handlers follow naming:** `_on<EventName>`
   ```dart
   on<GetChapter>(_onGetChapter, transformer: ...);
   ```

2. **Transformers for debounce/throttle:**
   ```dart
   transformer: (events, mapper) => events.debounce(const Duration(milliseconds: 500)).switchMap(mapper),
   transformer: (events, mapper) => events.switchMap(mapper),
   ```

3. **State immutability:** Use final fields with copyWith patterns:
   ```dart
   emit(BibleChapterLoaded(
     currentState.chapter,
     versionId: currentState.versionId,
     targetVerse: event.verse,
   ));
   ```

**Constructor Syntax:**
- Use super parameters (enabled by lint):
  ```dart
  // Instead of:
  // BibliaBloc(IBibleRepository repository, ScrollPersistenceService scrollService)
  //     : super(BibliaInitial());

  // Use:
  BibliaBloc(super.bibleRepository, super.scrollPersistenceService)
      : super(BibliaInitial());
  ```

**Const Usage:**
- Use const where possible:
  ```dart
  const BibliaLoading(versionId: 'KJA')
  const Duration(milliseconds: 500)
  ```

## Module Design

**BLoC Exports:**
- Export main class: `BibliaBloc`
- Export events: Part file `biblia_event.dart`
- Export states: Part file `biblia_state.dart`

**Pattern:**
```dart
// biblia_bloc.dart
part 'biblia_event.dart';
part 'biblia_state.dart';

class BibliaBloc extends Bloc<BibliaEvent, BibliaState> { ... }
```

**Directory Structure:**
```
lib/features/<feature>/
├── bloc/              # BLoC/Cubit logic
├── data/              # Repositories, data sources
├── presentation/     # UI (views, pages, widgets)
├── modals/            # Modal dialogs
└── widgets/           # Reusable widgets
```

**Core vs Features:**
- `lib/core/` - Cross-cutting services, design system, localization
- `lib/features/` - Feature-specific modules
- `lib/shared/` - Shared models, cubits

## State Management

**Primary:** `flutter_bloc` / `bloc`

**Secondary:** `hydrated_bloc` for persistence

**Pattern:**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SomeBloc extends HydratedBloc<SomeEvent, SomeState> { ... }
```

## Database/Storage

**Primary:** `sqflite` (SQLite)

**Secondary:** `shared_preferences` (simple key-value), `objectbox` (NoSQL)

---

*Convention analysis: 2026-04-16*
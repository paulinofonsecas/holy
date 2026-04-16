# Architecture

**Analysis Date:** 2026-04-16

## Pattern Overview

**Overall:** Feature-based Clean Architecture with BLoC state management

This Flutter app follows a feature-based Clean Architecture pattern with clear separation between domain, data, and presentation layers. The architecture emphasizes:
- Feature modules as the primary code organization unit
- BLoC pattern for state management with optional Cubit for simpler use cases
- Repository pattern with interfaces for data access abstraction
- Cross-cutting services centralized in `lib/core/`

## Layers

### Feature Layer (`lib/features/`)

**Purpose:** Self-contained feature modules with domain, data, and presentation layers

**Structure per feature:**
```
features/<feature_name>/
├── data/              # Data layer - repositories, services, models
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/            # Domain layer - entities, interfaces
│   ├── models/
│   └── repositories/
├── presentation/      # Presentation layer - UI, blocs, cubits, widgets
│   ├── bloc/
│   ├── cubit/
│   ├── pages/
│   └── widgets/
└── views/             # Alternative entry point (some features)
```

**Examples:**
- `lib/features/biblia/` - Bible reading with Bloc pattern
- `lib/features/daily_growth/` - Daily reminders with Cubit pattern
- `lib/features/search/` - Search with Bloc pattern
- `lib/features/eu_sou/` - User profile with Bloc pattern
- `lib/features/profile/` - History/marked verses with Bloc pattern

### Core Layer (`lib/core/`)

**Purpose:** Cross-cutting concerns used across features

**Location:** `lib/core/`

**Contains:**
- **data/** - Database helper, providers, repositories
- **services/** - AIDeeplinkService, ScrollPersistenceService, etc.
- **notifications/** - Local and push notifications
- **localization/** - Localization and internationalization
- **design_system/** - Themes, colors, typography
- **network/** - API client, interceptors
- **error/** - Error handling, failures
- **deeplinks/** - Deep link handling

### Shared Layer (`lib/shared/`)

**Purpose:** Shared UI components and cross-feature state

**Location:** `lib/shared/`

**Contains:**
- `cubit/` - Shared state (BibleVersionCubit, TabControllerCubit)
- `widgets/` - Reusable widgets (MainScaffold, LoadingWidget)
- `bible_models.dart` - Shared Bible data models

**Key files:**
- `lib/shared/cubit/bible_version_cubit.dart` - Bible version selection state
- `lib/shared/cubit/tab_controller_cubit.dart` - Tab navigation state
- `lib/shared/widgets/main_scaffold.dart` - Common app scaffold

### Package Layer (`packages/bible_handler/`)

**Purpose:** Separately versioned package for Bible data handling

**Location:** `packages/bible_handler/lib/`

**Contains:**
- `src/models/` - Bible, Chapter, Verse, Book, SearchResult models
- `src/parsers/` - USX and SQLite parsers
- `src/services/` - Download, WebDatabaseLoader
- `src/sorting/` - Book ordering strategies
- `src/bible_cache_provider.dart` - Caching layer
- `src/bible_search_provider.dart` - Search implementation
- `src/verse_interaction_provider.dart` - Highlights/interactions

## Data Flow

### Bible Reading Flow:
1. User selects book/chapter → BLoC event triggered
2. `BibliaBloc` receives `GetChapter` event
3. Calls `IBibleRepository.getChapter()`
4. Repository delegates to `GithubBibleProvider`
5. Provider checks cache → fetches from network if needed
6. Data returned through repository to BLoC
7. BLoC emits `BibleChapterLoaded` state
8. UI rebuilds with chapter content

**State Management:**
- Primary: `flutter_bloc` for complex state (BibliaBloc, SearchBloc, etc.)
- Secondary: `Cubit` for simpler state (BibleVersionCubit, DailyGrowthCubit)
- Persistence: `hydrated_bloc` for state persistence across app restarts

### Dependency Injection Flow:

**Location:** `lib/main.dart`

1. Services initialized at startup (ObjectBox, AI, Firebase)
2. Repositories created with dependencies
3. `EntryPoint` widget provides all dependencies via `MultiRepositoryProvider`
4. `App` widget provides BLoCs via `MultiBlocProvider`
5. Features access via `context.read<T>()` or `context.watch<T>()`

## Key Abstractions

### Repository Pattern:
**Purpose:** Abstract data source from business logic

**Examples:**
- `IBibleRepository` (`lib/core/data/repositories/interfaces/i_bible_repository.dart`) - Bible data access
- `IVerseHistoryRepository` (`lib/features/profile/domain/repositories/i_verse_history_repository.dart`) - History access

**Pattern:** Interface in domain layer, implementation in data layer

### Provider Pattern:
**Purpose:** Data access implementation

**Examples:**
- `GithubBibleProvider` - Network Bible data
- `SqlBibleSearchProvider` - SQLite search
- `BibleCacheProvider` - Caching layer

### Service Pattern:
**Purpose:** Business logic and cross-cutting operations

**Examples:**
- `StreakService` - Reading streak logic
- `DailyContentService` - Daily reflection generation
- `DeepUnderstandingService` - AI-powered analysis

## Entry Points

### Main Entry:
- **Location:** `lib/main.dart`
- **Triggers:** App launch
- **Responsibilities:** Initialize Firebase, ObjectBox, services, repositories; configure dependency injection; render `EntryPoint` widget

### App Widget:
- **Location:** `lib/app/app.dart`
- **Triggers:** After dependency injection complete
- **Responsibilities:** Configure theme, localization, BLoC providers; set up notification listeners

### Feature Entry Points:
- `lib/features/onboarding/presentation/splash_page.dart` - Initial flow
- `lib/features/biblia/views/biblia_view.dart` - Bible reading
- `lib/features/search/presentation/pages/search_screen.dart` - Search

## Error Handling

**Strategy:** Typed errors with Failure pattern

**Patterns:**
- `Failure` class in `lib/core/error/failures/failure.dart`
- `NetworkExceptions` in `lib/core/network/exceptions/network_exceptions.dart`
- Error states in BLoC states (e.g., `BibleError`)
- Global exception handler via Firebase Crashlytics

**Error Boundary:** Top-level error screen in main.dart for initialization failures

## Cross-Cutting Concerns

**Logging:** 
- `LoggerService` in `lib/core/services/logger_service.dart`
- Console logging via `debugPrint` 
- Firebase Crashlytics for production

**Validation:**
- Input validation in Cubits/Blocs before state changes
- SharedPreferences validation with defaults

**Authentication:**
- Firebase Authentication for user identity
- Local user data via `ProfileRepository`

**Notifications:**
- Firebase Messaging for push notifications
- `flutter_local_notifications` for local notifications
- Centralized via `NotificationHandler`

**Theme:**
- `ThemeBloc` for dynamic theme switching
- Custom theme extensions for brand colors
- Dark/light mode support

---

*Architecture analysis: 2026-04-16*
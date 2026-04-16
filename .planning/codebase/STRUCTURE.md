# Codebase Structure

**Analysis Date:** 2026-04-16

## Directory Layout

```
holy/                                    # Project root (Flutter app)
├── lib/                                 # Application code
│   ├── app/                             # App configuration
│   ├── core/                            # Cross-cutting concerns
│   ├── features/                        # Feature modules
│   ├── shared/                          # Shared components
│   ├── main.dart                        # App entry point
│   └── ...                              # Generated/config files
├── packages/
│   └── bible_handler/                   # Bible domain package
├── assets/                              # Fonts, images, icons
├── test/                                # Unit tests
├── doc/                                 # Architecture docs
└── specs/                               # Feature specs
```

## Directory Purposes

### lib/app/
- **Purpose:** App-level configuration
- **Contains:** `app.dart` (main widget with BLoC providers), `tuoring.dart`
- **Key files:** `lib/app/app.dart`

### lib/core/
- **Purpose:** Cross-cutting services and infrastructure
- **Contains:**
  - `data/` - Database helper, Bible providers, repositories
  - `services/` - AIDeeplinkService, ScrollPersistenceService, etc.
  - `notifications/` - Local/Firebase notification handling
  - `localization/` - i18n setup and delegates
  - `design_system/` - Theme, colors, typography
  - `network/` - API client, interceptors
  - `error/` - Error handling
  - `deeplinks/` - Deep link routing
  - `routes/` - Route constants
  - `utils/` - Utilities

### lib/features/
- **Purpose:** Self-contained feature modules
- **Contains:**
  - `authentication/` - User auth
  - `biblia/` - Bible reading (Bloc)
  - `daily_growth/` - Daily growth (Cubit)
  - `deep_understanding/` - AI verse analysis
  - `download/` - Bible version downloads
  - `eu_sou/` - User profile/personalization (Bloc)
  - `feedback/` - User feedback
  - `initialization/` - App initialization
  - `onboarding/` - Onboarding flow
  - `profile/` - User profile and history (Bloc)
  - `search/` - Verse search (Bloc)
  - `theme/` - Theme settings (Bloc)
  - `tutorial/` - In-app tutorials
  - `verse_interaction/` - Highlights/marks
  - `verse_of_the_day/` - Daily verse

### lib/shared/
- **Purpose:** Shared UI and state across features
- **Contains:**
  - `cubit/` - Shared cubits (BibleVersionCubit, TabControllerCubit)
  - `widgets/` - Reusable widgets (MainScaffold, LoadingWidget)
  - `bible_models.dart` - Shared Bible models

### packages/bible_handler/
- **Purpose:** Separate package for Bible domain logic
- **Structure:**
  - `lib/src/models/` - Bible data models
  - `lib/src/parsers/` - USX/SQLite parsing
  - `lib/src/services/` - Download, database loading
  - `lib/src/sorting/` - Book ordering
  - `lib/src/bible_cache_provider.dart` - Caching
  - `lib/src/bible_search_provider.dart` - Search
  - `lib/src/verse_interaction_provider.dart` - Interaction tracking

## Key File Locations

### Entry Points:
- `lib/main.dart` - App bootstrap, dependency injection
- `lib/app/app.dart` - Main widget with providers

### Configuration:
- `pubspec.yaml` - Dependencies and assets
- `lib/firebase_options.dart` - Firebase config
- `.env` - Environment variables

### Core Logic:
- `lib/core/data/database_helper.dart` - SQLite setup
- `lib/core/services/objectbox_service.dart` - ObjectBox (vector storage)
- `lib/core/notifications/notification_handler.dart` - Notification orchestration

### Feature Implementations:
- `lib/features/biblia/bloc/` - Bible reading state
- `lib/features/search/presentation/bloc/` - Search state
- `lib/features/profile/presentation/bloc/` - Profile/history state

## Naming Conventions

### Files:
- **Dart files:** `snake_case.dart` (e.g., `biblia_bloc.dart`)
- **Feature folders:** `snake_case` (e.g., `daily_growth/`)
- **BLoC files:** `<name>_bloc.dart`, `<name>_state.dart`, `<name>_event.dart`
- **Cubit files:** `<name>_cubit.dart`, `<name>_state.dart`
- **Repository files:** `<name>_repository.dart`
- **Service files:** `<name>_service.dart`

### Classes:
- **BLoCs:** `<Feature>Bloc` (e.g., `BibliaBloc`)
- **Cubits:** `<Feature>Cubit` (e.g., `DailyGrowthCubit`)
- **Repositories:** `<Feature>Repository` (e.g., `EuSouRepository`)
- **Providers:** `<Feature>Provider` (e.g., `GithubBibleProvider`)
- **Models:** PascalCase (e.g., `BibleChapter`)

### Variables/Functions:
- **Methods/variables:** `camelCase` (e.g., `getChapter()`)
- **Constants:** `kCamelCase` prefix (e.g., `kDefaultVersionId`)
- **Private members:** `_camelCase` prefix

## Where to Add New Code

### New Feature:
- Create folder: `lib/features/<feature_name>/`
- Follow structure: `data/`, `domain/`, `presentation/`
- Register BLoC/Cubit in `lib/app/app.dart`
- Add routes in `lib/core/routes/`

### New Component in Existing Feature:
- Implementation: `lib/features/<feature>/<layer>/`
- UI: `lib/features/<feature>/presentation/widgets/`
- Logic: `lib/features/<feature>/presentation/bloc/`

### New Service (Cross-Cutting):
- Location: `lib/core/services/<service_name>.dart`
- Register in: `lib/main.dart` `EntryPoint` widget

### New Repository:
- Interface: `lib/features/<feature>/domain/repositories/i_<name>_repository.dart`
- Implementation: `lib/features/<feature>/data/repositories/<name>_repository.dart`

### New Shared Component:
- Widgets: `lib/shared/widgets/`
- State: `lib/shared/cubit/`
- Models: `lib/shared/`

### New Bible Handler Feature:
- Package: `packages/bible_handler/lib/src/`
- Export in: `packages/bible_handler/lib/bible_handler.dart`

## Special Directories

### Generated:
- `lib/core/localization/generated/` - Flutter gen localization
- `lib/gen/` - Generated code
- `packages/bible_handler/.dart_tool/` - Package build artifacts

### Test:
- `test/` - Unit tests (root)
- `packages/bible_handler/test/` - Package tests
- Pattern: `<file>_test.dart` or `<file>_spec.dart`

### Assets:
- `assets/fonts/` - Custom fonts (TASAOrbiter)
- `assets/images/` - Images
- `assets/icons/` - Icon assets

### Documentation:
- `doc/` - Architecture documentation
- `specs/` - Feature specifications

---

*Structure analysis: 2026-04-16*
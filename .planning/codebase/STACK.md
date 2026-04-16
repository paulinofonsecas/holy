# Technology Stack

**Analysis Date:** 2026-04-16

## Languages

**Primary:**
- Dart `^3.6.0` - Application logic, state management, services
- Flutter `>=3.38.4` - UI framework and platform SDK

**Secondary:**
- Dart `^3.8.1` - Bible handler package (shared library)

## Runtime

**Environment:**
- Flutter SDK (cross-platform: Android, iOS, Web)

**Package Manager:**
- Pub (Dart package manager)
- Lockfile: `pubspec.lock` (present)

## Frameworks

**Core:**
- Flutter `>=3.38.4` - Cross-platform UI framework

**State Management:**
- `flutter_bloc` `^9.1.1` - BLoC pattern implementation
- `bloc` `^9.2.0` - Core BLoC library
- `hydrated_bloc` `^10.1.1` - State persistence for BLoC
- `stacked` `^3.4.1` - MVVM architecture helper
- `stacked_services` `^1.3.0` - Services for stacked architecture

**Testing:**
- `flutter_test` - Unit and widget testing
- `bloc_test` `^10.0.0` - BLoC testing utilities
- `mocktail` `^1.0.4` - Mocking library

**Build/Dev:**
- `build_runner` `^2.4.6` - Code generation
- `flutter_gen_runner` `^5.12.0` - Flutter asset generation
- `flutter_launcher_icons` `^0.14.4` - App icon generation

## Key Dependencies

**Firebase (Push Notifications & Crash Reporting):**
- `firebase_core` `^4.3.0` - Firebase initialization
- `firebase_messaging` `^16.1.0` - Push notifications (FCM)
- `firebase_crashlytics` `^5.0.6` - Crash reporting
- `firebase_storage` `^13.0.5` - Cloud storage
- `flutter_local_notifications` `^20.1.0` - Local notifications

**AI/Generative:**
- `google_generative_ai` `^0.4.5` - Gemini AI integration for:
  - Verse understanding/summaries
  - Weekly reminder message generation
  - Embeddings for semantic search

**Database & Storage:**
- `sqflite` `^2.3.0` - SQLite database (primary local DB)
- `sqlite3` `^2.9.4` - SQLite native library
- `sqlite3_flutter_libs` `^0.6.0+eol` - SQLite Flutter bindings
- `objectbox` `5.2.0` - NoSQL database for complex queries
- `objectbox_flutter_libs` `5.2.0` - ObjectBox Flutter bindings
- `shared_preferences` `^2.5.2` - Key-value storage
- `flutter_secure_storage` `^10.0.0` - Encrypted storage
- `path_provider` `^2.1.1` - File system paths
- `archive` `^4.0.7` - ZIP extraction for Bible downloads

**Networking:**
- `dio` `^5.3.3` - HTTP client for API calls
- `internet_connection_checker` `^3.0.1` - Network status detection

**UI/UX:**
- `google_fonts` `^8.0.2` - Typography
- `flutter_svg` `^2.0.9` - SVG rendering
- `cached_network_image` `^3.3.0` - Image caching
- `shimmer` `^3.0.0` - Loading placeholders
- `wolt_modal_sheet` `^0.11.0` - Modal bottom sheets
- `convex_bottom_bar` `^3.2.0` - Bottom navigation
- `smooth_page_indicator` `^2.0.1` - Page indicators
- `flutter_markdown` `^0.7.7+1` - Markdown rendering

**PDF & Printing:**
- `pdf` `^3.11.3` - PDF generation
- `printing` `^5.14.2` - Print and share PDFs

**Utilities:**
- `intl` - Internationalization
- `equatable` `^2.0.5` - Value equality
- `url_launcher` `^6.1.14` - External URL handling
- `package_info_plus` `^9.0.0` - App info
- `device_info_plus` `^12.3.0` - Device information
- `share_plus` `^10.1.4` - Share functionality
- `image_picker` `^1.0.7` - Image selection
- `gal` `^2.3.2` - Gallery access
- `app_links` `^6.3.2` - Deep linking
- `feedback` `^3.1.0` - User feedback collection
- `logger` `^2.0.2` - Logging
- `tutorial_coach_mark` `^1.3.3` - Onboarding tutorials

**Code Generation:**
- `json_serializable` `^6.7.1` - JSON serialization
- `freezed` `^3.2.3` - Immutable classes
- `json_annotation` `^4.8.1` - JSON annotations
- `freezed_annotation` `^3.1.0` - Freezed annotations

**Timezone:**
- `timezone` `^0.10.0` - Timezone handling
- `flutter_timezone` `^5.0.1` - Flutter timezone binding

**Platform Support:**
- `sqflite_common_ffi` `^2.3.7+1` - FFI for SQLite (desktop/testing)
- `sqflite_common_ffi_web` `^1.0.2` - Web SQLite support
- `firebase_core_web` `^3.3.1` - Firebase web support

## Configuration

**Environment:**
- `flutter_dotenv` `^6.0.0` - Environment variables from `.env`
- Key environment variables:
  - `GEMINI_API_KEY` - Google Gemini AI
  - `GEMINI_TEXT_MODEL` - Text model (default: gemini-2.5-flash)
  - `GEMINI_EMBEDDING_MODEL` - Embedding model (default: text-embedding-004)

**Build:**
- `analysis_options.yaml` - Linting rules (flutter_lints)
- `firebase.json` - Firebase configuration

**Assets:**
- Custom fonts: TASAOrbiter (ExtraBold, SemiBold, Regular, Medium, Bold)
- Images: `assets/images/`, `assets/images/backgrounds/`
- Icons: `assets/icons/`, `assets/icon/`

## Platform Requirements

**Development:**
- Flutter SDK `>=3.38.4`
- Dart SDK `^3.6.0`

**Production:**
- Android: minSdkVersion configured via Firebase (see `android/app/google-services.json`)
- iOS: Configured via Firebase
- Web: Firebase Hosting configured

---

*Stack analysis: 2026-04-16*
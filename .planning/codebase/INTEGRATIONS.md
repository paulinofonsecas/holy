# External Integrations

**Analysis Date:** 2026-04-16

## APIs & External Services

**AI/Generative:**
- Google Gemini AI - Verse understanding, summaries, embeddings
  - SDK: `google_generative_ai` `^0.4.5`
  - Env vars: `GEMINI_API_KEY`, `GEMINI_TEXT_MODEL`, `GEMINI_EMBEDDING_MODEL`
  - Used in: `lib/core/services/ai_service.dart`
  - Features:
    - Semantic search embeddings via `text-embedding-004`
    - Verse summary generation via `gemini-2.5-flash`
    - Weekly reminder message generation

**Bible Data:**
- GitHub (External) - Bible version downloads
  - Provider: `lib/core/data/provider/github_bible_provider.dart`
  - Downloads Bible XML files from remote repositories
  - Stored locally after download

## Data Storage

**Databases:**
- SQLite (Primary)
  - Connection: Local file via `sqflite`
  - Location: App documents directory
  - Used for: Bible content, user data, search history

- ObjectBox (Secondary)
  - Connection: Local via `objectbox_flutter_libs`
  - Used for: Complex queries, embeddings, faster lookups
  - Service: `lib/core/services/objectbox_service.dart`

- SharedPreferences
  - Used for: Simple key-value settings (theme, locale preferences)

**File Storage:**
- Firebase Storage
  - Service: `firebase_storage` `^13.0.5`
  - Used for: Cloud backup of user data, file storage
  - Config: `firebase.json`

- Local filesystem
  - Bible downloads: `path_provider` for app documents
  - Fonts: Bundled in assets
  - Images: Cached via `cached_network_image`

## Authentication & Identity

**Firebase Auth:**
- Not explicitly configured in pubspec.yaml (no `firebase_auth` package)
- Authentication appears to use custom implementation
- See: `lib/features/authentication/` (custom auth flow)

**Firebase Project:**
- Project ID: `caiaia01`
- Platforms: Android, iOS, Web
- Config: `android/app/google-services.json`, `firebase.json`

## Push Notifications

**Firebase Cloud Messaging (FCM):**
- Package: `firebase_messaging` `^16.1.0`
- Service: `lib/core/notifications/services/fcm_service.dart`
- Used for: Daily reminders, verse of the day, motivational notifications

**Local Notifications:**
- Package: `flutter_local_notifications` `^20.1.0`
- Service: `lib/core/notifications/services/local_notification_service.dart`
- Used for: Scheduled local notifications (streak reminders)

**Notification Handling:**
- Handler: `lib/core/notifications/notification_handler.dart`

## Error Tracking & Monitoring

**Firebase Crashlytics:**
- Package: `firebase_crashlytics` `^5.0.6`
- Used for: Crash reporting and error tracking

**Custom Logging:**
- Package: `logger` `^2.0.2`
- Service: `lib/core/services/logger_service.dart`
- Logs to: Console (debug mode) + crashlytics (production)

## Deep Linking

**App Links:**
- Package: `app_links` `^6.3.2`
- Service: `lib/core/services/deeplink_service.dart`
- Pattern: `bible://` for verse navigation (e.g., `bible://João/1/12`)
- Configuration: `specs/001-app-deeplinks/well-known/assetlinks.json`

## Network

**HTTP Client:**
- Package: `dio` `^5.3.3`
- Client: `lib/core/network/api_client.dart`
- Interceptors:
  - `lib/core/network/interceptors/auth_interceptor.dart`
  - `lib/core/network/interceptors/logging_interceptor.dart`

**Network Status:**
- Package: `internet_connection_checker` `^3.0.1`
- Service: `lib/core/network/network_info.dart`

## UI & Media

**Fonts:**
- Google Fonts API
  - Package: `google_fonts` `^8.0.2`
  - Used for: Dynamic font loading

**Custom Fonts:**
- TASAOrbiter (bundled in assets)
  - Weights: ExtraBold, SemiBold, Regular, Medium, Bold

**Images:**
- `cached_network_image` - Image caching
- `flutter_svg` - SVG icon rendering
- `image_picker` - Camera/gallery access
- `gal` - Gallery access
- `flutter_markdown` - Markdown rendering with formatting

## PDF & Sharing

**PDF Generation:**
- Package: `pdf` `^3.11.3`
- Used for: Generating printable Bible content

**Printing:**
- Package: `printing` `^5.14.2`
- Used for: Print and share Bible verses

**Sharing:**
- Package: `share_plus` `^10.1.4`
- Service: `lib/core/services/share_service.dart`

## User Feedback

**Feedback Collection:**
- Package: `feedback` `^3.1.0`
- Service: `lib/core/services/feedback_service.dart`

## CI/CD & Deployment

**Firebase Hosting:**
- Platform: Firebase (web hosting)
- Config: `firebase.json` - `"hosting": {"public": "build/web"}`
- Rewrite rule: All routes to `index.html` (SPA support)

**Build Targets:**
- Android: Gradle-based build
- iOS: Xcode (not fully configured in repo)
- Web: Flutter web (HTML renderer)

## Environment Configuration

**Required env vars (`.env`):**
- `GEMINI_API_KEY` - Google Gemini AI API key
- `GEMINI_TEXT_MODEL` - Text model name (optional, defaults to gemini-2.5-flash)
- `GEMINI_EMBEDDING_MODEL` - Embedding model name (optional, defaults to text-embedding-004)

**Secrets location:**
- Firebase: `android/app/google-services.json` (Android)
- Env vars: `.env` file (loaded via `flutter_dotenv`)
- Secure storage: `flutter_secure_storage` (for sensitive user data)

## Webhooks & Callbacks

**Incoming:**
- FCM token refresh callbacks
- Deep link handling via `app_links`

**Outgoing:**
- None detected (app is primarily consumer-focused)

---

*Integration audit: 2026-04-16*
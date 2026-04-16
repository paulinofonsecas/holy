# Codebase Concerns

**Analysis Date:** 2026-04-16

## Dependency Health Concerns

### Critical: End-of-Life Dependencies

**`sqlite3_flutter_libs: ^0.6.0+eol`** in `pubspec.yaml`
- Issue: This package version is explicitly marked as end-of-life (eol)
- Impact: May not receive security updates, could have compatibility issues with newer SQLite versions
- Fix approach: Monitor for updates to `sqlite3_flutter_libs` and upgrade when stable version available

### Potentially Outdated Firebase Dependencies

From `pubspec.yaml` (lines 20-24):
```yaml
firebase_core: ^4.3.0
firebase_messaging: ^16.1.0
firebase_crashlytics: ^5.0.6
firebase_storage: ^13.0.5
```
- Issue: These versions may lag behind latest Firebase SDK releases
- Impact: May miss new features and performance improvements
- Fix approach: Check for updates quarterly and test compatibility

### API Key Handling Concerns

**Location:** `lib/core/services/ai_service.dart` (lines 13-15), `lib/features/eu_sou/data/services/daily_content_service.dart` (lines 133-139)

**Issue:** API keys loaded via `flutter_dotenv` from `.env` file included in Flutter assets
```dart
_apiKey = dotenv.env['GEMINI_API_KEY'] ??
    const String.fromEnvironment('GEMINI_API_KEY');
```

**Security Risk:** The `.env` file is included in Flutter's assets bundle (see `pubspec.yaml` line 116):
```yaml
assets:
  - .env
```
- If app is decompiled, the `.env` file could be extracted
- No server-side proxy exists for API calls

**Fix approach:** Implement server-side proxy or use Firebase Functions to protect API keys

## Technical Debt Areas

### 1. Stub Authentication Interceptor

**File:** `lib/core/network/interceptors/auth_interceptor.dart`

**Issue:** The entire authentication system is stubbed out
```dart
// TODO: Replace with your authentication logic
String? _getToken() {
  // TODO: Implement your token retrieval logic
  return null;  // Always returns null
}
```

**Impact:** No authenticated API calls possible
**Fix approach:** Implement actual token retrieval from `flutter_secure_storage`

### 2. Unimplemented Bible Repository Methods

**File:** `lib/core/data/repositories/bible_repository.dart`

**Issue:** Multiple TODO markers for core repository methods:
```dart
// Line 48: TODO: implement getBook
// Line 55: TODO: implement getPassage
// Line 62: TODO: implement getPassageRange
// Line 69: TODO: implement getVerse
// Line 76: TODO: implement getVerseRange
// Line 82: TODO: implement verseOfDay
```

**Impact:** Bible repository cannot fully serve all data
**Fix approach:** Implement missing methods as needed for features

### 3. FCM Service - Token Not Sent to Server

**File:** `lib/core/notifications/services/fcm_service.dart`

**Issue:** FCM token is retrieved but never sent to backend
```dart
// Line 46: // TODO: Send this token to your server
_firebaseMessaging.onTokenRefresh.listen((newToken) {
  debugPrint('FCM Token refreshed: $newToken');
  // TODO: Send this token to your server
});
```

**Impact:** Cannot target specific users with push notifications
**Fix approach:** Implement token sync with backend API

### 4. Sharing Feature Not Implemented

**File:** `lib/features/daily_growth/presentation/pages/daily_growth_page.dart`

**Issue:** Line 66 has empty TODO
```dart
onPressed: () {/* TODO: share streak */},
```

**Impact:** Users cannot share their streak achievements
**Fix approach:** Implement share functionality using `share_plus`

### 5. Search History Management Incomplete

**Files:**
- `lib/features/profile/presentation/widgets/search_history_list.dart` (lines 58, 62)
- `lib/features/profile/presentation/pages/search_history_page.dart` (line 210)

**Issue:** Delete functionality marked as TODO
```dart
// TODO: Remove specific search history item
// TODO: Perform search with this query
// TODO: Implement delete single item
```

**Impact:** Users cannot manage search history
**Fix approach:** Implement delete and re-search functionality

## Known Bugs & Missing Features

### 1. Background Notification Handling

**File:** `lib/core/notifications/services/fcm_service.dart` (lines 121-128)

**Issue:** Navigation from background notification not implemented:
```dart
// TODO: Navigate to specific screen based on data if needed
// Example:
// if (message.data.containsKey('type')) {
//   if (message.data['type'] == 'chat') {
//     // Navigate to chat screen
//   }
// }
```

**Impact:** Tapping notifications doesn't navigate to relevant content
**Fix approach:** Implement deep linking based on notification payload

### 2. Verse Interaction - App Settings

**File:** `lib/features/verse_interaction/presentation/image_creator/widgets/background_picker.dart` (line 230)

**Issue:** TODO for opening app settings:
```dart
// TODO: Open app settings
```

**Impact:** Users cannot grant required permissions easily
**Fix approach:** Implement settings launcher

### 3. Deep Understanding Data Fetching

**File:** `lib/features/biblia/viewmodels/biblia_viewmodel.dart` (line 13)
```dart
// TODO: Implement data fetching
```

**File:** `lib/features/authentication/viewmodels/authentication_viewmodel.dart` (line 13)
```dart
// TODO: Implement data fetching
```

**Impact:** Features likely non-functional or using fallbacks
**Fix approach:** Implement missing data fetching logic

## Exception Handling Concerns

### Silent Exception Catching

**Pattern Found:** 119 catch blocks in the codebase, many silently swallowing errors:

**Example from** `lib/features/daily_growth/data/services/daily_reminder_service.dart` (line 76):
```dart
try {
  return DailyReminder.fromJsonList(raw);
} catch (_) {  // Silent catch - no logging
  final defaults = defaultReminders;
  await saveReminders(defaults);
  return defaults;
}
```

**Impact:** Errors go unnoticed, making debugging difficult only `debugPrint` used, no structured logging

**Better approach:** Use `LoggerService` consistently, add error tracking via Firebase Crashlytics

### Empty Returns in Error Paths

Multiple places return empty collections/null on errors instead of propagating errors:
- `lib/core/services/ai_service.dart` - returns `[]` after all retries
- Services return null for cache misses instead of throwing

## Performance Considerations

### 1. AI Service - Serial Embedding Extraction

**File:** `lib/core/services/ai_service.dart` (lines 62-73)

**Issue:** Falls back to sequential API calls with 500ms delay:
```dart
// FormatException on batch, falling back to individual calls...
for (final text in texts) {
  final singleResponse = await _embeddingModel.embedContent(Content.text(cleanedText));
  allEmbeddings.add(singleResponse.embedding.values);
  await Future.delayed(const Duration(milliseconds: 500));  // Rate limit prevention
}
```

**Impact:** Very slow for multiple texts
**Fix approach:** Implement batch retry logic, cache embeddings

### 2. Daily Reminder Service - Weekly Scheduling

**File:** `lib/features/daily_growth/data/services/daily_reminder_service.dart`

**Issue:** Schedules 21 notifications (3 reminders × 7 days) on each enable
```dart
for (int i = 0; i < _kDaysAhead; i++) {
  // Schedule each notification individually
}
```

**Impact:** Battery drain, scheduling delays on older devices
**Fix approach:** Use notification scheduling efficiently, batch updates

### 3. Large Widget Files

**Files of concern:**
- `lib/features/verse_interaction/presentation/image_creator/widgets/verse_image_canvas.dart` - Contains custom painters
- `lib/features/daily_growth/presentation/pages/daily_growth_page.dart` - Large build methods

**Impact:** Code readability, maintainability issues
**Fix approach:** Break into smaller components

## Security Considerations

### 1. API Keys in Assets

**Confirmed:** `.env` file bundled with app

**Mitigation in place:**
- Uses `flutter_dotenv` which loads at runtime
- `GEMINI_API_KEY` can be overridden via build args

**Remaining concern:** Anyone with APK can extract `.env`

### 2. No Signature Verification

**Issue:** No code signing verification for API calls

**Mitigation:** Firebase Auth could be added but not currently used

### 3. Debug Output in Production

**Pattern:** Heavy use of `debugPrint()` throughout codebase:
```dart
debugPrint('FCM Token: $token');
debugPrint('DailyContentService: using AI cache for $verseReference');
```

**Impact:** Information leakage in production builds
**Fix approach:** Wrap debug prints with `kDebugMode` checks

## Missing Critical Features

### 1. Proper Error Boundary

**Issue:** No global Flutter error boundary

**Current:** Top-level catch in `main.dart` shows generic error
```dart
} catch (e) {
  debugPrint('Erro ao inicializar o aplicativo: $e');
  runApp(const ErrorScreen());  // Generic error screen
}
```

**Impact:** Users see unhelpful error messages

### 2. Offline Mode Verification

**Issue:** Limited offline-first testing mentioned in CLAUDE.md but code shows potential issues:
- Random verse fetches in `daily_reminder_service.dart` may fail offline
- AI services won't work without network

**Fix approach:** Add offline detection, queue operations

### 3. Test Coverage Gaps

**Current test setup in** `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^10.0.0
  mocktail: ^1.0.4
```

**Issue:** No visible test execution in exploration
**Priority:** Add integration tests for notification scheduling

## Fragile Areas

### 1. Notification ID Collisions

**File:** `lib/features/daily_growth/data/services/daily_reminder_service.dart` (lines 162-165)

**Issue:** Complex ID calculation could collide:
```dart
int _weeklyNotificationId(DailyReminder reminder, int dayOffset) {
  final slotBase = reminder.notificationId - 2000;
  return 30000 + (slotBase * 10) + dayOffset;
}
```

**Impact:** Wrong notifications could be canceled
**Fix approach:** Use UUIDs instead of calculated IDs

### 2. Version Hardcoding

**File:** `lib/features/daily_growth/data/services/daily_reminder_service.dart` (line 14)
```dart
static const _kDefaultVersionId = 'KJA';
```

**Impact:** Bible version not configurable
**Fix approach:** Use user's selected version

### 3. State Restoration Assumptions

**Files:** HydratedBloc used but state migration not visible

**Impact:** App state changes could break between versions
**Fix approach:** Add state versioning/migration

## Recommended Priorities

### High Priority (Fix Soon)

1. **Remove EOL dependency** - Update `sqlite3_flutter_libs`
2. **Implement auth interceptor** - Enable authenticated API calls
3. **Fix notification deep linking** - Navigate from notifications
4. **Add error boundaries** - Better error handling

### Medium Priority (Next Phase)

1. **Implement sharing** - Complete streak sharing
2. **Add server-side token sync** - FCM token to backend
3. **Improve logging** - Replace debugPrint with LoggerService
4. **Add search history management** - Delete functionality

### Low Priority (Backlog)

1. **Offline mode improvements**
2. **Test coverage expansion**
3. **Performance optimization** - Batch embeddings
4. **Widget refactoring** - Split large files

---

*Concerns audit: 2026-04-16*
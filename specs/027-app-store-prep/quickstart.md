# Quickstart: Build & Release

## Prerequisites
- Flutter SDK installed and configured.
- Android Studio / Xcode for platform-specific builds.
- Production assets located in `assets/icons/`.

## Setup
1. **Prepare signing (Android)**:
   - Create `android/key.properties` (do NOT commit to git).
   - Add `storePassword`, `keyPassword`, `keyAlias`, `storeFile` paths.

2. **Generate Assets**:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```

3. **Rename Application ID**:
   - For Android: Update `namespace` and `applicationId` in `android/app/build.gradle`.
   - For iOS: Update `PRODUCT_BUNDLE_IDENTIFIER` in Runner project.

## Local Verification
1. **Clean build**:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Run in release mode**:
   ```bash
   flutter run --release
   ```

3. **Generate App Bundle**:
   ```bash
   flutter build appbundle --release
   ```

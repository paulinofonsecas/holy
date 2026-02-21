# Quickstart: Native Deep Linking Implementation

## Prerequisites
- [ ] A custom domain (e.g., `links.holy.app`) with HTTPS support.
- [ ] Ability to host files in the `/.well-known/` directory of the domain.
- [ ] `app_links` dependency added to `pubspec.yaml`.

## Step 1: Host Association Files
Host the following files on your domain:
1. `https://links.holy.app/.well-known/apple-app-site-association` (No extension)
2. `https://links.holy.app/.well-known/assetlinks.json`

Templates for these files are available in `specs/001-app-deeplinks/well-known/`.

## Step 2: Redirection Logic (Server Side)
Since we are not using Firebase Dynamic Links, your web server must handle redirection for users who don't have the app or are on desktop.
- **Path**: `/share`
- **Parameters**: `v={bookId}_{chapter}_{verse}`
- **Logic**:
  - If mobile browser: Redirect to Play Store/App Store.
  - If desktop: Show a landing page with "Open in App" or "Download" buttons.

## Step 3: Android Implementation
Add the following `intent-filter` to your `<activity>` in `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:host="links.holy.app" android:scheme="https"/>
</intent-filter>
```

## Step 4: iOS Implementation
In `ios/Runner/Runner.entitlements`:
```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:links.holy.app</string>
</array>
```

## Step 5: Flutter Implementation
1. Add `app_links: ^6.3.2` to `pubspec.yaml`.
2. `DeeplinkService` handles parsing in `lib/core/services/deeplink_service.dart`.
3. `DeeplinkBloc` coordinates navigation in `lib/core/deeplinks/bloc/`.

## Testing Command
Test Android App Link:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "https://links.holy.app/share?v=43_3_16" com.paulinofonseca.eusou
```


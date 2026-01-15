# Quickstart: Building and Running for Web

## Prerequisites
- Flutter SDK (Web support enabled)
- Chrome or Edge browser

## Development
```bash
# Run in debug mode
flutter run -d chrome

# Run with CanvasKit (higher performance but larger download)
flutter run -d chrome --web-renderer canvaskit
```

## Production Build
```bash
# Build for release
flutter build web --web-renderer auto --release

# Deploy to Firebase
firebase deploy --only hosting
```

## Validation
- Open `https://holy-bible-web.web.app`
- Verify "Loading Database" splash screen.
- Test offline mode by disabling internet in DevTools.

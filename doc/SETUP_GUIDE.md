# Holy - Setup & Onboarding Guide

This guide provides detailed instructions for setting up your development environment to work on the Holy (Eu Sou) project.

## 📋 General Prerequisites

Regardless of your operating system, you will need:

- **Flutter SDK**: `^3.6.0` (Ensure it is on your PATH)
- **Dart SDK**: Automatically included with Flutter.
- **Git**: For version control.
- **VS Code** (Recommended) with the following extensions:
  - Flutter
  - Dart
  - PlantUML (to view architecture diagrams)

---

## 💻 Environment Setup

### 🪟 Windows Setup

1. **Visual Studio 2022**:
   - Install "Desktop development with C++" workload (required for Windows desktop builds).
2. **Android Setup**:
   - Install **Android Studio**.
   - Set up the **Android SDK** and **Android Emulator**.
   - Ensure `ANDROID_HOME` environment variable is set.
3. **SQLite Support**:
   - Some Windows environments might require `sqlite3.dll`. If you encounter database errors, ensure the DLL is available in your System32 or project root.

### 🍎 macOS Setup

1. **Xcode**:
   - Install from the App Store.
   - Run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`.
   - Run `sudo xcodebuild -runFirstLaunch`.
2. **CocoaPods**:
   - Required for iOS native dependencies.
   - Install via Homebrew: `brew install cocoapods`.
3. **Android Setup**:
   - Install **Android Studio**.
   - Configure Android SDK and Emulator.

---

## 🚀 Getting Started (Monorepo Setup)

Holy uses a monorepo structure with internal packages. Follow these steps to initialize the project:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/paulinofonsecas/holy.git
   cd holy
   ```

2. **Configure Environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your local settings if necessary
   ```

3. **Install Dependencies**:
   You must run `pub get` in the root and in all internal packages.
   ```bash
   # Root dependencies
   flutter pub get

   # Internal packages
   cd packages/bible_handler
   flutter pub get
   cd ../..
   ```

4. **Run the App**:
   ```bash
   # Run on the default device
   flutter run

   # Specific platforms
   flutter run -d windows
   flutter run -d ios
   flutter run -d android
   ```

## 📦 Building for Production

### Android
To build a release APK:
```bash
flutter build apk --release
```
The artifact will be located at `build/app/outputs/flutter-apk/app-release.apk`.

### Windows
To build a release EXE:
```bash
flutter build windows --release
```
The artifacts will be in `build/windows/runner/Release/`.

### macOS
To build a release APP:
```bash
flutter build macos --release
```
The artifacts will be in `build/macos/Build/Products/Release/`.

---

## 🛠️ Common Tasks (Makefile)

The project includes a `Makefile` to simplify common operations:

| Command | Description |
|---------|-------------|
| `make test` | Runs all tests in the project and packages. |
| `make build` | Generates a release APK. |
| `make clean` | Cleans build artifacts. |
| `make pipeline` | Runs tests, builds, and prepares for distribution. |

*Note: On Windows, use `nmake` or run the powerShell scripts in `scripts/` directly.*

---

## ❓ Troubleshooting

### CocoaPods Issues (macOS)
If you get errors related to `Podfile`, try:
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
```

### Missing SQLite (Windows)
If the app fails to start on Windows with a SQLite error:
1. Download `sqlite3.dll` from [sqlite.org](https://www.sqlite.org/download.html).
2. Place it in the root of the project or in `C:\Windows\System32`.

### Bible Server (Optional)
The project can interact with a `bible_server` for advanced synchronization. If you need to test these features locally, you will need to clone the `bible_server` repository and run it separately.

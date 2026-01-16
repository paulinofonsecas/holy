# Data Model: Build Configuration

This feature does not introduce new database entities. However, it defines critical build-time "entities" in the form of configuration files.

## Android Build Config
- **Namespace**: `com.paulinofonseca.eusou`
- **Application ID**: `com.paulinofonseca.eusou`
- **Versioning**: 
  - `versionCode`: Derived from `pubspec.yaml` build number (currently 14, target 15).
  - `versionName`: Derived from `pubspec.yaml` version (currently 1.0.0).

## iOS Build Config
- **Product Bundle Identifier**: `com.paulinofonseca.eusou`
- **Development Team**: [NEEDS CLARIFICATION: Team ID]
- **Display Name**: `Eu Sou`

## Assets
- **Launcher Icon Source**: `assets/icons/play_store_512.png`
- **Splash Screen Icon Source**: `assets/icons/play_store_512.png`
- **Splash Screen Color**: `#FFFFFF`

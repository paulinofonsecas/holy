# Research: App Store Preparation

## Decision: Application ID Change
- **RATIONALE**: The use of `com.example` is prohibited by Google Play and App Store. The chosen ID `com.paulinofonseca.eusou` follows standard reverse-domain naming and matches the user's branding.
- **ALTERNATIVES CONSIDERED**: `br.com.holy.bible` was suggested but the user chose the author-branded version.

## Decision: Automated Asset Generation
- **RATIONALE**: Using `flutter_launcher_icons` and `flutter_native_splash` ensures that all density-specific assets are generated correctly according to platform guidelines, reducing the risk of store rejections based on image quality or format.
- **ALTERNATIVES CONSIDERED**: Manual asset creation (too error-prone).

## Decision: Release Signing Configuration
- **RATIONALE**: Mandatory for Android release builds. The configuration will be stored in `key.properties` (excluded from git) to separate sensitive credentials from code.

## Findings: Baseline Versioning
- **STATUS**: Current version in `pubspec.yaml` is `1.0.0+14`.
- **RECOMMENDATION**: Continue with this version for the first release candidate, or increment to `1.0.0+15` as the first official release build.

## Needs Clarification Resolved:
- Final Application ID: `com.paulinofonseca.eusou` (Resolved by user)
- Final Display Name: `Eu Sou` (Resolved by user)
- Firebase Keys: Research required on where to place production keys.

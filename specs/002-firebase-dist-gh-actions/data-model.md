# Data Model: Firebase Distribution

## CI Workflow Entities

### 1. Build Artifact
- **Type**: Android App Bundle (.aab)
- **Source**: `build/app/outputs/bundle/release/app-release.aab`
- **Metadata**: version-code, version-name (extracted from `pubspec.yaml`)

### 2. Authentication
- **Mechanism**: Firebase CLI Token
- **Storage**: GitHub Secret `FIREBASE_TOKEN`

### 3. Distribution Targets
- **App ID**: `FIREBASE_APP_ID` (GitHub Secret)
- **Tester Groups**: Configurable via workflow inputs or branch rules (default: `internal-testers`)

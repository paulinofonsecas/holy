# Script Contract: distribute-apk.sh

**Purpose**: Upload existing APK to Firebase App Distribution  
**Platform**: Unix/Linux/macOS (Bash 4.0+)  
**Phase**: Phase 1 - Design & Contracts

---

## Interface

### Script Path
```bash
scripts/distribute-apk.sh
```

### Parameters (Positional Arguments)

```bash
./scripts/distribute-apk.sh [APK_PATH] [APP_ID] [RELEASE_NOTES] [GROUPS]
```

### Parameter Details

| Position | Name | Type | Required | Default | Description |
|----------|------|------|----------|---------|-------------|
| 1 | `APK_PATH` | String | No | Auto-detect | Path to APK file |
| 2 | `APP_ID` | String | No | Auto-extract | Firebase app ID |
| 3 | `RELEASE_NOTES` | String | No | `""` | Release notes (prefix with `@` for file) |
| 4 | `GROUPS` | String | No | `"internal-testers"` | Comma-separated tester groups |

### Environment Variables (Flags)

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `DRY_RUN` | Boolean | `false` | Set to `true` for preview mode |
| `DEBUG` | Boolean | `false` | Set to `true` for verbose output |

---

## Usage Examples

### Basic Usage (Auto-detect APK)
```bash
./scripts/distribute-apk.sh
```

### With Custom APK Path
```bash
./scripts/distribute-apk.sh /path/to/my-app.apk
```

### With Release Notes (Text)
```bash
./scripts/distribute-apk.sh "" "" "Bug fixes and improvements"
```

### With Release Notes (File)
```bash
./scripts/distribute-apk.sh "" "" "@CHANGELOG.md"
```

### With Custom Tester Groups
```bash
./scripts/distribute-apk.sh "" "" "" "qa-testers,beta-testers"
```

### Dry Run (Preview)
```bash
DRY_RUN=true ./scripts/distribute-apk.sh
```

### Debug Mode
```bash
DEBUG=true ./scripts/distribute-apk.sh
```

### Full Example
```bash
./scripts/distribute-apk.sh \
    "build/app/outputs/flutter-apk/app-release.apk" \
    "1:86790721181:android:19238f375ace9f62db0e74" \
    "@docs/release-notes.txt" \
    "internal-testers"
```

### Combined Flags
```bash
DRY_RUN=true DEBUG=true ./scripts/distribute-apk.sh
```

---

## Preconditions

1. **Bash 4.0+**: Script uses Bash features (arrays, string manipulation)
2. **Firebase CLI installed**: Must be available in PATH
3. **Firebase authentication**: User logged in or `FIREBASE_TOKEN` environment variable set
4. **APK exists**: Build artifact must exist
5. **firebase.json exists**: For auto app ID extraction
6. **jq installed** (optional): For JSON parsing (fallback to grep/sed)
7. **Network connectivity**: Access to Firebase API

---

## Execution Flow

1. **Setup and validation**:
   ```bash
   set -e  # Exit on error
   set -u  # Error on undefined variables
   set -o pipefail  # Pipeline error propagation
   ```

2. **Validate prerequisites**:
   - Check Firebase CLI: `command -v firebase`
   - Check authentication: `firebase login:list` or `$FIREBASE_TOKEN`
   - Check firebase.json exists

3. **Resolve parameters**:
   - APK path (arg 1 or auto-detect)
   - App ID (arg 2 or extract from firebase.json)
   - Release notes (arg 3 or empty)
   - Groups (arg 4 or default)

4. **Build Firebase command**:
   ```bash
   cmd="firebase appdistribution:distribute \"$apk_path\""
   cmd="$cmd --app \"$app_id\""
   cmd="$cmd --groups \"$groups\""
   [[ -n "$release_notes" ]] && cmd="$cmd --release-notes \"$release_notes\""
   [[ -n "$FIREBASE_TOKEN" ]] && cmd="$cmd --token \"$FIREBASE_TOKEN\""
   [[ "$DEBUG" == "true" ]] && cmd="$cmd --debug"
   ```

5. **Execute with retry**:
   - Attempt upload
   - On network error, retry with exponential backoff (max 3 attempts)
   - On config error, fail immediately

6. **Report results**:
   - Success: Display release info
   - Failure: Display error and guidance
   - Exit with appropriate code

---

## Success Criteria

### Successful Execution
- Exit code: `0`
- Standard output contains: `"✔ uploaded distribution"`
- Testers notified within 5 minutes

### Example Success Output
```text
[Step 1/5] Validating prerequisites...
✓ Firebase CLI installed (version 13.0.1)
✓ Authenticated

[Step 2/5] Resolving APK path...
✓ APK found: build/app/outputs/flutter-apk/app-release.apk (45.2 MB)

[Step 3/5] Extracting Firebase app ID...
✓ App ID: 1:86790721181:android:19238f375ace9f62db0e74

[Step 4/5] Uploading to Firebase App Distribution...
Uploading... ████████████████████ 100%
✓ Upload complete

[Step 5/5] Finalizing distribution...
✓ Distribution successful!

Release ID: abc123xyz
Tester Groups: internal-testers
```

---

## Error Scenarios

### Error 1: Firebase CLI Not Installed
```bash
echo "ERROR: Firebase CLI not found"
echo "Install: npm install -g firebase-tools"
exit 1
```

### Error 2: Not Authenticated
```bash
echo "ERROR: Firebase authentication required"
echo "Run: firebase login"
echo "Or set FIREBASE_TOKEN for CI"
exit 2
```

### Error 3: APK Not Found
```bash
echo "ERROR: APK not found: $apk_path"
echo "Build APK: flutter build apk"
exit 3
```

### Error 4: Invalid App ID
```bash
echo "ERROR: Invalid Firebase app ID"
echo "Check firebase.json or provide valid app ID"
exit 4
```

### Error 5: Network Error (with Retry)
```bash
echo "WARNING: Upload failed - retrying..."
# Retry logic with exponential backoff
exit 5  # If all retries fail
```

---

## Exit Codes

(Same as PowerShell version - see distribute-apk-ps1.md)

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Firebase CLI not installed |
| 2 | Authentication required |
| 3 | APK not found |
| 4 | Invalid app ID |
| 5 | Network/upload error |
| 6 | Permission denied |
| 7 | Invalid tester group |
| 99 | Unknown error |

---

## Environment Variables

### Input Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `FIREBASE_TOKEN` | CI only | Firebase CI token |
| `FIREBASE_APP_ID_OVERRIDE` | No | Override app ID |
| `DRY_RUN` | No | Preview mode (true/false) |
| `DEBUG` | No | Verbose output (true/false) |

### Detection Variables

| Variable | Description |
|----------|-------------|
| `CI` | CI environment indicator |
| `GITHUB_ACTIONS` | GitHub Actions indicator |

---

## Retry Logic

(Same as PowerShell version)

- Max attempts: 3
- Initial delay: 5 seconds
- Backoff: Exponential (5s, 10s, 20s)
- Retriable: Network errors, timeouts, rate limits
- Non-retriable: Auth, permissions, invalid config

---

## JSON Parsing Strategy

### Prefer jq (if available)
```bash
if command -v jq &> /dev/null; then
    app_id=$(jq -r '.flutter.dart."lib/firebase_options.dart".configurations.android' firebase.json)
fi
```

### Fallback to grep/sed
```bash
app_id=$(grep -A 10 '"android"' firebase.json | grep -o '"1:[^"]*"' | tr -d '"')
```

---

## Compatibility

### Tested Platforms
- Ubuntu 20.04+ (GitHub Actions default)
- macOS 11+ (Intel and Apple Silicon)
- Debian-based Linux distributions
- WSL2 (Windows Subsystem for Linux)

### Required Tools
- `bash` 4.0+
- `firebase` CLI
- `jq` (recommended but optional)
- `curl` or `wget` (for Firebase CLI if not installed)

---

## Shebang and Permissions

### Shebang
```bash
#!/bin/bash
```
**Note**: Uses `/bin/bash`, not `/bin/sh` (requires Bash-specific features)

### Execution Permissions
```bash
chmod +x scripts/distribute-apk.sh
```

---

## Testing Contract

### Manual Test Cases

1. **Auto-detect APK**: No arguments
2. **Custom APK path**: First argument
3. **Release notes text**: Third argument
4. **Release notes file**: `@CHANGELOG.md`
5. **Custom groups**: Fourth argument
6. **Dry run**: `DRY_RUN=true`
7. **Debug mode**: `DEBUG=true`
8. **Network failure**: Verify retry
9. **Invalid APK**: Error handling
10. **Missing Firebase CLI**: Error handling

### Cross-Platform Testing
- Ubuntu (GitHub Actions runner)
- macOS local development
- WSL2 (Windows developers using Linux)

---

## Version
**Contract Version**: 1.0  
**Date**: 2026-01-04  
**Status**: Phase 1 Design

# Script Contract: distribute-apk.ps1

**Purpose**: Upload existing APK to Firebase App Distribution  
**Platform**: Windows (PowerShell 5.1+)  
**Phase**: Phase 1 - Design & Contracts

---

## Interface

### Script Path
```powershell
scripts/distribute-apk.ps1
```

### Parameters

```powershell
param(
    [Parameter(Mandatory=$false)]
    [string]$ApkPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$AppId = "",
    
    [Parameter(Mandatory=$false)]
    [string]$ReleaseNotes = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Groups = "internal-testers",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$Debug
)
```

### Parameter Details

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `ApkPath` | String | No | Auto-detect | Path to APK file. If empty, auto-detects from `build/app/outputs/flutter-apk/app-release.apk` |
| `AppId` | String | No | Auto-extract | Firebase app ID. If empty, extracts from `firebase.json` |
| `ReleaseNotes` | String | No | `""` | Release notes text or file path (prefix with `@` for file: `@CHANGELOG.md`) |
| `Groups` | String | No | `"internal-testers"` | Comma-separated tester group aliases |
| `DryRun` | Switch | No | `false` | Preview actions without executing upload |
| `Debug` | Switch | No | `false` | Enable verbose Firebase CLI output |

---

## Usage Examples

### Basic Usage (Auto-detect APK)
```powershell
.\scripts\distribute-apk.ps1
```
**Behavior**: Auto-detects APK, uses default tester group, no release notes.

### With Custom APK Path
```powershell
.\scripts\distribute-apk.ps1 -ApkPath "C:\builds\my-app.apk"
```

### With Release Notes (Text)
```powershell
.\scripts\distribute-apk.ps1 -ReleaseNotes "Bug fixes and improvements"
```

### With Release Notes (File)
```powershell
.\scripts\distribute-apk.ps1 -ReleaseNotes "@CHANGELOG.md"
```

### With Custom Tester Groups
```powershell
.\scripts\distribute-apk.ps1 -Groups "qa-testers,beta-testers"
```

### Dry Run (Preview)
```powershell
.\scripts\distribute-apk.ps1 -DryRun
```
**Output**: Shows what would be uploaded without executing.

### Debug Mode
```powershell
.\scripts\distribute-apk.ps1 -Debug
```
**Output**: Verbose Firebase CLI logs for troubleshooting.

### Full Example
```powershell
.\scripts\distribute-apk.ps1 `
    -ApkPath "build\app\outputs\flutter-apk\app-release.apk" `
    -ReleaseNotes "@docs\release-notes.txt" `
    -Groups "internal-testers" `
    -Debug
```

---

## Preconditions

1. **Firebase CLI installed**: Must be available in PATH
2. **Firebase authentication**: User must be logged in (`firebase login`) OR `FIREBASE_TOKEN` environment variable set (CI)
3. **APK exists**: If `ApkPath` provided, file must exist; otherwise default path must exist
4. **firebase.json exists**: If `AppId` not provided, must contain valid app ID
5. **Network connectivity**: Access to Firebase API endpoints
6. **Permissions**: User/token must have App Distribution permissions for the Firebase project

---

## Execution Flow

1. **Validate prerequisites**:
   - Check Firebase CLI installation
   - Verify authentication status
   - Validate firebase.json exists (if AppId not provided)

2. **Resolve APK path**:
   - If `ApkPath` provided, validate file exists
   - Otherwise, check default path: `build/app/outputs/flutter-apk/app-release.apk`
   - Exit with error if APK not found

3. **Resolve App ID**:
   - If `AppId` provided, use it
   - Otherwise, extract from firebase.json
   - Validate app ID format
   - Exit with error if invalid

4. **Prepare Firebase command**:
   - Build `firebase appdistribution:distribute` command
   - Add `--app` parameter
   - Add `--groups` parameter (or `--testers` if emails provided)
   - Add `--release-notes` or `--release-notes-file` if provided
   - Add `--token` if `FIREBASE_TOKEN` environment variable exists
   - Add `--debug` flag if Debug switch enabled

5. **Execute upload** (skip if DryRun):
   - Display progress messages
   - Execute Firebase CLI command with retry logic
   - Capture output and exit code
   - Parse Firebase release ID from output if successful

6. **Report results**:
   - Display success message with release details
   - OR display error message with actionable guidance
   - Exit with appropriate code (0 = success, non-zero = failure)

---

## Success Criteria

### Successful Execution
- Exit code: `0`
- Standard output contains: `"✔ uploaded distribution"`
- Testers receive notification within 5 minutes
- Console displays release ID and distribution link

### Example Success Output
```text
[Step 1/5] Validating prerequisites...
✓ Firebase CLI installed (version 13.0.1)
✓ Authenticated as developer@example.com

[Step 2/5] Resolving APK path...
✓ APK found: build/app/outputs/flutter-apk/app-release.apk (45.2 MB)

[Step 3/5] Extracting Firebase app ID...
✓ App ID: 1:86790721181:android:19238f375ace9f62db0e74

[Step 4/5] Uploading to Firebase App Distribution...
Uploading APK... ████████████████████ 100% (45.2 MB)
✓ APK uploaded successfully

[Step 5/5] Finalizing distribution...
✓ Distribution complete!

Release ID: abc123xyz
Distribution URL: https://appdistribution.firebase.google.com/pub/i/abc123xyz
Tester Groups: internal-testers
Release Notes: Bug fixes and improvements

Testers will receive notification shortly.
```

---

## Error Scenarios

### Error 1: Firebase CLI Not Installed
```text
ERROR: Firebase CLI not found
Install Firebase CLI: npm install -g firebase-tools
Documentation: https://firebase.google.com/docs/cli
Exit Code: 1
```

### Error 2: Not Authenticated
```text
ERROR: Firebase authentication required
Run: firebase login
OR set FIREBASE_TOKEN environment variable for CI
Exit Code: 2
```

### Error 3: APK Not Found
```text
ERROR: APK file not found
Path: build/app/outputs/flutter-apk/app-release.apk
Solution: Build APK first with 'flutter build apk' or specify custom path with -ApkPath
Exit Code: 3
```

### Error 4: Invalid App ID
```text
ERROR: Invalid Firebase app ID format
App ID: invalid-id
Expected format: 1:123456789:android:abc123def456
Check firebase.json or provide valid -AppId parameter
Exit Code: 4
```

### Error 5: Network Error (with Retry)
```text
WARNING: Upload failed - network timeout
Retrying in 5 seconds... (Attempt 1/3)
...
ERROR: Max retries reached - upload failed
Check network connection and try again
Exit Code: 5
```

### Error 6: Permission Denied
```text
ERROR: Permission denied
Your account lacks App Distribution permissions for this project
Contact Firebase project admin to grant access
Exit Code: 6
```

---

## Exit Codes

| Code | Meaning | Resolution |
|------|---------|------------|
| 0 | Success | Distribution completed |
| 1 | Firebase CLI not installed | Install Firebase CLI |
| 2 | Authentication required | Run `firebase login` or set token |
| 3 | APK not found | Build APK or check path |
| 4 | Invalid app ID | Check firebase.json or AppId parameter |
| 5 | Network/upload error | Check connectivity, retry |
| 6 | Permission denied | Request Firebase project access |
| 7 | Invalid tester group | Check group name in Firebase console |
| 99 | Unknown error | Check logs, enable --Debug |

---

## Environment Variables

### Input Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `FIREBASE_TOKEN` | CI only | Firebase CI authentication token (from `firebase login:ci`) |
| `FIREBASE_APP_ID_OVERRIDE` | No | Override app ID from firebase.json (for testing) |

### Detection Variables (Read by script)

| Variable | Description |
|----------|-------------|
| `CI` | If `true`, expects token authentication |
| `GITHUB_ACTIONS` | If `true`, running in GitHub Actions |

---

## Retry Logic

### Retriable Errors
- Network timeout
- Connection refused
- Rate limit (429)
- Server error (5xx)

### Retry Configuration
- Max attempts: 3
- Initial delay: 5 seconds
- Backoff strategy: Exponential (5s, 10s, 20s)
- Total max time: ~35 seconds

### Non-Retriable Errors (Fail Fast)
- Authentication failed
- Invalid app ID
- Permission denied
- APK not found
- Invalid APK format

---

## Logging

### Log Levels
- `INFO`: Progress steps, success messages
- `WARNING`: Retriable errors, retries
- `ERROR`: Fatal errors, exit conditions

### Log Format
```text
[YYYY-MM-DD HH:MM:SS] [LEVEL] Message
```

### Example Log Output
```text
[2026-01-04 14:30:00] [INFO] Starting Firebase distribution...
[2026-01-04 14:30:01] [INFO] APK path: build/app/outputs/flutter-apk/app-release.apk
[2026-01-04 14:30:01] [INFO] App ID: 1:86790721181:android:19238f375ace9f62db0e74
[2026-01-04 14:30:02] [INFO] Uploading to Firebase...
[2026-01-04 14:30:45] [INFO] Upload complete
[2026-01-04 14:30:46] [INFO] Distribution successful - Release ID: abc123xyz
```

---

## Dependencies

### Required
- PowerShell 5.1 or higher
- Firebase CLI 11.0.0 or higher
- Network connectivity

### Optional
- jq (for JSON parsing, fallback to PowerShell native)

---

## Testing Contract

### Manual Test Cases

1. **Happy path**: Auto-detect APK, default group
2. **Custom APK path**: Explicit path parameter
3. **Release notes from text**: String parameter
4. **Release notes from file**: `@CHANGELOG.md` syntax
5. **Multiple tester groups**: Comma-separated groups
6. **Dry run**: Preview without upload
7. **Debug mode**: Verbose output
8. **Network failure**: Verify retry logic
9. **Invalid APK path**: Error handling
10. **Missing Firebase CLI**: Error handling

### Expected Behavior
Each test case should:
- Validate inputs correctly
- Provide clear error messages on failure
- Exit with appropriate exit code
- Display progress for long operations
- Complete successfully for valid inputs

---

## Version
**Contract Version**: 1.0  
**Date**: 2026-01-04  
**Status**: Phase 1 Design

# Research: Firebase APK Distribution Automation

**Feature**: 012-firebase-apk-distribution  
**Phase**: Phase 0 - Outline & Research  
**Date**: 2026-01-04

## Overview

This document consolidates research findings for implementing Firebase App Distribution automation, including CLI best practices, cross-platform scripting patterns, and CI/CD integration approaches.

## Research Tasks Completed

1. Firebase CLI App Distribution capabilities and command structure
2. Cross-platform scripting best practices (PowerShell vs Bash)
3. APK file detection and validation patterns
4. Firebase authentication methods for CI/CD
5. GitHub Actions Firebase CLI integration
6. Error handling and retry patterns for network operations
7. Make target definition for cross-platform compatibility

---

## 1. Firebase CLI App Distribution

### Decision: Use `firebase appdistribution:distribute` command

**Rationale**:
- Official Firebase CLI command specifically designed for App Distribution
- Supports all required parameters: app ID, release notes, tester groups, APK path
- Provides progress feedback and detailed error messages
- Works identically across platforms (Windows, macOS, Linux)
- Actively maintained by Google Firebase team

**Command Structure**:
```bash
firebase appdistribution:distribute <apk-path> \
  --app <firebase-app-id> \
  --release-notes "Release notes text or file path" \
  --groups "tester-group-1,tester-group-2" \
  --token <ci-token>  # For CI/CD environments
```

**Key Parameters**:
- `<apk-path>`: Path to APK file (relative or absolute)
- `--app`: Firebase app ID (format: `1:1234567890:android:abcdef123456`)
- `--release-notes`: Text or file path (prefix with `@` for file)
- `--release-notes-file`: Alternative parameter for file-based notes
- `--groups`: Comma-separated tester group aliases
- `--testers`: Alternative - comma-separated email addresses
- `--token`: CI token for non-interactive authentication (GitHub Actions)
- `--debug`: Verbose output for troubleshooting

**Alternatives Considered**:
- REST API direct calls: Rejected - more complex, requires manual authentication handling
- Third-party tools (Fastlane): Rejected - additional dependency, primarily iOS-focused
- Firebase Admin SDK: Rejected - overkill for simple distribution task

---

## 2. Cross-Platform Scripting Best Practices

### Decision: Separate PowerShell and Bash scripts with shared logic patterns

**Rationale**:
- Different shell environments have incompatible syntax and capabilities
- Separate scripts easier to maintain than conditional platform detection
- Allows platform-specific optimizations (e.g., PowerShell cmdlets vs Unix utilities)
- Existing project already uses this pattern (ci_all.ps1 / ci_all.sh)

**PowerShell Best Practices**:
```powershell
# Use proper error handling
$ErrorActionPreference = "Stop"
try {
    # Operations
} catch {
    Write-Error "Error: $_"
    exit 1
}

# Parameter validation
param(
    [Parameter(Mandatory=$false)]
    [string]$ApkPath,
    [string]$ReleaseNotes = "",
    [string]$Groups = "internal-testers"
)

# Test file existence
if (!(Test-Path $ApkPath)) {
    Write-Error "APK not found: $ApkPath"
    exit 1
}

# Progress indication
Write-Host "Step 1/3: Validating prerequisites..."
```

**Bash Best Practices**:
```bash
#!/bin/bash
set -e  # Exit on error
set -u  # Error on undefined variables
set -o pipefail  # Pipeline error propagation

# Function definitions
function check_prerequisites() {
    if ! command -v firebase &> /dev/null; then
        echo "Error: Firebase CLI not installed"
        exit 1
    fi
}

# Parameter parsing with defaults
APK_PATH="${1:-}"
RELEASE_NOTES="${2:-}"
GROUPS="${3:-internal-testers}"

# File existence check
if [ ! -f "$APK_PATH" ]; then
    echo "Error: APK not found: $APK_PATH"
    exit 1
fi
```

**Shared Logic Patterns**:
- Prerequisites validation (Firebase CLI installation check)
- APK file auto-detection if path not provided
- App ID extraction from firebase.json
- Progress feedback at key steps
- Exit code 0 for success, non-zero for failures
- Retry logic for transient network errors

**Alternatives Considered**:
- Single cross-platform shell script: Rejected - limited compatibility, complex conditional logic
- Node.js script: Rejected - additional runtime dependency
- Python script: Rejected - not already in project dependencies

---

## 3. APK File Detection and Validation

### Decision: Use standard Flutter build output path with auto-detection

**Rationale**:
- Flutter consistently outputs APK to `build/app/outputs/flutter-apk/app-release.apk`
- Predictable location enables reliable auto-detection
- Validation ensures file exists and is non-zero size before upload attempt

**Detection Logic**:
```powershell
# PowerShell
function Find-Apk {
    param([string]$CustomPath)
    
    if ($CustomPath -and (Test-Path $CustomPath)) {
        return $CustomPath
    }
    
    $defaultPath = "build/app/outputs/flutter-apk/app-release.apk"
    if (Test-Path $defaultPath) {
        return $defaultPath
    }
    
    Write-Error "APK not found. Build APK first or specify path."
    exit 1
}
```

```bash
# Bash
find_apk() {
    local custom_path="$1"
    local default_path="build/app/outputs/flutter-apk/app-release.apk"
    
    if [ -n "$custom_path" ] && [ -f "$custom_path" ]; then
        echo "$custom_path"
        return 0
    fi
    
    if [ -f "$default_path" ]; then
        echo "$default_path"
        return 0
    fi
    
    echo "Error: APK not found. Build APK first or specify path." >&2
    exit 1
}
```

**Validation Checks**:
1. File exists at specified/detected path
2. File is regular file (not directory/symlink)
3. File size > 0 bytes (not empty)
4. File extension is .apk
5. Optionally: File is recent (modified within last 24 hours)

**Alternatives Considered**:
- Search entire build directory: Rejected - could find wrong APK variant
- Require explicit path always: Rejected - reduces developer convenience
- Use glob patterns: Rejected - ambiguous when multiple APKs exist

---

## 4. Firebase Authentication for CI/CD

### Decision: Use Firebase CI tokens for GitHub Actions, local auth for developers

**Rationale**:
- Firebase tokens enable non-interactive authentication in CI/CD
- Local developers use `firebase login` with browser-based OAuth (one-time setup)
- Token-based auth is secure when stored in GitHub Secrets
- Separates CI/CD auth from developer auth for better security

**CI/CD Authentication (GitHub Actions)**:
```yaml
- name: Distribute to Firebase
  env:
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
  run: |
    firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
      --app ${{ secrets.FIREBASE_APP_ID }} \
      --groups "qa-testers" \
      --release-notes "@CHANGELOG.md" \
      --token "$FIREBASE_TOKEN"
```

**Token Generation** (one-time setup):
```bash
# Generate CI token (developer runs locally)
firebase login:ci

# Output: Token copied to secrets as FIREBASE_TOKEN
# Add to GitHub: Settings > Secrets > Actions > New repository secret
```

**Local Developer Authentication**:
```bash
# One-time login (opens browser)
firebase login

# Credentials stored in ~/.config/firebase
# Scripts omit --token parameter for local execution
```

**Script Logic**:
```powershell
# PowerShell
$token = $env:FIREBASE_TOKEN
if ($token) {
    # CI/CD environment
    firebase appdistribution:distribute $apkPath --token $token ...
} else {
    # Local environment (uses firebase login credentials)
    firebase appdistribution:distribute $apkPath ...
}
```

**Alternatives Considered**:
- Service account JSON keys: Rejected - more complex, requires additional file management
- Shared credentials file: Rejected - security risk, difficult to manage
- Manual login in CI: Rejected - impossible in non-interactive environments

---

## 5. GitHub Actions Firebase CLI Integration

### Decision: Add distribution step to existing workflows, create dedicated workflow for branch-triggered automation

**Rationale**:
- Existing `release.yml` workflow already builds APK on tag pushes
- Adding distribution step extends existing workflow without duplication
- Dedicated `distribute.yml` workflow enables branch-specific automation
- Reuses existing Flutter setup and caching for efficiency

**Integration Approach 1: Extend Release Workflow**:
```yaml
# .github/workflows/release.yml (add after Build APK step)
- name: Distribute to Firebase
  if: success()  # Only if build succeeded
  env:
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
    FIREBASE_APP_ID: ${{ secrets.FIREBASE_APP_ID }}
  run: |
    npm install -g firebase-tools
    firebase appdistribution:distribute \
      build/app/outputs/flutter-apk/app-release.apk \
      --app "$FIREBASE_APP_ID" \
      --groups "beta-testers" \
      --release-notes "Release ${{ github.ref_name }}: See GitHub release for details" \
      --token "$FIREBASE_TOKEN"
```

**Integration Approach 2: Dedicated Distribution Workflow**:
```yaml
# .github/workflows/distribute.yml (new file)
name: Firebase Distribution

on:
  push:
    branches:
      - staging
      - develop
  workflow_dispatch:  # Manual trigger option

jobs:
  distribute:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          flutter-version: 3.38.5
          
      - name: Build APK
        run: flutter build apk --release
        
      - name: Install Firebase CLI
        run: npm install -g firebase-tools
        
      - name: Distribute to Firebase
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
        run: |
          firebase appdistribution:distribute \
            build/app/outputs/flutter-apk/app-release.apk \
            --app "${{ secrets.FIREBASE_APP_ID }}" \
            --groups "qa-testers" \
            --release-notes "Build from ${{ github.ref_name }} - Commit: ${{ github.sha }}" \
            --token "$FIREBASE_TOKEN"
```

**Required Secrets**:
- `FIREBASE_TOKEN`: CI token from `firebase login:ci`
- `FIREBASE_APP_ID`: Firebase app ID (format: `1:86790721181:android:19238f375ace9f62db0e74`)

**Alternatives Considered**:
- Firebase GitHub Action: Rejected - not officially maintained, limited features
- Matrix builds for multiple APKs: Rejected - single APK sufficient for current needs
- Separate workflow for each branch: Rejected - unnecessary duplication

---

## 6. Error Handling and Retry Patterns

### Decision: Implement exponential backoff retry for network errors, fail fast for configuration errors

**Rationale**:
- Network errors (timeouts, rate limits) are transient and benefit from retries
- Configuration errors (missing credentials, invalid app ID) are permanent and should fail immediately
- Exponential backoff prevents overwhelming Firebase API during issues
- Clear error messages help developers diagnose and fix problems quickly

**Retry Logic (PowerShell)**:
```powershell
function Invoke-WithRetry {
    param(
        [scriptblock]$Command,
        [int]$MaxRetries = 3,
        [int]$InitialDelaySeconds = 5
    )
    
    $attempt = 1
    $delay = $InitialDelaySeconds
    
    while ($attempt -le $MaxRetries) {
        try {
            Write-Host "Attempt $attempt/$MaxRetries..."
            & $Command
            return  # Success
        } catch {
            $errorMsg = $_.Exception.Message
            
            # Check if retriable error
            if ($errorMsg -match "network|timeout|connection|rate limit") {
                if ($attempt -lt $MaxRetries) {
                    Write-Warning "Retriable error: $errorMsg"
                    Write-Host "Retrying in $delay seconds..."
                    Start-Sleep -Seconds $delay
                    $delay *= 2  # Exponential backoff
                    $attempt++
                } else {
                    Write-Error "Max retries reached. Last error: $errorMsg"
                    throw
                }
            } else {
                # Non-retriable error (config, permissions, etc.)
                Write-Error "Configuration error: $errorMsg"
                throw
            }
        }
    }
}

# Usage
Invoke-WithRetry {
    firebase appdistribution:distribute $apkPath --app $appId ...
}
```

**Retry Logic (Bash)**:
```bash
retry_with_backoff() {
    local max_retries=3
    local delay=5
    local attempt=1
    
    while [ $attempt -le $max_retries ]; do
        echo "Attempt $attempt/$max_retries..."
        
        if firebase appdistribution:distribute "$@"; then
            return 0  # Success
        fi
        
        local exit_code=$?
        
        # Check if retriable (network-related errors typically exit with code 1)
        if [ $attempt -lt $max_retries ]; then
            echo "Warning: Upload failed, retrying in $delay seconds..."
            sleep $delay
            delay=$((delay * 2))  # Exponential backoff
            attempt=$((attempt + 1))
        else
            echo "Error: Max retries reached"
            return $exit_code
        fi
    done
}
```

**Error Categories**:

1. **Retriable Errors** (network, transient):
   - Connection timeout
   - Network unreachable
   - Rate limit exceeded
   - Temporary server error (5xx)
   
2. **Non-Retriable Errors** (configuration, permanent):
   - Firebase CLI not installed
   - Invalid app ID
   - Authentication failed
   - Permission denied
   - APK file not found
   - Invalid APK format

**Alternatives Considered**:
- Fixed retry interval: Rejected - can overwhelm service during outages
- Unlimited retries: Rejected - could hang indefinitely
- No retry logic: Rejected - poor user experience for transient failures

---

## 7. Make Target Definition for Cross-Platform Compatibility

### Decision: Create Makefile with platform-specific command delegation

**Rationale**:
- Make provides unified interface across platforms
- Platform detection allows automatic script selection (PS1 on Windows, SH on Unix)
- Developers use same command regardless of OS
- Integrates with existing developer workflows

**Makefile Structure**:
```makefile
# Detect platform
ifeq ($(OS),Windows_NT)
    SHELL := powershell.exe
    SCRIPT_EXT := .ps1
    SCRIPT_CMD := powershell -ExecutionPolicy Bypass -File
else
    SCRIPT_EXT := .sh
    SCRIPT_CMD := bash
endif

# Phony targets (not files)
.PHONY: distribute build-and-distribute ci-all help

# Display help
help:
	@echo "Available targets:"
	@echo "  distribute           - Upload existing APK to Firebase"
	@echo "  build-and-distribute - Run CI scripts then distribute"
	@echo "  ci-all               - Run existing CI scripts only"

# Distribute existing APK
distribute:
	$(SCRIPT_CMD) scripts/distribute-apk$(SCRIPT_EXT)

# Full pipeline: CI + distribution
build-and-distribute:
	$(SCRIPT_CMD) scripts/build-and-distribute$(SCRIPT_EXT)

# Existing CI scripts
ci-all:
	$(SCRIPT_CMD) scripts/ci_all$(SCRIPT_EXT)
```

**Usage Examples**:
```bash
# Manual distribution (APK must exist)
make distribute

# Full pipeline (build + distribute)
make build-and-distribute

# Just CI scripts (no distribution)
make ci-all

# Show help
make help
```

**Parameter Passing** (optional enhancement):
```makefile
# Accept parameters
distribute:
	$(SCRIPT_CMD) scripts/distribute-apk$(SCRIPT_EXT) \
		-ApkPath $(APK_PATH) \
		-ReleaseNotes "$(NOTES)" \
		-Groups $(GROUPS)

# Usage: make distribute APK_PATH=path/to/app.apk NOTES="Test build" GROUPS="qa-testers"
```

**Alternatives Considered**:
- Task runner (npm scripts, just): Rejected - requires additional tooling
- Direct script invocation: Rejected - developers must remember platform-specific commands
- CMake: Rejected - overkill for simple script orchestration

---

## Configuration and Defaults

### App ID Extraction from firebase.json

**Decision**: Parse firebase.json to extract Firebase app ID automatically

**Implementation** (PowerShell):
```powershell
function Get-FirebaseAppId {
    $firebaseJson = Get-Content "firebase.json" | ConvertFrom-Json
    $appId = $firebaseJson.flutter.dart.'lib/firebase_options.dart'.configurations.android
    
    if (!$appId) {
        Write-Error "Firebase app ID not found in firebase.json"
        exit 1
    }
    
    return $appId
}
```

**Implementation** (Bash):
```bash
get_firebase_app_id() {
    local app_id=$(jq -r '.flutter.dart."lib/firebase_options.dart".configurations.android' firebase.json)
    
    if [ "$app_id" == "null" ] || [ -z "$app_id" ]; then
        echo "Error: Firebase app ID not found in firebase.json" >&2
        exit 1
    fi
    
    echo "$app_id"
}
```

**Current Project App ID**: `1:86790721181:android:19238f375ace9f62db0e74`

### Default Tester Group

**Decision**: Use "internal-testers" as default group with override capability

**Rationale**: Sensible default for most distributions while allowing customization for specific scenarios (QA vs beta testers).

---

## Summary

All research complete. Key decisions finalized:

1. ✅ Firebase CLI `appdistribution:distribute` command
2. ✅ Separate PowerShell/Bash scripts with shared patterns
3. ✅ Auto-detect APK at standard Flutter build output path
4. ✅ Token-based auth for CI/CD, login auth for developers
5. ✅ Extend existing workflows + add dedicated distribution workflow
6. ✅ Exponential backoff retry for network errors
7. ✅ Makefile with platform detection for unified interface

**No NEEDS CLARIFICATION items remaining.** Ready for Phase 1 (Design & Contracts).

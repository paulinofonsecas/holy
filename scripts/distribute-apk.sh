#!/bin/bash

################################################################################
# Firebase Distribution Script (Bash)
#
# Description:
#   Uploads APK or AAB file to Firebase App Distribution for testing.
#   Auto-detects artifact path and Firebase app ID if not provided.
#
# Usage:
#   ./distribute-apk.sh [ARTIFACT_PATH] [APP_ID] [RELEASE_NOTES] [GROUPS]
#
# Environment Variables:
#   DRY_RUN=true    - Preview actions without executing upload
#   DEBUG=true      - Enable verbose Firebase CLI output
#   FIREBASE_TOKEN  - CI authentication token (auto-detected)
#
# Examples:
#   ./distribute-apk.sh
#   ./distribute-apk.sh "" "" "Bug fixes" "qa-testers"
#   DRY_RUN=true ./distribute-apk.sh
#
# Exit Codes:
#   0 - Success
#   1 - Firebase CLI not installed
#   2 - Authentication required
#   3 - Artifact not found
#   4 - Invalid app ID
#   5 - Network/upload error
#   6 - Permission denied
#   7 - Invalid tester group
#   99 - Unknown error
#
################################################################################

set -e  # Exit on error
set -u  # Error on undefined variables
set -o pipefail  # Pipeline error propagation

# Parameters
ARTIFACT_PATH="${1:-}"
APP_ID="${2:-}"
RELEASE_NOTES="${3:-}"
GROUPS="${4:-internal-testers}"

# Environment flags
DRY_RUN="${DRY_RUN:-false}"
DEBUG="${DEBUG:-false}"

# Script variables
START_TIME=$(date +%s)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

################################################################################
# Helper Functions
################################################################################

log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    case "$level" in
        ERROR)
            echo -e "\033[0;31m[$timestamp] [ERROR] $message\033[0m" >&2
            ;;
        WARNING)
            echo -e "\033[0;33m[$timestamp] [WARNING] $message\033[0m" >&2
            ;;
        SUCCESS)
            echo -e "\033[0;32m[$timestamp] [SUCCESS] $message\033[0m" >&2
            ;;
        *)
            echo "[$timestamp] [INFO] $message" >&2
            ;;
    esac
}

step() {
    local current="$1"
    local total="$2"
    local message="$3"
    echo ""
    echo -e "\033[0;36m[Step $current/$total] $message...\033[0m"
}

check_firebase_cli() {
    log INFO "Checking Firebase CLI installation..."
    
    if ! command -v firebase &> /dev/null; then
        log ERROR "Firebase CLI not found"
        log ERROR "Install: npm install -g firebase-tools"
        log ERROR "Documentation: https://firebase.google.com/docs/cli"
        return 1
    fi
    
    local version=$(firebase --version 2>&1 || echo "unknown")
    log SUCCESS "✓ Firebase CLI installed ($version)"
    return 0
}

check_firebase_auth() {
    log INFO "Checking Firebase authentication..."
    
    # Check for CI token first
    if [ -n "${FIREBASE_TOKEN:-}" ]; then
        log SUCCESS "✓ Using FIREBASE_TOKEN from environment (CI mode)"
        return 0
    fi
    
    # Check local authentication
    if firebase login:list &> /dev/null; then
        log SUCCESS "✓ Authenticated with Firebase"
        return 0
    else
        log ERROR "Firebase authentication required"
        log ERROR "Run: firebase login"
        log ERROR "OR set FIREBASE_TOKEN environment variable for CI"
        return 1
    fi
}

get_artifact_path() {
    local custom_path="$1"
    
    log INFO "Resolving artifact path..."
    
    # Use custom path if provided
    if [ -n "$custom_path" ]; then
        if [ -f "$custom_path" ]; then
            local size=$(format_file_size "$custom_path")
            log SUCCESS "✓ Using custom artifact: $custom_path ($size)"
            echo "$custom_path"
            return 0
        else
            log ERROR "Custom artifact not found: $custom_path"
            exit 3
        fi
    fi
    
    # Auto-detect from standard Flutter build output (AAB first, then APK)
    local aab_path="build/app/outputs/bundle/release/app-release.aab"
    local apk_path="build/app/outputs/flutter-apk/app-release.apk"
    
    if [ -f "$aab_path" ]; then
        local size=$(format_file_size "$aab_path")
        log SUCCESS "✓ Found AAB: $aab_path ($size)"
        echo "$aab_path"
        return 0
    elif [ -f "$apk_path" ]; then
        local size=$(format_file_size "$apk_path")
        log SUCCESS "✓ Found APK: $apk_path ($size)"
        echo "$apk_path"
        return 0
    else
        log ERROR "Artifact not found at default locations"
        log ERROR "Build AAB/APK first: flutter build appbundle --release OR flutter build apk --release"
        log ERROR "Or specify custom path as first argument"
        exit 3
    fi
}

get_firebase_app_id() {
    local custom_app_id="$1"
    
    log INFO "Resolving Firebase app ID..."
    
    # Use custom app ID if provided
    if [ -n "$custom_app_id" ]; then
        if [[ "$custom_app_id" =~ ^[0-9]+:[0-9]+:android:[a-f0-9]+$ ]]; then
            log SUCCESS "✓ Using custom app ID: $custom_app_id"
            echo "$custom_app_id"
            return 0
        else
            log ERROR "Invalid app ID format: $custom_app_id"
            log ERROR "Expected format: 1:123456789:android:abc123def456"
            exit 4
        fi
    fi
    
    # Extract from firebase.json
    local firebase_json="firebase.json"
    if [ ! -f "$firebase_json" ]; then
        log ERROR "firebase.json not found in current directory"
        log ERROR "Ensure you're running from repository root"
        exit 4
    fi
    
    # Try jq first (preferred)
    local app_id=""
    if command -v jq &> /dev/null; then
        app_id=$(jq -r '.flutter.dart."lib/firebase_options.dart".configurations.android' "$firebase_json" 2>/dev/null || echo "")
    else
        # Fallback to grep/sed
        app_id=$(grep -A 10 '"android"' "$firebase_json" | grep -o '"1:[^"]*"' | tr -d '"' | head -1)
    fi
    
    if [ -z "$app_id" ] || [ "$app_id" = "null" ]; then
        log ERROR "Failed to extract app ID from firebase.json"
        log ERROR "Provide app ID explicitly as second argument"
        exit 4
    fi
    
    log SUCCESS "✓ Extracted app ID from firebase.json: $app_id"
    echo "$app_id"
    return 0
}

format_file_size() {
    local file="$1"
    local bytes=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
    
    if [ "$bytes" -ge 1073741824 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1073741824}") GB"
    elif [ "$bytes" -ge 1048576 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1048576}") MB"
    elif [ "$bytes" -ge 1024 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1024}") KB"
    else
        echo "$bytes bytes"
    fi
}

get_file_age_hours() {
    local file="$1"
    local now=$(date +%s)
    local mtime=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null || echo $now)
    local age_seconds=$((now - mtime))
    local age_hours=$((age_seconds / 3600))
    echo "$age_hours"
}

invoke_with_retry() {
    local cmd="$1"
    local max_retries=3
    local delay=5
    local attempt=1
    
    while [ $attempt -le $max_retries ]; do
        if [ $attempt -gt 1 ]; then
            log WARNING "Retry attempt $attempt/$max_retries..."
        fi
        
        if eval "$cmd"; then
            return 0
        fi
        
        local exit_code=$?
        local error_msg="Command failed with exit code $exit_code"
        
        # Check if error is retriable (network-related)
        # Note: This is simplified - in practice, capture stderr for better detection
        if [ $attempt -lt $max_retries ]; then
            log WARNING "Retriable error detected, waiting $delay seconds..."
            sleep $delay
            delay=$((delay * 2))  # Exponential backoff
            attempt=$((attempt + 1))
        else
            log ERROR "Max retries ($max_retries) reached"
            log ERROR "$error_msg"
            exit 5
        fi
    done
}

################################################################################
# Main Script
################################################################################

echo ""
echo -e "\033[0;36m========================================\033[0m"
echo -e "\033[0;36m  Firebase Distribution\033[0m"
echo -e "\033[0;36m========================================\033[0m"
echo ""

# Change to repository root
cd "$REPO_ROOT"

# Step 1: Validate prerequisites
step 1 5 "Validating prerequisites"

if ! check_firebase_cli; then
    exit 1
fi

if ! check_firebase_auth; then
    exit 2
fi

if [ ! -f "firebase.json" ]; then
    log WARNING "firebase.json not found in current directory"
fi

# Step 2: Resolve artifact path
step 2 5 "Resolving artifact path"
resolved_artifact_path=$(get_artifact_path "$ARTIFACT_PATH")

# Validate artifact file
artifact_size=$(stat -f%z "$resolved_artifact_path" 2>/dev/null || stat -c%s "$resolved_artifact_path" 2>/dev/null || echo 0)
if [ "$artifact_size" -eq 0 ]; then
    log ERROR "Artifact file is empty (0 bytes)"
    exit 3
fi

if [ "$artifact_size" -gt 1073741824 ]; then
    log WARNING "Artifact size exceeds 1GB - may hit Firebase limits"
fi

# Step 3: Extract Firebase app ID
step 3 5 "Extracting Firebase app ID"
resolved_app_id=$(get_firebase_app_id "$APP_ID")

# Step 4: Build Firebase command
step 4 5 "Preparing distribution command"

firebase_cmd="firebase appdistribution:distribute \"$resolved_artifact_path\""
firebase_cmd="$firebase_cmd --app \"$resolved_app_id\""
firebase_cmd="$firebase_cmd --groups \"$GROUPS\""

if [ -n "$RELEASE_NOTES" ]; then
    if [[ "$RELEASE_NOTES" == @* ]]; then
        notes_file="${RELEASE_NOTES:1}"
        if [ -f "$notes_file" ]; then
            firebase_cmd="$firebase_cmd --release-notes-file \"$notes_file\""
            log SUCCESS "✓ Release notes from file: $notes_file"
        else
            log WARNING "Release notes file not found: $notes_file"
            firebase_cmd="$firebase_cmd --release-notes \"Release notes file not found\""
        fi
    else
        firebase_cmd="$firebase_cmd --release-notes \"$RELEASE_NOTES\""
        log INFO "✓ Release notes: $RELEASE_NOTES"
    fi
fi

if [ -n "${FIREBASE_TOKEN:-}" ]; then
    firebase_cmd="$firebase_cmd --token \"$FIREBASE_TOKEN\""
    log INFO "✓ Using CI token for authentication"
fi

if [ "$DEBUG" = "true" ]; then
    firebase_cmd="$firebase_cmd --debug"
    log INFO "✓ Debug mode enabled"
fi

log INFO "Target groups: $GROUPS"

if [ "$DRY_RUN" = "true" ]; then
    echo ""
    echo -e "\033[0;33m========================================\033[0m"
    echo -e "\033[0;33m  DRY RUN MODE - Preview Only\033[0m"
    echo -e "\033[0;33m========================================\033[0m"
    echo ""
    
    echo -e "\033[0;33mWould execute command:\033[0m"
    echo -e "\033[0;90m$firebase_cmd\033[0m"
    
    echo -e "\n\033[0;33mDistribution details:\033[0m"
    echo -e "\033[0;90m  Artifact: $resolved_artifact_path\033[0m"
    echo -e "\033[0;90m  Size: $(format_file_size "$resolved_artifact_path")\033[0m"
    echo -e "\033[0;90m  App ID: $resolved_app_id\033[0m"
    echo -e "\033[0;90m  Groups: $GROUPS\033[0m"
    [ -n "$RELEASE_NOTES" ] && echo -e "\033[0;90m  Notes: $RELEASE_NOTES\033[0m"
    
    echo -e "\n\033[0;33mNo upload performed (dry run mode)\033[0m\n"
    exit 0
fi

# Step 5: Execute upload with retry
step 5 5 "Uploading to Firebase App Distribution"

log INFO "Starting upload... (this may take a few minutes)"
echo ""

invoke_with_retry "$firebase_cmd"

# Calculate duration
end_time=$(date +%s)
duration=$((end_time - START_TIME))

# Success!
echo ""
echo -e "\033[0;32m========================================\033[0m"
echo -e "\033[0;32m  ✓ Distribution Successful!\033[0m"
echo -e "\033[0;32m========================================\033[0m"
echo ""

echo -e "\033[0;32mDistribution complete:\033[0m"
echo -e "\033[0;90m  Artifact: $resolved_artifact_path\033[0m"
echo -e "\033[0;90m  Size: $(format_file_size "$resolved_artifact_path")\033[0m"
echo -e "\033[0;90m  Tester Groups: $GROUPS\033[0m"
echo -e "\033[0;90m  Duration: $duration seconds\033[0m"

echo -e "\n\033[0;32mTesters will receive notification shortly.\033[0m\n"

exit 0

#!/bin/bash

# Firebase APK Distribution Script (Bash)
# Equivalent to distribute-apk.ps1

set -e

# Default values
APK_PATH=""
APP_ID=""
RELEASE_NOTES=""
GROUPS="internal-testers"
DRY_RUN=false
VERBOSE_OUTPUT=false

START_TIME=$(date +%s)

# Helper for logging
log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    case "$level" in
        ERROR)   echo -e "\033[0;31m[$timestamp] [ERROR] $message\033[0m" >&2 ;;
        WARNING) echo -e "\033[0;33m[$timestamp] [WARNING] $message\033[0m" >&2 ;;
        SUCCESS) echo -e "\033[0;32m[$timestamp] [SUCCESS] $message\033[0m" >&2 ;;
        *)       echo "[$timestamp] [INFO] $message" >&2 ;;
    esac
}

step() {
    echo -e "\n\033[0;36m[Step $1/$2] $3...\033[0m"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --apk-path) APK_PATH="$2"; shift 2 ;;
        --app-id) APP_ID="$2"; shift 2 ;;
        --release-notes) RELEASE_NOTES="$2"; shift 2 ;;
        --groups) GROUPS="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --verbose) VERBOSE_OUTPUT=true; shift ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --apk-path <path>      Path to APK"
            echo "  --app-id <id>          Firebase App ID"
            echo "  --release-notes <text> Release notes (use @filename for file)"
            echo "  --groups <groups>      Tester groups (default: internal-testers)"
            echo "  --dry-run              Preview only"
            echo "  --verbose              Enable verbose output"
            exit 0
            ;;
        *)
            # Support positional for backward compatibility
            if [ -z "$APK_PATH" ]; then APK_PATH="$1"; elif [ -z "$APP_ID" ]; then APP_ID="$1"; fi
            shift
            ;;
    esac
done

check_firebase_cli() {
    log INFO "Checking Firebase CLI installation..."
    if ! command -v firebase &> /dev/null; then
        log ERROR "Firebase CLI not found"
        log ERROR "Install: npm install -g firebase-tools"
        return 1
    fi
    log SUCCESS "Firebase CLI is installed"
    return 0
}

check_firebase_auth() {
    log INFO "Checking Firebase authentication..."
    if [ -n "${FIREBASE_TOKEN:-}" ]; then
        log SUCCESS "Using FIREBASE_TOKEN from environment"
        return 0
    fi
    if firebase login:list &> /dev/null; then
        log SUCCESS "Authenticated with Firebase"
        return 0
    else
        log ERROR "Firebase authentication required"
        log ERROR "Run: firebase login"
        return 1
    fi
}

get_apk_path() {
    log INFO "Resolving APK path..."
    if [ -n "$1" ] && [ -f "$1" ]; then
        log SUCCESS "Using custom APK: $1"
        echo "$1"
        return 0
    fi
    local default_path="build/app/outputs/flutter-apk/app-release.apk"
    if [ -f "$default_path" ]; then
        log SUCCESS "Found APK: $default_path"
        echo "$default_path"
        return 0
    fi
    log ERROR "APK not found at: $default_path"
    exit 3
}

get_firebase_app_id() {
    log INFO "Resolving Firebase app ID..."
    if [ -n "$1" ]; then
        log SUCCESS "Using custom app ID: $1"
        echo "$1"
        return 0
    fi
    
    if [ -f "firebase.json" ]; then
        if command -v jq &> /dev/null; then
            local app_id=$(jq -r '.flutter.dart."lib/firebase_options.dart".platforms.android.appId // .flutter.dart."lib/firebase_options.dart".android.appId // .flutter.platforms.android.default.appId' firebase.json 2>/dev/null || echo "null")
            if [ "$app_id" != "null" ] && [ -n "$app_id" ] && [[ "$app_id" != "" ]]; then
                log SUCCESS "Extracted app ID from firebase.json: $app_id"
                echo "$app_id"
                return 0
            fi
        fi
        local app_id=$(grep -oE "1:[0-9]+:android:[0-9a-f]+" firebase.json | head -1)
        if [ -n "$app_id" ]; then
            log SUCCESS "Extracted app ID from firebase.json (grep): $app_id"
            echo "$app_id"
            return 0
        fi
    fi

    if [ -f "android/app/google-services.json" ]; then
        if command -v jq &> /dev/null; then
            local app_id=$(jq -r '.client[0].client_info.mobilesdk_app_id' android/app/google-services.json 2>/dev/null || echo "null")
            if [ "$app_id" != "null" ] && [ -n "$app_id" ] && [[ "$app_id" != "" ]]; then
                log SUCCESS "Extracted app ID from google-services.json: $app_id"
                echo "$app_id"
                return 0
            fi
        fi
    fi
    
    log ERROR "Firebase App ID not found. Provide it via --app-id or check configuration files."
    exit 4
}

invoke_with_retry() {
    local cmd="$1"
    local max_retries=3
    local delay=5
    local attempt=1
    while [ $attempt -le $max_retries ]; do
        [ $attempt -gt 1 ] && log WARNING "Retry attempt $attempt/$max_retries..."
        if eval "$cmd"; then return 0; fi
        if [ $attempt -lt $max_retries ]; then
            log WARNING "Command failed, waiting $delay seconds..."
            sleep $delay
            delay=$((delay * 2))
            attempt=$((attempt + 1))
        else
            log ERROR "Max retries reached."
            exit 5
        fi
    done
}

echo -e "\n========================================"
echo -e "  Firebase APK Distribution"
echo -e "========================================\n"

step 1 5 "Validating prerequisites"
check_firebase_cli || exit 1
check_firebase_auth || exit 2

step 2 5 "Resolving APK path"
RESOLVED_APK_PATH=$(get_apk_path "$APK_PATH")
if [ ! -s "$RESOLVED_APK_PATH" ]; then
    log ERROR "APK file is empty"
    exit 3
fi

step 3 5 "Extracting Firebase app ID"
RESOLVED_APP_ID=$(get_firebase_app_id "$APP_ID")

step 4 5 "Preparing distribution command"
FIREBASE_CMD="firebase appdistribution:distribute \"$RESOLVED_APK_PATH\" --app \"$RESOLVED_APP_ID\" --groups \"$GROUPS\""

if [ -n "$RELEASE_NOTES" ]; then
    if [[ "$RELEASE_NOTES" == @* ]]; then
        NOTES_FILE="${RELEASE_NOTES:1}"
        if [ -f "$NOTES_FILE" ]; then
            FIREBASE_CMD="$FIREBASE_CMD --release-notes-file \"$NOTES_FILE\""
            log SUCCESS "Release notes from file: $NOTES_FILE"
        else
            log WARNING "Release notes file not found: $NOTES_FILE"
            FIREBASE_CMD="$FIREBASE_CMD --release-notes \"Release notes file not found\""
        fi
    else
        FIREBASE_CMD="$FIREBASE_CMD --release-notes \"$RELEASE_NOTES\""
        log INFO "Release notes: $RELEASE_NOTES"
    fi
fi

[ -n "${FIREBASE_TOKEN:-}" ] && FIREBASE_CMD="$FIREBASE_CMD --token \"$FIREBASE_TOKEN\""
[ "$VERBOSE_OUTPUT" = true ] && FIREBASE_CMD="$FIREBASE_CMD --debug"

log INFO "Target groups: $GROUPS"

if [ "$DRY_RUN" = true ]; then
    echo -e "\n========================================"
    echo -e "  DRY RUN MODE - Preview Only"
    echo -e "========================================\n"
    echo -e "Would execute:\n$FIREBASE_CMD\n"
    exit 0
fi

step 5 5 "Uploading to Firebase App Distribution"
log INFO "Starting upload... (this may take a few minutes)"
invoke_with_retry "$FIREBASE_CMD"

DURATION=$(($(date +%s) - START_TIME))
echo -e "\n========================================"
echo -e "  Distribution Successful!"
echo -e "========================================\n"
echo -e "Duration: $DURATION seconds"
exit 0

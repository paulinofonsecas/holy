#!/bin/bash

# Build and Distribute APK to Firebase App Distribution

set -e # Exit on error

# Default values
RELEASE_NOTES="Manual build from $(date '+%Y-%m-%d %H:%M')"
GROUPS="testers"
SKIP_TESTS=false
DRY_RUN=false
VERBOSE_OUTPUT=false

# Help message
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --release-notes <text>  Release notes for this version"
    echo "  --groups <groups>       Comma-separated list of tester groups (default: testers)"
    echo "  --skip-tests            Skip running tests before build"
    echo "  --dry-run               Perform a dry run"
    echo "  --verbose               Enable verbose output"
    echo "  --help                  Show this help message"
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --release-notes) RELEASE_NOTES="$2"; shift 2 ;;
        --groups) GROUPS="$2"; shift 2 ;;
        --skip-tests) SKIP_TESTS=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        --verbose) VERBOSE_OUTPUT=true; shift ;;
        --help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

START_TIME=$(date +%s)

echo -e "\033[0;36m=== Starting Build and Distribution Pipeline ===\033[0m"

# 1. Run Tests
if [ "$SKIP_TESTS" = false ]; then
    echo -e "\n\033[0;33m[Step 1/3] Running tests...\033[0m"
    if [ "$DRY_RUN" = true ]; then
        echo -e "\033[0;90m[DryRun] Would run: ./scripts/ci_all.sh\033[0m"
    else
        if ./scripts/ci_all.sh; then
            echo -e "\033[0;32mTests passed successfully.\033[0m"
        else
            echo -e "\033[0;31mTests failed. Aborting pipeline.\033[0m"
            exit 1
        fi
    fi
else
    echo -e "\n\033[0;90m[Step 1/3] Skipping tests as requested.\033[0m"
fi

# 2. Build APK
echo -e "\n\033[0;33m[Step 2/3] Building Release APK...\033[0m"
if [ "$DRY_RUN" = true ]; then
    echo -e "\033[0;90m[DryRun] Would run: flutter build apk --release\033[0m"
else
    if flutter build apk --release; then
        echo -e "\033[0;32mBuild completed successfully.\033[0m"
    else
        echo -e "\033[0;31mFlutter build failed. Aborting pipeline.\033[0m"
        exit 2
    fi
fi

# 3. Distribute APK
echo -e "\n\033[0;33m[Step 3/3] Distributing APK to Firebase...\033[0m"
DIST_ARGS=()
[ -n "$RELEASE_NOTES" ] && DIST_ARGS+=("--release-notes" "$RELEASE_NOTES")
[ -n "$GROUPS" ] && DIST_ARGS+=("--groups" "$GROUPS")
[ "$DRY_RUN" = true ] && DIST_ARGS+=("--dry-run")
[ "$VERBOSE_OUTPUT" = true ] && DIST_ARGS+=("--verbose")

if ./scripts/distribute-apk.sh "${DIST_ARGS[@]}"; then
    echo -e "\033[0;32mDistribution completed successfully.\033[0m"
else
    echo -e "\033[0;31mDistribution failed.\033[0m"
    exit 3
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo -e "\n\033[0;36m=== Pipeline Completed Successfully in ${MINUTES}m ${SECONDS}s ===\033[0m"

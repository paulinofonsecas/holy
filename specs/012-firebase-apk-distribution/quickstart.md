# Quickstart Guide: Firebase APK Distribution

**Feature**: 012-firebase-apk-distribution  
**Audience**: Developers  
**Phase**: Phase 1 - Design & Contracts  
**Date**: 2026-01-04

---

## Overview

This guide shows you how to distribute APK builds to Firebase App Distribution for testing. You can distribute manually, use integrated pipeline commands, or rely on automatic CI/CD distribution.

**Three Distribution Methods**:
1. **Manual Script**: Run distribution script directly (fastest for existing APKs)
2. **Make Pipeline**: Single command for build + distribution (recommended)
3. **Automatic CI/CD**: Branch merges trigger distribution (fully automated)

---

## Prerequisites

### 1. Install Firebase CLI

**Check if installed**:
```bash
firebase --version
```

**Install** (if not present):
```bash
npm install -g firebase-tools
```

Minimum version: 11.0.0

### 2. Authenticate with Firebase

**For local development**:
```bash
firebase login
```
Opens browser for Google authentication. One-time setup.

**For CI/CD** (GitHub Actions):
1. Generate CI token:
   ```bash
   firebase login:ci
   ```
2. Copy the token output
3. Add to GitHub Secrets:
   - Go to: Repository Settings → Secrets → Actions
   - Add secret: `FIREBASE_TOKEN` with the token value
   - Add secret: `FIREBASE_APP_ID` with value: `1:86790721181:android:19238f375ace9f62db0e74`

### 3. Verify Configuration

Check that `firebase.json` contains app ID:
```bash
# PowerShell
Get-Content firebase.json | Select-String "android"

# Bash
grep "android" firebase.json
```

Expected output includes: `1:86790721181:android:19238f375ace9f62db0e74`

---

## Quick Start: Distribute Existing APK

**Fastest method** if you already have a built APK.

### Windows (PowerShell)
```powershell
.\scripts\distribute-apk.ps1
```

### Unix/Linux/macOS (Bash)
```bash
./scripts/distribute-apk.sh
```

### Cross-Platform (Make)
```bash
make distribute
```

**What happens**:
- Auto-detects APK at `build/app/outputs/flutter-apk/app-release.apk`
- Uploads to Firebase
- Notifies "internal-testers" group
- Completes in ~30-90 seconds

---

## Recommended: Build and Distribute Pipeline

**Best for regular development workflow** - runs tests, builds, and distributes.

### Single Command
```bash
make build-and-distribute
```

**Pipeline steps**:
1. ✓ Run tests and analysis
2. ✓ Build release APK
3. ✓ Upload to Firebase
4. ✓ Notify testers

**Duration**: ~6-14 minutes

---

## Common Usage Scenarios

### Scenario 1: Quick Test Build

**Goal**: Distribute to internal testers with simple notes

```bash
make distribute NOTES="Testing navigation fix"
```

### Scenario 2: QA Release

**Goal**: Distribute to QA team with detailed release notes

```bash
make distribute GROUPS="qa-testers" NOTES="@docs/qa-release-notes.md"
```

**Note**: `@` prefix reads notes from file

### Scenario 3: Beta Release

**Goal**: Full pipeline for beta testers

```bash
make build-and-distribute GROUPS="beta-testers" NOTES="@CHANGELOG.md"
```

### Scenario 4: Multi-Group Distribution

**Goal**: Send to multiple tester groups simultaneously

```bash
make distribute GROUPS="internal-testers,qa-testers,stakeholders"
```

### Scenario 5: Preview (Dry Run)

**Goal**: See what would happen without actually uploading

**PowerShell**:
```powershell
.\scripts\distribute-apk.ps1 -DryRun
```

**Bash**:
```bash
DRY_RUN=true ./scripts/distribute-apk.sh
```

**Make**:
```bash
make distribute DRY_RUN=true
```

---

## Troubleshooting

### Problem: "Firebase CLI not found"

**Solution**:
```bash
npm install -g firebase-tools
firebase --version  # Verify installation
```

### Problem: "Authentication required"

**Solution**:
```bash
firebase login
```
Or for CI, ensure `FIREBASE_TOKEN` secret is set.

### Problem: "APK not found"

**Solution**: Build APK first
```bash
flutter build apk --release
# Then distribute
make distribute
```

Or use integrated pipeline:
```bash
make build-and-distribute
```

### Problem: "Permission denied"

**Solution**: Contact Firebase project admin to grant App Distribution permissions for your account.

### Problem: "Network timeout"

**Solution**: Script automatically retries (up to 3 attempts). If still failing:
1. Check network connection
2. Try again later
3. Use debug mode for details:
   ```bash
   make distribute DEBUG=true
   ```

### Problem: "Invalid tester group"

**Solution**: Verify group exists in Firebase Console:
1. Go to Firebase Console → App Distribution
2. Check "Testers & Groups" tab
3. Use exact group alias in command

---

## Advanced Usage

### Custom APK Path

If APK is in non-standard location:

**PowerShell**:
```powershell
.\scripts\distribute-apk.ps1 -ApkPath "C:\custom\path\app.apk"
```

**Bash**:
```bash
./scripts/distribute-apk.sh /custom/path/app.apk
```

**Make**:
```bash
make distribute APK_PATH=/custom/path/app.apk
```

### Debug Mode

For verbose Firebase CLI output:

**PowerShell**:
```powershell
.\scripts\distribute-apk.ps1 -Debug
```

**Bash**:
```bash
DEBUG=true ./scripts/distribute-apk.sh
```

**Make**:
```bash
make distribute DEBUG=true
```

### CI-Only Distribution

Scripts automatically detect CI environment and use token authentication:

```yaml
# .github/workflows/distribute.yml
- name: Distribute to Firebase
  env:
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
  run: make distribute GROUPS="qa-testers"
```

---

## Tester Groups

### Default Groups

| Group | Alias | Purpose |
|-------|-------|---------|
| Internal Testers | `internal-testers` | Development team |
| QA Testers | `qa-testers` | QA and testing team |
| Beta Testers | `beta-testers` | External beta users |
| Stakeholders | `stakeholders` | Product owners, managers |

**Note**: Groups are managed in Firebase Console, not by scripts.

### Creating New Groups

1. Go to Firebase Console → App Distribution
2. Click "Testers & Groups" tab
3. Click "Add Group"
4. Set alias (used in scripts) and display name
5. Add tester emails to group

---

## Release Notes Best Practices

### Option 1: Inline Text
```bash
make distribute NOTES="Version 1.2.3: Fixed login bug, improved performance"
```

**Best for**: Quick distributions, small updates

### Option 2: File Reference
```bash
make distribute NOTES="@CHANGELOG.md"
```

**Best for**: Detailed releases, formatted notes

**File format** (CHANGELOG.md example):
```markdown
# Version 1.2.3 - 2026-01-04

## New Features
- Added dark mode support
- Improved search performance

## Bug Fixes
- Fixed login issue on Android 12
- Resolved crash on app resume

## Known Issues
- Occasional sync delay on slow networks
```

### Option 3: Empty (No Notes)
```bash
make distribute
```

**Best for**: Internal builds, quick tests

---

## Make Commands Reference

| Command | Purpose | Duration |
|---------|---------|----------|
| `make help` | Show available commands | Instant |
| `make distribute` | Upload existing APK | ~1-2 min |
| `make build-and-distribute` | Full pipeline | ~6-14 min |
| `make ci-all` | Run tests/analysis only | ~2-5 min |
| `make build-apk` | Build APK only | ~3-7 min |

---

## Workflow Examples

### Daily Development Workflow

```bash
# 1. Make code changes
# 2. Run CI checks locally
make ci-all

# 3. Build and distribute for testing
make build-and-distribute NOTES="Testing feature XYZ"

# 4. Testers receive notification and download APK
```

### Pre-Release Workflow

```bash
# 1. Update CHANGELOG.md with release notes

# 2. Build and distribute to QA
make build-and-distribute \
  GROUPS="qa-testers" \
  NOTES="@CHANGELOG.md"

# 3. QA validates

# 4. Distribute to beta testers
make distribute \
  GROUPS="beta-testers" \
  NOTES="@CHANGELOG.md"

# 5. Collect feedback, iterate
```

### Hotfix Workflow

```bash
# 1. Fix critical bug

# 2. Quick distribution (skip full CI for urgency)
make build-apk
make distribute NOTES="Hotfix: Critical login bug resolved"

# 3. Follow up with full CI later
make ci-all
```

---

## CI/CD Automation

### Automatic Distribution on Branch Push

Merging to `staging` or `develop` branches automatically distributes to testers.

**Configured in**: `.github/workflows/distribute.yml`

**Behavior**:
- Push to `staging` → distributes to `qa-testers`
- Push to `main` → distributes to `beta-testers` (if configured)
- Manual trigger available via GitHub Actions UI

**View distribution status**:
1. Go to repository on GitHub
2. Click "Actions" tab
3. Find "Firebase Distribution" workflow
4. View logs and status

---

## Tips and Best Practices

### ✅ Do's

- ✅ Use `make build-and-distribute` for regular workflow
- ✅ Include meaningful release notes for QA/beta distributions
- ✅ Test with `internal-testers` before wider distribution
- ✅ Use file-based notes (`@CHANGELOG.md`) for detailed releases
- ✅ Verify Firebase authentication before distributing
- ✅ Use dry run (`DRY_RUN=true`) to preview before uploading

### ❌ Don'ts

- ❌ Don't commit `FIREBASE_TOKEN` to repository (use GitHub Secrets)
- ❌ Don't distribute debug builds to external testers (always use release)
- ❌ Don't skip CI checks for non-urgent distributions
- ❌ Don't include sensitive information in release notes
- ❌ Don't assume tester groups exist - verify in Firebase Console first

---

## Next Steps

After successful distribution:

1. **Monitor notifications**: Check that testers received Firebase email/push notification
2. **Track installations**: View install metrics in Firebase Console → App Distribution → Releases
3. **Collect feedback**: Use feedback channels to gather tester input
4. **Iterate**: Make improvements and distribute updated builds

---

## Getting Help

### Check Distribution Logs

**Firebase Console**:
1. Go to Firebase Console → App Distribution
2. Click on release to view details
3. Check tester download status

**Local Logs** (if script failed):
- Review console output for error messages
- Use `DEBUG=true` for verbose logging
- Check exit code for error category

### Common Exit Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success | All good! |
| 1 | Firebase CLI missing | Install Firebase CLI |
| 2 | Not authenticated | Run `firebase login` |
| 3 | APK not found | Build APK first |
| 5 | Network error | Check connection, retry |
| 6 | Permission denied | Request Firebase access |

### Support Resources

- Firebase CLI docs: https://firebase.google.com/docs/cli
- App Distribution docs: https://firebase.google.com/docs/app-distribution
- Project documentation: `specs/012-firebase-apk-distribution/`

---

## Summary

**Quickest Path to First Distribution**:
```bash
# 1. Install Firebase CLI (if needed)
npm install -g firebase-tools

# 2. Authenticate
firebase login

# 3. Build and distribute
make build-and-distribute
```

**That's it!** Testers will receive notification and can download your APK.

---

**Document Version**: 1.0  
**Last Updated**: 2026-01-04  
**Status**: Phase 1 Design

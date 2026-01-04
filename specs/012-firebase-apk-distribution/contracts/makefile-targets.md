# Makefile Targets Contract

**Purpose**: Cross-platform build and distribution pipeline commands  
**Platform**: Cross-platform (uses Make for unified interface)  
**Phase**: Phase 1 - Design & Contracts

---

## Makefile Interface

### File Location
```text
Makefile  (repository root)
```

### Available Targets

| Target | Description | Dependencies |
|--------|-------------|--------------|
| `help` | Display available commands | None |
| `distribute` | Upload existing APK to Firebase | APK must exist |
| `build-and-distribute` | Run CI scripts + distribute | None (builds APK) |
| `ci-all` | Run existing CI scripts only | None |
| `build-apk` | Build release APK only | None |

---

## Target: `help`

**Purpose**: Display usage information and available commands

### Usage
```bash
make help
```

### Output
```text
Firebase APK Distribution - Available Commands:

  make help                 Show this help message
  make distribute           Distribute existing APK to Firebase
  make build-and-distribute Run CI + build + distribute pipeline
  make ci-all               Run CI scripts (test + analyze)
  make build-apk            Build release APK only

Prerequisites:
  - Firebase CLI installed (npm install -g firebase-tools)
  - Firebase authentication (firebase login or FIREBASE_TOKEN)
  - Flutter SDK installed

Configuration:
  - Default tester group: internal-testers
  - Override with: make distribute GROUPS="qa-testers"

Examples:
  make distribute
  make build-and-distribute
  make distribute GROUPS="beta-testers" NOTES="Release 1.2.3"
```

---

## Target: `distribute`

**Purpose**: Upload existing APK to Firebase App Distribution

### Preconditions
- APK file exists at: `build/app/outputs/flutter-apk/app-release.apk`
- Firebase CLI installed and authenticated
- firebase.json contains valid app ID

### Usage

**Basic (Windows)**:
```bash
make distribute
```
**Executes**: `powershell -ExecutionPolicy Bypass -File scripts/distribute-apk.ps1`

**Basic (Unix/Linux/macOS)**:
```bash
make distribute
```
**Executes**: `bash scripts/distribute-apk.sh`

### With Parameters

**Custom tester groups**:
```bash
make distribute GROUPS="qa-testers,beta-testers"
```

**With release notes**:
```bash
make distribute NOTES="Bug fixes and performance improvements"
```

**From file**:
```bash
make distribute NOTES="@CHANGELOG.md"
```

**Dry run**:
```bash
make distribute DRY_RUN=true
```

**Full example**:
```bash
make distribute GROUPS="internal-testers" NOTES="@CHANGELOG.md" DEBUG=true
```

### Success Criteria
- Exit code: 0
- APK uploaded to Firebase
- Testers receive notification
- Console shows release ID

### Error Handling
- If APK not found → Error message + exit 3
- If Firebase CLI missing → Error message + exit 1
- If authentication fails → Error message + exit 2
- Errors propagate to make command (make exits with same code)

---

## Target: `build-and-distribute`

**Purpose**: Execute complete build-to-distribution pipeline

### Pipeline Steps
1. Run existing CI scripts (`ci_all.ps1` or `ci_all.sh`)
   - Install dependencies (`flutter pub get`)
   - Run code analysis (`flutter analyze`)
   - Execute tests (`flutter test`)
   - Process for `bible_handler` package
2. Build release APK (`flutter build apk --release`)
3. Upload to Firebase App Distribution

### Usage

**Basic**:
```bash
make build-and-distribute
```

**With parameters**:
```bash
make build-and-distribute GROUPS="qa-testers" NOTES="Release 1.2.3"
```

**Skip tests** (optional enhancement):
```bash
make build-and-distribute SKIP_TESTS=true
```

### Expected Duration
- CI scripts: 2-5 minutes (tests + analysis)
- APK build: 3-7 minutes (release build + code generation)
- Distribution: 30 seconds - 2 minutes (upload)
- **Total**: ~6-14 minutes

### Success Criteria
- All CI checks pass (analysis + tests)
- APK builds successfully
- Upload completes without errors
- Exit code: 0

### Error Handling
- **CI script fails**: Pipeline stops, no APK built, exit with CI error code
- **Build fails**: Pipeline stops, no distribution, exit with build error code
- **Distribution fails**: APK exists but not distributed, exit with distribution error code
- Clear error messages at each stage

---

## Target: `ci-all`

**Purpose**: Run existing CI scripts without distribution

### Usage
```bash
make ci-all
```

### Behavior
- Executes `scripts/ci_all.ps1` (Windows) or `scripts/ci_all.sh` (Unix)
- Runs tests and analysis for root package and `bible_handler`
- Does NOT build APK
- Does NOT distribute

### Use Cases
- Local development pre-commit checks
- Verify code quality before build
- Quick validation without full pipeline

---

## Target: `build-apk`

**Purpose**: Build release APK without distribution

### Usage
```bash
make build-apk
```

### Behavior
- Executes `flutter build apk --release`
- Generates APK at: `build/app/outputs/flutter-apk/app-release.apk`
- Does NOT distribute

### Use Cases
- Manual testing before distribution
- Create APK for local testing
- Separate build from distribution workflow

---

## Platform Detection

### Implementation

```makefile
# Detect operating system
ifeq ($(OS),Windows_NT)
    # Windows detected
    SHELL := powershell.exe
    SCRIPT_EXT := .ps1
    SCRIPT_CMD := powershell -ExecutionPolicy Bypass -File
else
    # Unix/Linux/macOS detected
    SCRIPT_EXT := .sh
    SCRIPT_CMD := bash
endif
```

### Platform-Specific Behavior

**Windows**:
- Uses PowerShell scripts (`.ps1`)
- Shell: `powershell.exe`
- Execution: `powershell -ExecutionPolicy Bypass -File`

**Unix/Linux/macOS**:
- Uses Bash scripts (`.sh`)
- Shell: Default shell (typically Bash)
- Execution: `bash`

---

## Parameter Passing

### Makefile Variables

```makefile
# Variables with defaults
APK_PATH ?= build/app/outputs/flutter-apk/app-release.apk
GROUPS ?= internal-testers
NOTES ?=
DRY_RUN ?= false
DEBUG ?= false
```

### PowerShell Parameter Mapping

```makefile
distribute:
	$(SCRIPT_CMD) scripts/distribute-apk$(SCRIPT_EXT) \
		-ApkPath "$(APK_PATH)" \
		-Groups "$(GROUPS)" \
		$$(if $(NOTES),-ReleaseNotes "$(NOTES)") \
		$$(if $(DRY_RUN),-DryRun) \
		$$(if $(DEBUG),-Debug)
```

### Bash Parameter Mapping

```makefile
distribute:
	GROUPS="$(GROUPS)" \
	NOTES="$(NOTES)" \
	DRY_RUN=$(DRY_RUN) \
	DEBUG=$(DEBUG) \
	$(SCRIPT_CMD) scripts/distribute-apk$(SCRIPT_EXT) \
		"$(APK_PATH)"
```

---

## Error Codes

Make targets propagate script exit codes:

| Code | Source | Meaning |
|------|--------|---------|
| 0 | Success | All operations completed |
| 1 | Firebase CLI | CLI not installed |
| 2 | Authentication | Login required |
| 3 | APK | File not found |
| 4 | Configuration | Invalid app ID |
| 5 | Network | Upload failed |
| 6 | Permissions | Access denied |
| 10+ | CI Scripts | Test or analysis failures |
| 20+ | Flutter Build | Build compilation errors |

---

## Dependencies

### Required Tools
- Make (GNU Make 3.81+)
- Platform-appropriate shell:
  - Windows: PowerShell 5.1+
  - Unix: Bash 4.0+
- Firebase CLI 11.0.0+
- Flutter SDK

### Optional Tools
- jq (Unix JSON parsing, has fallback)

---

## Makefile Best Practices

### Phony Targets
```makefile
.PHONY: help distribute build-and-distribute ci-all build-apk
```
Ensures targets run even if files with same names exist.

### Silent Commands
```makefile
@echo "Message"  # @ suppresses command echo
```

### Error Propagation
```makefile
set -e  # Bash scripts
$ErrorActionPreference = "Stop"  # PowerShell
```

### Default Target
```makefile
.DEFAULT_GOAL := help
```
Running `make` without target shows help.

---

## Testing Contract

### Manual Test Cases

1. **make help**: Display usage information
2. **make distribute**: Upload existing APK
3. **make build-and-distribute**: Full pipeline
4. **make ci-all**: CI scripts only
5. **make build-apk**: Build without distribution
6. **Custom parameters**: Groups, notes, flags
7. **Platform detection**: Test on Windows and Unix
8. **Error propagation**: Verify exit codes
9. **Missing prerequisites**: Error messages
10. **Pipeline interruption**: Stop on CI failure

### Expected Behavior
- Commands execute appropriate platform scripts
- Parameters passed correctly
- Errors stop pipeline and propagate
- Success shows completion messages
- Help text is clear and actionable

---

## Examples

### Developer Daily Workflow

**1. Local testing**:
```bash
make ci-all                      # Run tests and analysis
make build-apk                   # Build APK
make distribute NOTES="Testing fix for issue #123"  # Distribute
```

**2. Quick distribution**:
```bash
make build-and-distribute       # One command for everything
```

**3. QA release**:
```bash
make distribute GROUPS="qa-testers" NOTES="@docs/release-notes.md"
```

### CI/CD Usage

**GitHub Actions** (workflow file):
```yaml
- name: Build and Distribute
  env:
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
  run: make build-and-distribute GROUPS="beta-testers"
```

---

## Version
**Contract Version**: 1.0  
**Date**: 2026-01-04  
**Status**: Phase 1 Design

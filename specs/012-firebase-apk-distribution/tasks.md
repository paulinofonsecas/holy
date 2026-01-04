# Implementation Tasks: Firebase APK Distribution Automation

**Feature**: 012-firebase-apk-distribution  
**Branch**: `012-firebase-apk-distribution`  
**Created**: 2026-01-04  
**Status**: Ready for Implementation

---

## Task Execution Guidelines

### Priority Levels
- **P1 (Critical)**: Manual APK distribution - Foundation for all workflows
- **P2 (High)**: Integrated pipeline - Developer workflow optimization  
- **P3 (Medium)**: Automated CI/CD - Full automation

### Execution Rules
- Execute tasks sequentially within each phase
- Tasks marked with **[P]** can be executed in parallel with other [P] tasks in the same phase
- Complete all tasks in a phase before moving to the next phase
- Mark completed tasks with [X]
- Test each component before proceeding to the next

### Phase Structure
1. **Setup Phase**: Project configuration and prerequisites
2. **Core Phase - P1**: Manual distribution scripts (foundational)
3. **Integration Phase - P2**: Build pipeline integration
4. **Automation Phase - P3**: CI/CD workflows
5. **Polish Phase**: Documentation and final validation

---

## SETUP PHASE

### SETUP-001: Create ignore file patterns
- [X] **Task**: Verify/create .gitignore entries for build artifacts and logs
- **Files**: `.gitignore`
- **Details**:
  - Add `build/` if not present
  - Add `logs/` for distribution logs
  - Add `.firebase/` for Firebase CLI cache
  - Verify no sensitive tokens in tracked files
- **Validation**: Run `git status` - no unwanted files staged
- **Estimated Time**: 5 minutes

### SETUP-002: Create scripts directory structure
- [X] **Task**: Ensure scripts directory exists with proper permissions
- **Files**: `scripts/` (directory)
- **Details**:
  - Directory already exists with ci_all.ps1 and ci_all.sh
  - No changes needed, just verification
- **Validation**: `scripts/` directory exists and is writable
- **Estimated Time**: 2 minutes

---

## CORE PHASE - P1: MANUAL DISTRIBUTION SCRIPTS

### P1-001: Implement PowerShell distribution script
- [X] **Task**: Create distribute-apk.ps1 with core distribution logic
- **Files**: `scripts/distribute-apk.ps1`
- **Dependencies**: SETUP phase complete
- **Details**:
  - Implement parameter parsing (ApkPath, AppId, ReleaseNotes, Groups, DryRun, Debug)
  - Add Firebase CLI installation check
  - Add authentication status check
  - Implement APK path auto-detection
  - Implement app ID extraction from firebase.json
  - Add file existence validation
  - Add app ID format validation
- **Validation**: Script loads without errors, help/usage displays correctly
- **Reference**: contracts/distribute-apk-ps1.md
- **Estimated Time**: 60 minutes

### P1-002: Add Firebase command builder (PowerShell)
- [X] **Task**: Implement Firebase CLI command construction logic
- **Files**: `scripts/distribute-apk.ps1`
- **Dependencies**: P1-001
- **Details**:
  - Build firebase appdistribution:distribute command
  - Add --app parameter
  - Add --groups or --testers parameter
  - Add --release-notes or --release-notes-file parameter
  - Add --token parameter if FIREBASE_TOKEN exists
  - Add --debug flag if Debug switch enabled
  - Implement DryRun mode (display command without executing)
- **Validation**: Command string correctly formatted, all parameters present
- **Estimated Time**: 30 minutes

### P1-003: Implement retry logic with exponential backoff (PowerShell)
- [X] **Task**: Add network error retry mechanism
- **Files**: `scripts/distribute-apk.ps1`
- **Dependencies**: P1-002
- **Details**:
  - Implement Invoke-WithRetry function
  - Max retries: 3
  - Initial delay: 5 seconds
  - Exponential backoff: 5s, 10s, 20s
  - Detect retriable errors (network, timeout, rate limit)
  - Fail fast on configuration errors (auth, permissions, invalid config)
  - Display retry progress messages
- **Validation**: Simulate network error, verify 3 retry attempts with correct delays
- **Estimated Time**: 45 minutes

### P1-004: Add error handling and exit codes (PowerShell)
- [X] **Task**: Implement comprehensive error handling
- **Files**: `scripts/distribute-apk.ps1`
- **Dependencies**: P1-003
- **Details**:
  - Exit code 0: Success
  - Exit code 1: Firebase CLI not installed
  - Exit code 2: Authentication required
  - Exit code 3: APK not found
  - Exit code 4: Invalid app ID
  - Exit code 5: Network/upload error
  - Exit code 6: Permission denied
  - Exit code 7: Invalid tester group
  - Exit code 99: Unknown error
  - Clear error messages with actionable guidance
  - Log all errors with timestamps
- **Validation**: Test each error scenario, verify correct exit codes and messages
- **Estimated Time**: 30 minutes

### P1-005: Implement Bash distribution script
- [X] **Task**: Create distribute-apk.sh with equivalent functionality
- **Files**: `scripts/distribute-apk.sh`
- **Dependencies**: P1-004 (use as reference)
- **Details**:
  - Add shebang: #!/bin/bash
  - Set error handling: set -e, set -u, set -o pipefail
  - Implement positional parameter parsing
  - Implement environment variable flags (DRY_RUN, DEBUG)
  - Port all functionality from PowerShell version
  - Use jq for JSON parsing with grep/sed fallback
  - Match all features: auto-detection, validation, retry, error handling
  - Ensure exit codes match PowerShell version
- **Validation**: Compare behavior with PowerShell version, ensure identical outcomes
- **Reference**: contracts/distribute-apk-sh.md
- **Estimated Time**: 90 minutes

### P1-006: Add execution permissions to Bash script
- [X] **Task**: Make distribute-apk.sh executable
- **Files**: `scripts/distribute-apk.sh`
- **Dependencies**: P1-005
- **Details**:
  - Run: chmod +x scripts/distribute-apk.sh
  - Verify script is executable
  - Test execution: ./scripts/distribute-apk.sh --help
- **Validation**: Script executes without "Permission denied" error
- **Estimated Time**: 2 minutes

### P1-007: Test manual distribution (PowerShell) [P]
- [ ] **Task**: Manual testing of PowerShell distribution script
- **Files**: Test execution, no file changes
- **Dependencies**: P1-004
- **Details**:
  - Test 1: Auto-detect APK (default behavior)
  - Test 2: Custom APK path parameter
  - Test 3: Release notes text parameter
  - Test 4: Release notes from file (@CHANGELOG.md)
  - Test 5: Custom tester groups
  - Test 6: Dry run mode
  - Test 7: Debug mode
  - Test 8: Error scenarios (missing CLI, not authenticated, APK not found)
  - Document results
- **Validation**: All test cases pass, script behaves according to contract
- **Estimated Time**: 45 minutes

### P1-008: Test manual distribution (Bash) [P]
- [ ] **Task**: Manual testing of Bash distribution script
- **Files**: Test execution, no file changes
- **Dependencies**: P1-006
- **Details**:
  - Execute same test cases as P1-007 in Unix/Linux environment
  - Verify behavior matches PowerShell version
  - Test on Ubuntu (GitHub Actions environment) if possible
  - Test on macOS if available
  - Test on WSL2 for Windows developers
- **Validation**: All test cases pass, behavior identical to PowerShell version
- **Estimated Time**: 45 minutes

---

## INTEGRATION PHASE - P2: BUILD PIPELINE

### P2-001: Create PowerShell build-and-distribute script
- [ ] **Task**: Implement full pipeline script for Windows
- **Files**: `scripts/build-and-distribute.ps1`
- **Dependencies**: P1-007 (P1 tests passing)
- **Details**:
  - Parameters: ReleaseNotes, Groups, SkipTests, DryRun
  - Step 1: Run ci_all.ps1 (unless SkipTests)
  - Step 2: Run flutter build apk --release
  - Step 3: Call distribute-apk.ps1 with parameters
  - Display progress for each step
  - Exit on any step failure
  - Report total pipeline duration
- **Validation**: Full pipeline executes successfully end-to-end
- **Estimated Time**: 45 minutes

### P2-002: Create Bash build-and-distribute script
- [ ] **Task**: Implement full pipeline script for Unix/Linux
- **Files**: `scripts/build-and-distribute.sh`
- **Dependencies**: P1-008 (P1 tests passing)
- **Details**:
  - Environment variables: RELEASE_NOTES, GROUPS, SKIP_TESTS, DRY_RUN
  - Step 1: Run ci_all.sh (unless SKIP_TESTS=true)
  - Step 2: Run flutter build apk --release
  - Step 3: Call distribute-apk.sh with parameters
  - Match PowerShell functionality
  - Add execution permissions
- **Validation**: Full pipeline executes successfully end-to-end
- **Estimated Time**: 45 minutes

### P2-003: Create Makefile with cross-platform targets
- [ ] **Task**: Implement Make commands for unified interface
- **Files**: `Makefile`
- **Dependencies**: P2-001, P2-002
- **Details**:
  - Implement platform detection (Windows vs Unix)
  - Target: help (display usage)
  - Target: distribute (call distribute-apk script)
  - Target: build-and-distribute (call build-and-distribute script)
  - Target: ci-all (call ci_all script)
  - Target: build-apk (flutter build apk)
  - Set .DEFAULT_GOAL := help
  - Mark all targets as .PHONY
  - Implement parameter passing (GROUPS, NOTES, DRY_RUN, DEBUG)
- **Validation**: All make targets execute correctly on both platforms
- **Reference**: contracts/makefile-targets.md
- **Estimated Time**: 60 minutes

### P2-004: Test integrated pipeline (PowerShell) [P]
- [ ] **Task**: Test build-and-distribute.ps1 end-to-end
- **Files**: Test execution
- **Dependencies**: P2-001
- **Details**:
  - Test 1: Full pipeline with default parameters
  - Test 2: With custom release notes
  - Test 3: With custom tester groups
  - Test 4: Skip tests flag
  - Test 5: Dry run mode
  - Test 6: Pipeline failure scenarios (CI failure, build failure)
  - Measure total execution time
- **Validation**: Pipeline completes successfully, APK distributed
- **Estimated Time**: 30 minutes

### P2-005: Test integrated pipeline (Bash) [P]
- [ ] **Task**: Test build-and-distribute.sh end-to-end
- **Files**: Test execution
- **Dependencies**: P2-002
- **Details**:
  - Execute same test cases as P2-004 in Unix environment
  - Verify behavior matches PowerShell version
  - Measure execution time
- **Validation**: Pipeline completes successfully, matches PowerShell behavior
- **Estimated Time**: 30 minutes

### P2-006: Test Make targets [P]
- [ ] **Task**: Test all Makefile targets on both platforms
- **Files**: Test execution
- **Dependencies**: P2-003
- **Details**:
  - Test: make help (displays usage)
  - Test: make distribute (uploads existing APK)
  - Test: make build-and-distribute (full pipeline)
  - Test: make ci-all (CI scripts only)
  - Test: make build-apk (build only)
  - Test: make distribute GROUPS="qa-testers" NOTES="Test"
  - Test on Windows (PowerShell)
  - Test on Unix/Linux (Bash)
- **Validation**: All targets work correctly, parameters passed properly
- **Estimated Time**: 30 minutes

---

## AUTOMATION PHASE - P3: CI/CD WORKFLOWS

### P3-001: Create GitHub Actions distribution workflow
- [ ] **Task**: Implement automated distribution workflow
- **Files**: `.github/workflows/distribute.yml`
- **Dependencies**: P2-006 (P2 tests passing)
- **Details**:
  - Trigger on push to: staging, develop branches
  - Add workflow_dispatch for manual trigger
  - Setup Flutter (version 3.38.5, cache: true)
  - Install dependencies
  - Run build_runner
  - Build APK (flutter build apk --release)
  - Install Firebase CLI (npm install -g firebase-tools)
  - Distribute to Firebase (use FIREBASE_TOKEN and FIREBASE_APP_ID secrets)
  - Use appropriate tester groups based on branch
  - Include commit info in release notes
  - Handle errors and report status
- **Validation**: Workflow syntax valid, runs successfully in GitHub Actions
- **Estimated Time**: 45 minutes

### P3-002: Update existing CI workflow (optional enhancement)
- [ ] **Task**: Add distribution step to ci.yml workflow
- **Files**: `.github/workflows/ci.yml`
- **Dependencies**: P3-001
- **Details**:
  - Add distribution job after build job
  - Only run on specific branches (optional)
  - Use if: success() condition
  - Reuse setup from existing workflow
  - Add Firebase distribution step
- **Validation**: CI workflow runs successfully with distribution
- **Estimated Time**: 20 minutes

### P3-003: Update release workflow with distribution
- [ ] **Task**: Add Firebase distribution to release.yml
- **Files**: `.github/workflows/release.yml`
- **Dependencies**: P3-001
- **Details**:
  - Add distribution step after APK/AAB build
  - Distribute to beta-testers group for releases
  - Use release tag in release notes
  - Maintain existing GitHub Release creation
  - Add Firebase distribution as additional distribution channel
- **Validation**: Release workflow creates GitHub Release AND distributes to Firebase
- **Estimated Time**: 20 minutes

### P3-004: Test CI/CD workflows [P]
- [ ] **Task**: Validate automated distribution in GitHub Actions
- **Files**: Test execution (GitHub Actions)
- **Dependencies**: P3-001, P3-002, P3-003
- **Details**:
  - Test 1: Push to staging branch (triggers distribute.yml)
  - Test 2: Manual workflow trigger via GitHub UI
  - Test 3: Create release tag (triggers release.yml with distribution)
  - Test 4: Verify APK uploaded to Firebase
  - Test 5: Verify testers receive notifications
  - Test 6: Check workflow execution logs
  - Test 7: Verify secrets are properly configured
- **Validation**: All workflows execute successfully, APKs distributed
- **Estimated Time**: 45 minutes

---

## POLISH PHASE: DOCUMENTATION & VALIDATION

### POLISH-001: Create developer documentation
- [ ] **Task**: Write comprehensive usage guide
- **Files**: `docs/firebase-distribution-guide.md`
- **Dependencies**: All P1, P2, P3 tasks complete
- **Details**:
  - Prerequisites section
  - Quick start guide
  - Command reference (scripts and Make targets)
  - Common usage scenarios
  - Troubleshooting guide
  - CI/CD setup instructions
  - Include examples from quickstart.md
- **Validation**: Documentation is clear, complete, and accurate
- **Estimated Time**: 60 minutes

### POLISH-002: Update README with distribution info
- [ ] **Task**: Add Firebase distribution section to main README
- **Files**: `README.md`
- **Dependencies**: POLISH-001
- **Details**:
  - Add "APK Distribution" section
  - Link to detailed guide (docs/firebase-distribution-guide.md)
  - Quick reference for common commands
  - Prerequisites summary
- **Validation**: README clearly explains distribution feature
- **Estimated Time**: 15 minutes

### POLISH-003: Final integration testing
- [ ] **Task**: Complete end-to-end validation
- **Files**: Test execution
- **Dependencies**: All tasks complete
- **Details**:
  - Test complete workflow: code change → CI → build → distribute
  - Test manual distribution scenarios
  - Test Make commands
  - Test GitHub Actions workflows
  - Verify testers receive APKs
  - Check all error scenarios
  - Verify documentation accuracy
  - Test on Windows, Linux, and macOS if possible
- **Validation**: All features work as specified, all tests pass
- **Estimated Time**: 90 minutes

### POLISH-004: Create distribution demo/video (optional)
- [ ] **Task**: Record screen demo of distribution workflow
- **Files**: `docs/demo-distribution.mp4` or link
- **Dependencies**: POLISH-003
- **Details**:
  - Show manual distribution
  - Show Make command usage
  - Show automated CI/CD distribution
  - Demonstrate error handling
  - Show tester notification and APK download
- **Validation**: Demo clearly shows all features
- **Estimated Time**: 45 minutes (optional)

---

## Task Summary

### Phase Breakdown

**SETUP**: 2 tasks (~7 minutes)  
**CORE - P1**: 8 tasks (~6 hours)  
**INTEGRATION - P2**: 6 tasks (~4.5 hours)  
**AUTOMATION - P3**: 4 tasks (~2.5 hours)  
**POLISH**: 4 tasks (~3.5 hours)

**Total**: 24 tasks  
**Estimated Time**: ~16-20 hours (2-3 days with testing)

### Parallel Execution Opportunities

- P1-007 and P1-008 can run in parallel (testing phase)
- P2-004, P2-005, and P2-006 can run in parallel (testing phase)
- P3-004 can start while P3-002/P3-003 are in progress

### Critical Path

SETUP → P1-001 → P1-002 → P1-003 → P1-004 → P2-001 → P2-003 → P3-001 → POLISH-003

### Success Criteria

- [ ] All scripts execute without errors
- [ ] Manual distribution works on Windows and Unix
- [ ] Integrated pipeline completes end-to-end
- [ ] Make commands work cross-platform
- [ ] CI/CD workflows distribute automatically
- [ ] Documentation is complete and accurate
- [ ] All tests pass

---

**Last Updated**: 2026-01-04  
**Status**: Ready to begin implementation  
**Next Step**: Start with SETUP-001

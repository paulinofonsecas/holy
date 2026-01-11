# Implementation Plan: Firebase Distribution in GitHub Actions

**Branch**: `002-firebase-dist-gh-actions` | **Date**: 2026-01-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/002-firebase-dist-gh-actions/spec.md`

## Summary

Automate the distribution of the "Eu Sou" Flutter application using GitHub Actions and Firebase App Distribution. The solution will include a workflow that triggers on pushes to `main` and `develop` branches, as well as a `manual` trigger for custom branches. It will build a signed Android App Bundle (AAB) and distribute it to a pre-defined tester group in Firebase using a Firebase CLI Token for authentication.

## Technical Context

**Language/Version**: Flutter (SDK ^3.6.0), Dart (^3.6.0)  
**Primary Dependencies**: `w9jds/setup-firebase@v2`, `actions/checkout@v4`, `subosito/flutter-action@v2`  
**Storage**: N/A (Cloud distribution)  
**Testing**: App Bundle verification on Firebase console  
**Target Platform**: Android (AAB format)
**Project Type**: Flutter Mobile App  
**Performance Goals**: Build and upload completion < 15 minutes.  
**Constraints**: Secure management of Firebase CLI tokens and Android Keystores via GitHub Secrets.  
**Scale/Scope**: CI/CD pipeline for automated and manual distribution.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **VI. Consistent Navigation**: N/A for this infrastructure feature.
- **I. Monorepo & Modularization**: Compliant. The CI workflow resides in the root `.github/workflows/` and manages the main app build.

## Project Structure

### Documentation (this feature)

```text
specs/002-firebase-dist-gh-actions/
├── plan.md              # This file
├── research.md          # Implementation details for signing and firebase auth
├── data-model.md        # N/A (Infrastructure)
├── quickstart.md        # Guide for setting up GH Secrets (FIREBASE_TOKEN, etc.)
├── contracts/           # N/A
└── tasks.md             # Implementation steps
```

### Source Code (repository root)

```text
.github/
└── workflows/
    └── firebase-distribution.yml  # Main CI workflow
```

**Structure Decision**: Standard GitHub Actions workflow structure.

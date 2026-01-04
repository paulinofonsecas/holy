# GitHub Actions CI/CD Pipeline

This directory contains the GitHub Actions workflow definitions for the `eu_sou` project.

## Workflows

### 1. PR Checks (`pr-checks.yml`)
- **Trigger**: Pull requests to `main` or `develop`, and pushes to `main` or `develop`.
- **Purpose**: Ensures code quality and stability before merging.
- **Runner**: `windows-latest`
- **Steps**:
  - Sets up Java 17 and Flutter 3.38.4.
  - Caches Pub dependencies.
  - Runs `flutter analyze` and `flutter test` across all packages (root and `packages/bible_handler`) using `scripts/ci_all.ps1`.

### 2. Release (`release.yml`)
- **Trigger**: Pushes with tags matching `v*` (e.g., `v1.0.0`).
- **Purpose**: Builds and releases Android binaries.
- **Runner**: `windows-latest`
- **Steps**:
  - Sets up Java 17 and Flutter 3.38.4.
  - Caches Pub and Gradle dependencies.
  - Builds Release APK and AAB.
  - Creates a GitHub Release and uploads `app-release.apk` and `app-release.aab`.

## Required Secrets

The CI/CD pipeline currently does not require manual secrets for basic builds and releases, as signing has been disabled.

- `GITHUB_TOKEN`: Automatically provided by GitHub Actions.

## Scripts

- `scripts/ci_all.ps1`: A PowerShell helper script to run analysis and tests across the monorepo on Windows.

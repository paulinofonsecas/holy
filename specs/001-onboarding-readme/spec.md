# Feature Specification: Onboarding README for Windows and macOS

**Feature Branch**: `001-onboarding-readme`
**Created**: 2026-01-18
**Status**: Draft
**Input**: User description: "crie o readme de onboarding completo para rodar ou buildar este projeto em qualquer sistema windows ou macos"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - New Windows Developer Onboarding (Priority: P1)

As a new Windows developer, I want to follow a step-by-step guide to set up my environment, install dependencies, and run the application on an Android emulator or Windows desktop so that I can start contributing immediately.

**Why this priority**: Essential for expanding the team and ensuring Windows developers can work on the project without frustration.

**Independent Test**: A user with a fresh Windows installation follows the guide and successfully launches the app in debug mode.

**Acceptance Scenarios**:

1. **Given** a Windows 10/11 machine, **When** following the Windows setup section, **Then** all required tools (Flutter, Android SDK, VS Code) are installed.
2. **Given** the repository is cloned, **When** running the specified initialization commands, **Then** all internal dependencies (including `bible_handler`) are resolved.
3. **Given** dependencies are installed, **When** running `flutter run -d windows`, **Then** the app opens correctly.

---

### User Story 2 - New macOS Developer Onboarding (Priority: P1)

As a new macOS developer, I want to follow a step-by-step guide to set up my environment for iOS and macOS development so that I can build and run the app on Apple devices.

**Why this priority**: Essential for cross-platform support and ensuring macOS-specific features can be developed.

**Independent Test**: A user with a fresh macOS installation follows the guide and successfully builds the app for iOS or macOS.

**Acceptance Scenarios**:

1. **Given** a macOS machine, **When** following the Apple setup section, **Then** Xcode and CocoaPods are correctly configured.
2. **Given** the project is initialized, **When** running `flutter run -d ios`, **Then** the app launches on an iOS simulator.

---

### User Story 3 - Building for Production (Priority: P2)

As a developer or CI/CD engineer, I want to know the exact commands and prerequisites to build a release version of the app for Android and Windows/macOS.

**Why this priority**: Necessary for distributing the app to testers or stores.

**Independent Test**: Running the build command produces a valid signed or unsigned artifact.

**Acceptance Scenarios**:

1. **Given** the environment is set up, **When** running `make build`, **Then** a release APK is generated in the build directory.

---

### Edge Cases

- **Missing .env file**: How does the developer create or obtain the necessary environment variables?
- **Missing Firebase config**: Does the app fail to start or run in a "mock" mode if `google-services.json` is missing?
- **Native Dependency conflicts**: Handling `sqflite` or `sqlite3` native library issues on Windows (e.g., missing C++ redistributables).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The guide MUST provide a clear list of prerequisites for both Windows and macOS (Flutter version, Dart SDK, OS-specific tools).
- **FR-002**: The guide MUST detail the step-by-step initialization process, including sub-package dependency resolution (Mono-repo management).
- **FR-003**: The guide MUST explain how to configure the `.env` file based on a template or example.
- **FR-004**: System MUST document how to connect to a local or remote Bible Server, noting that it is an optional dependency for advanced feature testing.
- **FR-005**: The guide MUST provide troubleshooting steps for common Flutter/Native errors (e.g., CocoaPods issues on macOS, Android SDK path on Windows).
- **FR-006**: The guide MUST document how to use the `Makefile` for standard tasks.

### Key Entities *(include if feature involves data)*

- **Onboarding Guide**: The markdown document containing all instructions.
- **Prerequisites**: Tools and SDKs required before cloning.
- **Project Structure**: Explanation of the monorepo and its internal packages (e.g., `bible_handler`).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Average onboarding time (setup to first run) for a new developer is under 60 minutes.
- **SC-002**: The guide covers 100% of the platforms supported by the project (Android, iOS, Windows, macOS, Web).
- **SC-003**: 0% of the "Getting Started" steps rely on manual, undocumented file editing (excluding `.env` configuration).
- **SC-004**: Success rate of first-time "build" commands (following the guide) is above 90% for developers with correct hardware.

## Assumptions

- The project targets Flutter version ^3.6.0 as per `pubspec.yaml`.
- The `bible_handler` package is a critical part of the core functionality.
- Developers have basic knowledge of Git and terminal usage.

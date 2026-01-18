# Data Model: Documentation Structure

## Entities

### Onboarding Documentation
A collection of markdown files designed to guide a developer from "clone" to "success run".

**Fields**:
- `Root README (README.md)`: Entry point, feature overview, Quick Start.
- `Setup Guide (doc/SETUP_GUIDE.md)`: Deep dive into OS-specific prerequisites and troubleshooting.
- `Environment Template (.env.example)`: Template for sensitive configurations.

## Hierarchy

1. **README.md** (Quick focus)
   - Prerequisite summary
   - 3-step Quick Start
   - Link to SETUP_GUIDE.md
2. **doc/SETUP_GUIDE.md** (Deep focus)
   - Windows Detailed Setup (Visual Studio, SDKs)
   - macOS Detailed Setup (Xcode, CocoaPods)
   - Monorepo Setup (bible_handler linkage)
   - Troubleshooting common build errors
3. **.env.example**
   - Required keys: `API_BASE_URL`, `FIREBASE_API_KEY`, etc.

## Transitions

- **Uninitialized** -> **Environment Ready** (Tools installed)
- **Environment Ready** -> **Dependencies Resolved** (Pub get successful)
- **Dependencies Resolved** -> **Application Running** (First build)

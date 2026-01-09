# Research: Firebase Distribution in GitHub Actions

## Unknowns & Research Tasks

### 1. Firebase CLI Token Generation
- **Decision**: Use `firebase login:ci` to generate a long-lived token.
- **Rationale**: Standard method for non-interactive environments like GitHub Actions.
- **Alternatives considered**: Google Service Account JSON (deprecated for some legacy actions, but generally better for security. Given the user's "Option B" preference for Firebase CLI Token, we will stick with the token).

### 2. Android App Bundle Signing in CI
- **Decision**: Store the Keystore base64-encoded in GitHub Secrets. Use a shell script or a specialized action to decode and write it to a temporary path during build.
- **Rationale**: Keeps sensitive binary files out of the repository while making them available to the CI environment.
- **Alternatives considered**: Checking in the keystore (Security risk), using Google Play Console internal app sharing (requires more setup).

### 3. Firebase App Distribution Action
- **Decision**: Use `w9jds/setup-firebase` to setup the environment and then use the Firebase CLI directly, or use a specialized action like `FirebaseExtended/action-hosting-deploy` (though that's for hosting). For App Distribution, `w9jds/firebase-action` is widely used.
- **Rationale**: `w9jds/firebase-action` provides direct access to Firebase CLI commands.
- **Implementation**: `firebase appdistribution:distribute <path_to_aab> --app <app_id> --groups <group_name> --release-notes "<notes>"`

### 4. Automated Release Notes
- **Decision**: Use a git command to extract commit messages between the current HEAD and the last successful build or tag.
- **Rationale**: Simple, zero-dependency way to provide context to testers.
- **Command**: `git log --pretty=format:"%s" -n 10` (last 10 commits as a starting point).

## Technology Choices & Best Practices

- **Tech**: GitHub Actions
- **Best Practice**: Use `actions/cache` to speed up Flutter builds by caching the pub cache and build artifacts.
- **Best Practice**: Use `workflow_dispatch` to allow manual triggers as requested in FR-004.
- **Best Practice**: Use `environment` in GitHub Actions for secret management to restrict access to the production Firebase token.

# Research: User Feedback & About Page Implementation

## Decision: Feedback Integration with Firebase Crashlytics
**Rationale**: The `feedback` package provides a user-friendly way to capture text and screenshots. Since Crashlytics doesn't natively support image attachments, we will upload screenshots to Firebase Storage and link them via custom keys and non-fatal error reports in Crashlytics.

**Alternatives considered**:
- **Email Client**: Simple but inconsistent across devices and doesn't capture screenshots easily.
- **Custom Backend**: Provides full control but requires server-side development and maintenance.

## Decision: About Page with `package_info_plus` and `url_launcher`
**Rationale**: `package_info_plus` ensures the version displayed is always accurate to the build. `url_launcher` is the standard for opening external links. Using `showLicensePage` fulfills legal requirements for open-source software.

## Findings

### Feedback Workflow
1. Wrap the app in `BetterFeedback`.
2. On submission:
   - Upload screenshot to `FirebaseStorage` (path: `feedback/{timestamp}.png`).
   - Get download URL.
   - Log feedback text to `FirebaseCrashlytics.instance.log`.
   - Set custom key `feedback_screenshot_url`.
   - Record non-fatal error `User Feedback Report` with the text as the reason.

### About Page Content
- App Icon, Name, Version (from `package_info_plus`).
- Links to Social Media/Website (via `url_launcher`).
- "View Licenses" button (via `showLicensePage`).

### Offline Handling
- Crashlytics queues logs and errors automatically.
- Screenshot upload will fail offline; the service should catch this and either skip the upload or notify the user.

### Best Practices
- Use `device_info_plus` to include device model and OS version in the Crashlytics report.
- Use `LaunchMode.externalApplication` for `url_launcher` to ensure native app handling.

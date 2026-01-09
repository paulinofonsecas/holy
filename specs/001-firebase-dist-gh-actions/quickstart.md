# Quickstart: Setting up Firebase Distribution in GitHub Actions

This guide explains how to configure the necessary secrets and environment to enable automated Firebase distribution.

## Prerequisites

1.  **Firebase Project**: Ensure you have a Firebase project with "App Distribution" enabled for the Android app.
2.  **Tester Groups**: Create a group in Firebase App Distribution (e.g., `internal-testers`) and add the testers' emails.

## Step 1: Generate Firebase Token

1.  Install Firebase CLI locally: `npm install -g firebase-tools`
2.  Run the CI login command: `firebase login:ci`
3.  Authenticate in your browser.
4.  Copy the token printed in the terminal.

## Step 2: Configure GitHub Secrets

Go to your GitHub repository -> Settings -> Secrets and variables -> Actions. Add the following repository secrets:

-   `FIREBASE_TOKEN`: The token generated in Step 1.
-   `FIREBASE_APP_ID`: Found in Firebase Console -> Project Settings -> Your Apps -> App ID (e.g., `1:1234567890:android:abc123def456`).

## Step 3: Triggering the Workflow

### Automatic
-   Push or merge code to the `main` or `develop` branches.
-   The workflow will automatically build the App Bundle (AAB) and distribute it.

### Manual
1.  Go to the **Actions** tab in GitHub.
2.  Select **Firebase Distribution**.
3.  Click **Run workflow**.
4.  Optionally provide release notes and specific tester groups.

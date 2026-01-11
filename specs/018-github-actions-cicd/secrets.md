# GitHub Secrets Configuration

The CI/CD pipeline currently does not require manual secrets for basic builds and releases, as signing has been disabled per user request.

## GitHub Token

| Secret Name | Description |
|-------------|-------------|
| `GITHUB_TOKEN` | Automatically provided by GitHub Actions. Used for creating releases and uploading assets. Ensure the workflow has `contents: write` permissions. |

## Future: Android Signing (Optional)

If you decide to re-enable signing in the future, you will need:
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

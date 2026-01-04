Write-Host "Running CI for all packages on Windows..."

# Root package
Write-Host "--- Root Package ---"
flutter pub get
flutter analyze
flutter build apk --release
flutter test

Write-Host "CI completed successfully!"

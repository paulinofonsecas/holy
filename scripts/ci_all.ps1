Write-Host "Running CI for all packages on Windows..."

# Root package
Write-Host "--- Root Package ---"
flutter pub get
flutter analyze
flutter test

# bible_handler package
Write-Host "--- bible_handler Package ---"
Push-Location packages/bible_handler
flutter pub get
flutter analyze
flutter test
Pop-Location

Write-Host "CI completed successfully!"

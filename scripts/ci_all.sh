#!/bin/bash

# Exit on error
set -e

echo "Running CI for all packages..."

# Root package
echo "--- Root Package ---"
flutter pub get
flutter analyze
flutter test

# bible_handler package
echo "--- bible_handler Package ---"
cd packages/bible_handler
flutter pub get
flutter analyze
flutter test
cd ../..

echo "CI completed successfully!"

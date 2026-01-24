#!/bin/bash

# Exit on error
set -e

echo "Running CI for all packages..."

# Root package
echo "--- Root Package ---"
flutter pub get
flutter analyze
flutter test

echo "CI completed successfully!"

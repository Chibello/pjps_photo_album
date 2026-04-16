#!/bin/bash

echo "🧹 Cleaning project..."

# Flutter clean
flutter clean

# Remove build directories
rm -rf build/
rm -rf .dart_tool/

# Remove logs
rm -rf *.log

# Remove iOS build artifacts
rm -rf ios/Pods
rm -rf ios/Podfile.lock

# Remove Android build artifacts
rm -rf android/.gradle
rm -rf android/app/build

# Remove temporary files
find . -name "*.bak" -type f -delete
find . -name "*.tmp" -type f -delete

echo "✅ Clean complete!"
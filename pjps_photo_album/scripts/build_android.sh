#!/bin/bash

echo "📱 Building Android APK..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build app bundle for Play Store
flutter build appbundle --release

echo ""
echo "✅ Android builds complete!"
echo "📦 Debug APK: build/app/outputs/flutter-apk/app-debug.apk"
echo "📦 Release APK: build/app/outputs/flutter-apk/app-release.apk"
echo "📦 App Bundle: build/app/outputs/bundle/release/app-release.aab"
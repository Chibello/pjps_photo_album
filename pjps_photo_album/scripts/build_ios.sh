#!/bin/bash

echo "🍎 Building iOS app..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for simulator
flutter build ios --debug --simulator

# Build for device
flutter build ios --release

echo ""
echo "✅ iOS builds complete!"
echo "📦 Open Xcode: open ios/Runner.xcworkspace"
echo "Then: Product > Archive to create IPA"
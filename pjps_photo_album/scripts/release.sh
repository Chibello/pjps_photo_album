#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Please provide version number"
    echo "Usage: ./release.sh 1.0.0"
    exit 1
fi

echo "📦 Creating release v$VERSION..."

# Create release directory
mkdir -p releases/v$VERSION

# Build for all platforms
./scripts/build_android.sh
./scripts/build_ios.sh

# Copy artifacts
cp build/app/outputs/flutter-apk/app-release.apk "releases/v$VERSION/PJPS-Photo-Album-v$VERSION.apk"
cp build/app/outputs/bundle/release/app-release.aab "releases/v$VERSION/PJPS-Photo-Album-v$VERSION.aab"

# Create release notes
cat > "releases/v$VERSION/RELEASE_NOTES.md" << EOF
# PJPS Photo Album v$VERSION

## What's New
- Full offline support
- Fingerprint login
- Photo albums by year/class
- Staff directory
- Remarks system

## Installation
- Android: Download the APK file
- iOS: Available on TestFlight

## Requirements
- Android 8.0+ or iOS 13.0+
- 100MB free space
EOF

# Create zip archive
cd releases
zip -r "PJPS-Photo-Album-v$VERSION.zip" "v$VERSION"
cd ..

echo ""
echo "✅ Release v$VERSION created!"
echo "📦 Archive: releases/PJPS-Photo-Album-v$VERSION.zip"
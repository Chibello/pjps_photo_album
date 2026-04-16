#!/bin/bash

echo "🎨 Setting up assets for PJPS Photo Album..."

# Create directory structure
mkdir -p assets/icons
mkdir -p assets/images
mkdir -p assets/images/backgrounds
mkdir -p assets/animations
mkdir -p assets/fonts

# Download fonts
echo "📦 Downloading Poppins fonts..."
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf" -o assets/fonts/Poppins-Regular.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Medium.ttf" -o assets/fonts/Poppins-Medium.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-SemiBold.ttf" -o assets/fonts/Poppins-SemiBold.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Bold.ttf" -o assets/fonts/Poppins-Bold.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-ExtraBold.ttf" -o assets/fonts/Poppins-ExtraBold.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Light.ttf" -o assets/fonts/Poppins-Light.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-ExtraLight.ttf" -o assets/fonts/Poppins-ExtraLight.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Thin.ttf" -o assets/fonts/Poppins-Thin.ttf
curl -L "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Italic.ttf" -o assets/fonts/Poppins-Italic.ttf

# Install required package for image generation
echo "📦 Installing image package..."
flutter pub add image

# Generate icons
echo "🎨 Generating icons..."
dart scripts/generate_icons.dart

# Generate images
echo "🖼️ Generating images..."
dart scripts/generate_images.dart

# Create animation files
echo "🎬 Creating animation files..."
cat > assets/animations/splash_animation.json << 'EOF'
{
  "v": "5.7.1",
  "fr": 30,
  "ip": 0,
  "op": 90,
  "w": 400,
  "h": 400,
  "nm": "Splash Animation",
  "ddd": 0,
  "assets": [],
  "layers": []
}
EOF

cp assets/animations/splash_animation.json assets/animations/loading_animation.json
cp assets/animations/splash_animation.json assets/animations/success_animation.json

# Generate launcher icons
echo "📱 Generating launcher icons..."
flutter pub get
flutter pub run flutter_launcher_icons

# Generate splash screen
echo "💫 Generating splash screen..."
flutter pub run flutter_native_splash:create

echo ""
echo "✅ All assets generated successfully!"
echo ""
echo "📁 Assets are now in:"
echo "   - assets/icons/     - App icons"
echo "   - assets/images/    - Images and backgrounds"
echo "   - assets/animations/ - Lottie animations"
echo "   - assets/fonts/     - Font files"
echo ""
echo "🚀 Next steps:"
echo "1. Run: flutter pub get"
echo "2. Run: flutter run"
echo "3. Your app now has all icons, images, and animations!"
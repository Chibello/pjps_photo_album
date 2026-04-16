@echo off
echo 🎨 Setting up assets for PJPS Photo Album...

REM Create directory structure
mkdir assets\icons 2>nul
mkdir assets\images 2>nul
mkdir assets\images\backgrounds 2>nul
mkdir assets\animations 2>nul
mkdir assets\fonts 2>nul

REM Download fonts using PowerShell
echo 📦 Downloading Poppins fonts...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf' -OutFile 'assets\fonts\Poppins-Regular.ttf'"
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Bold.ttf' -OutFile 'assets\fonts\Poppins-Bold.ttf'"

REM Install required package
echo 📦 Installing image package...
flutter pub add image

REM Generate icons
echo 🎨 Generating icons...
dart scripts\generate_icons.dart

REM Generate images
echo 🖼️ Generating images...
dart scripts\generate_images.dart

REM Create animation files
echo 🎬 Creating animation files...
echo { "v": "5.7.1", "fr": 30, "ip": 0, "op": 90, "w": 400, "h": 400 } > assets\animations\splash_animation.json
copy assets\animations\splash_animation.json assets\animations\loading_animation.json >nul
copy assets\animations\splash_animation.json assets\animations\success_animation.json >nul

REM Generate launcher icons
echo 📱 Generating launcher icons...
flutter pub get
flutter pub run flutter_launcher_icons

REM Generate splash screen
echo 💫 Generating splash screen...
flutter pub run flutter_native_splash:create

echo.
echo ✅ All assets generated successfully!
echo.
echo Next steps:
echo 1. Run: flutter pub get
echo 2. Run: flutter run
pause
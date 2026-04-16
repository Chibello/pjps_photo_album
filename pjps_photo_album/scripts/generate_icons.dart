import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'dart:convert';

void main() async {
  print('🎨 Generating app icons...');

  // Create directories
  Directory('assets/icons').createSync(recursive: true);
  Directory('android/app/src/main/res/mipmap-hdpi').createSync(recursive: true);
  Directory('android/app/src/main/res/mipmap-mdpi').createSync(recursive: true);
  Directory('android/app/src/main/res/mipmap-xhdpi')
      .createSync(recursive: true);
  Directory('android/app/src/main/res/mipmap-xxhdpi')
      .createSync(recursive: true);
  Directory('android/app/src/main/res/mipmap-xxxhdpi')
      .createSync(recursive: true);
  Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset')
      .createSync(recursive: true);

  // Create base icon (512x512 gold circle with "P")
  final baseIcon = img.Image(width: 512, height: 512);

  // Fill with gold gradient
  //for (int y = 0; y < 512; y++) {
  // for (int x = 0; x < 512; x++) {
  // Calculate distance from center for circle
  //    double dx = (x - 256).abs();
  //   double dy = (y - 256).abs();
  //     double distance = (dx * dx + dy * dy).sqrt();
//
//      if (distance <= 256) {
  // Gold gradient
//        double intensity = 1.0 - (distance / 256) * 0.3;
//        int gold = (244 * intensity).toInt();
//        baseIcon.setPixelRgba(x, y, gold, 197, 66, 255);
//      } else {
//        baseIcon.setPixelRgba(x, y, 107, 114, 128, 255); // Ash
//      }
//    }
//  }

  for (int y = 0; y < 512; y++) {
    for (int x = 0; x < 512; x++) {
      double dx = (x - 256).abs().toDouble();
      double dy = (y - 256).abs().toDouble();
      double distance = sqrt(dx * dx + dy * dy);

      if (distance <= 256) {
        double intensity = 1.0 - (distance / 256) * 0.3;
        int gold = (244 * intensity).toInt();

        baseIcon.setPixelRgba(x, y, gold, 197, 66, 255);
      } else {
        baseIcon.setPixelRgba(x, y, 107, 114, 128, 255);
      }
    }
  }

  // Add "P" text
  await _drawText(baseIcon, 'P', 256, 256, 200);

  // Save base icon
  img.encodePngFile('assets/icons/app_icon.png', baseIcon);
  print('✅ Base icon created');

  // Generate Android icons
  final sizes = {
    'hdpi': 72,
    'mdpi': 48,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };

  sizes.forEach((key, size) {
    final resized = img.copyResize(baseIcon, width: size, height: size);
    img.encodePngFile(
        'android/app/src/main/res/mipmap-$key/ic_launcher.png', resized);
    print('✅ Android icon $key created');
  });

  // Generate iOS icons
  final iosSizes = [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024];

  for (int size in iosSizes) {
    final resized = img.copyResize(baseIcon, width: size, height: size);
    img.encodePngFile(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon_${size}x$size.png',
        resized);

    if (size < 1024) {
      // Create @2x versions
      final resized2x =
          img.copyResize(baseIcon, width: size * 2, height: size * 2);
      img.encodePngFile(
          'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon_${size}x$size@2x.png',
          resized2x);
    }

    print('✅ iOS icon $size created');
  }

  // Generate Contents.json for iOS
  final contents = {
    "images": [for (int size in iosSizes) ..._generateIosIconEntries(size)],
    "info": {"version": 1, "author": "xcode"}
  };

  File('ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json')
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(contents));

  print('✅ iOS Contents.json created');

  // Generate notification icons
  final notificationIcon = img.copyResize(baseIcon, width: 48, height: 48);
  img.encodePngFile('android/app/src/main/res/drawable/ic_notification.png',
      notificationIcon);

  print('🎉 All icons generated successfully!');
}

Future<void> _drawText(
    img.Image image, String text, int x, int y, int size) async {
  // Simple text drawing - in production, use a proper font rendering library
  // This is a placeholder implementation
  print('📝 Drawing text: $text');
}

List<Map<String, dynamic>> _generateIosIconEntries(int size) {
  final entries = [
    {
      "size": "${size}x$size",
      "idiom": size >= 1024 ? "ios-marketing" : "iphone",
      "filename": "icon_${size}x$size.png",
      "scale": "1x"
    }
  ];

  if (size < 1024) {
    entries.add({
      "size": "${size}x$size",
      "idiom": "iphone",
      "filename": "icon_${size}x$size@2x.png",
      "scale": "2x"
    });
  }

  return entries;
}

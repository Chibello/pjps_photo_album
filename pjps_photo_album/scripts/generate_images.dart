import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;

void main() async {
  print('🖼️ Generating images...');

  // Create directories
  Directory('assets/images').createSync(recursive: true);
  Directory('assets/images/backgrounds').createSync(recursive: true);

  // Generate logo
  await generateLogo();

  // Generate default avatars
  await generateDefaultAvatar();
  await generateDefaultStudent();
  await generateDefaultTeacher();

  // Generate empty states
  await generateEmptyState('albums');
  await generateEmptyState('staff');
  await generateEmptyState('remarks');
  await generateEmptyState('search');

  // Generate gradients
  await generateGradient('gold', [244, 197, 66], [218, 165, 32]);
  await generateGradient('ash', [107, 114, 128], [75, 85, 99]);

  // Generate patterns
  await generatePattern('dots');
  await generatePattern('lines');

  print('🎉 All images generated successfully!');
}

Future<void> generateLogo() async {
  final image = img.Image(width: 512, height: 512);

  // Gold background
  for (int y = 0; y < 512; y++) {
    for (int x = 0; x < 512; x++) {
      image.setPixelRgba(x, y, 244, 197, 66, 255);
    }
  }

  // Add text
  await drawText(image, 'PJPS', 256, 256, 60);

  // Save
  img.encodePngFile('assets/images/logo.png', image);

  // White version
  final whiteImage = img.Image(width: 512, height: 512);
  for (int y = 0; y < 512; y++) {
    for (int x = 0; x < 512; x++) {
      whiteImage.setPixelRgba(x, y, 255, 255, 255, 255);
    }
  }
  await drawText(whiteImage, 'PJPS', 256, 256, 60);
  img.encodePngFile('assets/images/logo_white.png', whiteImage);

  print('✅ Logo generated');
}

Future<void> generateDefaultAvatar() async {
  final image = img.Image(width: 200, height: 200);

  // Gray background
  for (int y = 0; y < 200; y++) {
    for (int x = 0; x < 200; x++) {
      image.setPixelRgba(x, y, 200, 200, 200, 255);
    }
  }

  // Draw person icon
  drawCircle(image, 100, 70, 30, [150, 150, 150]);
  drawRect(image, 70, 110, 60, 40, [150, 150, 150]);

  img.encodePngFile('assets/images/default_avatar.png', image);
  print('✅ Default avatar generated');
}

Future<void> generateDefaultStudent() async {
  final image = img.Image(width: 200, height: 200);

  // Light gold background
  for (int y = 0; y < 200; y++) {
    for (int x = 0; x < 200; x++) {
      image.setPixelRgba(x, y, 255, 235, 200, 255);
    }
  }

  // Draw student icon
  drawCircle(image, 100, 70, 30, [244, 197, 66]);
  drawRect(image, 70, 110, 60, 40, [244, 197, 66]);
  drawRect(image, 85, 80, 30, 10, [255, 255, 255]);

  img.encodePngFile('assets/images/default_student.png', image);
  print('✅ Default student generated');
}

Future<void> generateDefaultTeacher() async {
  final image = img.Image(width: 200, height: 200);

  // Light ash background
  for (int y = 0; y < 200; y++) {
    for (int x = 0; x < 200; x++) {
      image.setPixelRgba(x, y, 230, 230, 240, 255);
    }
  }

  // Draw teacher icon
  drawCircle(image, 100, 70, 30, [107, 114, 128]);
  drawRect(image, 70, 110, 60, 40, [107, 114, 128]);
  drawRect(image, 85, 80, 30, 10, [255, 255, 255]);

  // Add glasses
  drawCircle(image, 85, 70, 8, [150, 150, 150]);
  drawCircle(image, 115, 70, 8, [150, 150, 150]);

  img.encodePngFile('assets/images/default_teacher.png', image);
  print('✅ Default teacher generated');
}

Future<void> generateEmptyState(String type) async {
  final image = img.Image(width: 400, height: 400);

  // Light background
  for (int y = 0; y < 400; y++) {
    for (int x = 0; x < 400; x++) {
      image.setPixelRgba(x, y, 245, 245, 245, 255);
    }
  }

  // Draw empty state icon based on type
  switch (type) {
    case 'albums':
      drawFolder(image, 150, 150, [200, 200, 200]);
      break;
    case 'staff':
      drawPerson(image, 150, 150, [200, 200, 200]);
      break;
    case 'remarks':
      drawNote(image, 150, 150, [200, 200, 200]);
      break;
    case 'search':
      drawSearch(image, 150, 150, [200, 200, 200]);
      break;
  }

  img.encodePngFile('assets/images/empty_$type.png', image);
  print('✅ Empty state $type generated');
}

Future<void> generateGradient(
    String name, List<int> color1, List<int> color2) async {
  final image = img.Image(width: 800, height: 1200);

  for (int y = 0; y < 1200; y++) {
    double ratio = y / 1200;
    int r = (color1[0] * (1 - ratio) + color2[0] * ratio).toInt();
    int g = (color1[1] * (1 - ratio) + color2[1] * ratio).toInt();
    int b = (color1[2] * (1 - ratio) + color2[2] * ratio).toInt();

    for (int x = 0; x < 800; x++) {
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  img.encodeJpgFile('assets/images/backgrounds/${name}_gradient.jpg', image);
  print('✅ Gradient $name generated');
}

Future<void> generatePattern(String type) async {
  final image = img.Image(width: 200, height: 200);

  // Light background
  for (int y = 0; y < 200; y++) {
    for (int x = 0; x < 200; x++) {
      image.setPixelRgba(x, y, 245, 245, 245, 255);
    }
  }

  if (type == 'dots') {
    // Draw dots pattern
    for (int y = 20; y < 200; y += 40) {
      for (int x = 20; x < 200; x += 40) {
        drawCircle(image, x, y, 5, [200, 200, 200]);
      }
    }
  } else if (type == 'lines') {
    // Draw lines pattern
    for (int y = 0; y < 200; y += 20) {
      for (int x = 0; x < 200; x += 2) {
        if (x % 4 == 0) {
          image.setPixelRgba(x, y, 200, 200, 200, 255);
        }
      }
    }
  }

  img.encodePngFile('assets/images/backgrounds/pattern_$type.png', image);
  print('✅ Pattern $type generated');
}

void drawCircle(img.Image image, int cx, int cy, int radius, List<int> color) {
  for (int y = cy - radius; y <= cy + radius; y++) {
    for (int x = cx - radius; x <= cx + radius; x++) {
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        double dx = (x - cx).abs().toDouble();
        double dy = (y - cy).abs().toDouble();

        if ((dx * dx + dy * dy) <= radius * radius) {
          image.setPixelRgba(x, y, color[0], color[1], color[2], 255);
        }
      }
    }
  }
}

//void drawCircle(img.Image image, int cx, int cy, int radius, List<int> color) {
//  for (int y = cy - radius; y <= cy + radius; y++) {
//    for (int x = cx - radius; x <= cx + radius; x++) {
//      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
//        double dx = (x - cx).abs();
//        double dy = (y - cy).abs();
//        double distance = sqrt(dx * dx + dy * dy);

//        if (distance <= radius) {
//          image.setPixelRgba(x, y, color[0], color[1], color[2], 255);
//        }
//      }
//    }
//  }
//}

void drawRect(
    img.Image image, int x, int y, int width, int height, List<int> color) {
  for (int dy = y; dy < y + height; dy++) {
    for (int dx = x; dx < x + width; dx++) {
      if (dx >= 0 && dx < image.width && dy >= 0 && dy < image.height) {
        image.setPixelRgba(dx, dy, color[0], color[1], color[2], 255);
      }
    }
  }
}

void drawFolder(img.Image image, int x, int y, List<int> color) {
  drawRect(image, x, y, 100, 80, color);
  drawRect(image, x - 10, y - 10, 30, 20, color);
}

void drawPerson(img.Image image, int x, int y, List<int> color) {
  drawCircle(image, x + 50, y + 30, 20, color);
  drawRect(image, x + 30, y + 50, 40, 30, color);
}

void drawNote(img.Image image, int x, int y, List<int> color) {
  drawRect(image, x, y, 80, 100, color);
  drawRect(image, x + 10, y + 20, 60, 5, [255, 255, 255]);
  drawRect(image, x + 10, y + 40, 60, 5, [255, 255, 255]);
  drawRect(image, x + 10, y + 60, 60, 5, [255, 255, 255]);
}

void drawSearch(img.Image image, int x, int y, List<int> color) {
  drawCircle(image, x + 40, y + 40, 30, color);
  drawRect(image, x + 65, y + 65, 20, 5, color);
}

Future<void> drawText(
    img.Image image, String text, int x, int y, int size) async {
  // This is a placeholder - in production, use a proper text rendering library
  // For now, we'll just draw a rectangle where text would go
  drawRect(image, x - 100, y - 30, 200, 60, [255, 255, 255]);
}

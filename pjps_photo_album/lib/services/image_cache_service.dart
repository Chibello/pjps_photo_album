import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:synchronized/synchronized.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import 'package:http/http.dart' as http;

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  final Lock _lock = Lock();
  final Map<String, File> _memoryCache = {};
  static const int _maxMemoryCacheSize = 50;

  /// Returns local path if cached, else the original URL
  Future<String> getImagePath(String url) async {
    if (url.isEmpty) return '';
    final file = await _getLocalFile(url);
    if (await file.exists()) {
      await file.setLastAccessed(DateTime.now());
      final db = await DatabaseHelper().database;
      await db.update(
        'images_cache',
        {'last_accessed': DateTime.now().toIso8601String()},
        where: 'url = ?',
        whereArgs: [url],
      );
      return file.path;
    }
    return url;
  }

  /// Cache raw bytes locally
  Future<File?> cacheImage(String url, Uint8List bytes) async {
    return _lock.synchronized(() async {
      try {
        final file = await _getLocalFile(url);
        await file.writeAsBytes(bytes);

        final db = await DatabaseHelper().database;
        await db.insert(
          'images_cache',
          {
            'id': _getFileName(url),
            'url': url,
            'local_path': file.path,
            'file_size': await file.length(),
            'downloaded_at': DateTime.now().toIso8601String(),
            'last_accessed': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        _memoryCache[url] = file;
        if (_memoryCache.length > _maxMemoryCacheSize) {
          _memoryCache.remove(_memoryCache.keys.first);
        }

        return file;
      } catch (e) {
        print('Error caching image: $e');
        return null;
      }
    });
  }

  /// Convenience method: download image from URL and cache it
  Future<File> cacheImageFromUrl(String url) async {
    final file = await _getLocalFile(url);
    if (await file.exists()) return file;

    final response = await http.get(Uri.parse(url));
    return await cacheImage(url, response.bodyBytes) ?? file;
  }

  /// Preload multiple images
  Future<void> preloadImages(List<String> urls) async {
    final dio = Dio();
    for (var url in urls) {
      try {
        if (await _isImageCached(url)) continue;
        final response = await dio.get(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        await cacheImage(url, response.data);
      } catch (e) {
        print('Error preloading image $url: $e');
      }
    }
  }

  /// Check if image is already cached
  Future<bool> _isImageCached(String url) async {
    final file = await _getLocalFile(url);
    return await file.exists();
  }

  /// Clear old cached files
  Future<void> clearOldCache({int daysOld = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));
    final cacheDir = Directory(
        '${(await getApplicationDocumentsDirectory()).path}/image_cache');
    if (!await cacheDir.exists()) return;
    final files = cacheDir.list();
    await for (var file in files) {
      if (file is File && (await file.stat()).accessed.isBefore(cutoff)) {
        await file.delete();
      }
    }
  }

  /// Helper: generate local file path
  Future<File> _getLocalFile(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    // Use SHA256 hash for filename to avoid collisions
    final filename = _getFileName(url);
    return File('${cacheDir.path}/$filename');
  }

  /// Generate SHA256 hash for filename
  String _getFileName(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_cache_service.dart';
import '../core/theme/app_colors.dart';

class OfflineImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool useCache;

  const OfflineImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.useCache = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    if (!useCache) {
      // Load directly from network
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildError(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _buildPlaceholder(),
      );
    }

    // Use cache service
    return FutureBuilder<String?>(
      future: ImageCacheService().getImagePath(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder();
        }

        final path = snapshot.data;

        if (path != null && path != imageUrl) {
          // Load from local file
          return Image.file(
            File(path),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => _buildError(),
          );
        }

        // Not cached yet, load from network and cache
        return FutureBuilder<File?>(
          future: _downloadAndCacheImage(imageUrl),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return _buildPlaceholder();
            }
            if (snap.hasData && snap.data != null) {
              return Image.file(
                snap.data!,
                width: width,
                height: height,
                fit: fit,
                errorBuilder: (_, __, ___) => _buildError(),
              );
            }
            // Fallback to network
            return Image.network(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) => _buildError(),
            );
          },
        );
      },
    );
  }

  Future<File?> _downloadAndCacheImage(String url) async {
    try {
      final response = await ImageCacheService().cacheImageFromUrl(url);
      return response;
    } catch (e) {
      print('Error caching image: $e');
      return null;
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.lightGrey,
      child: placeholder ??
          const Center(
            child: CircularProgressIndicator(),
          ),
    );
  }

  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      color: AppColors.lightGrey,
      child: errorWidget ??
          const Center(
            child: Icon(
              Icons.broken_image,
              color: AppColors.secondaryAsh,
              size: 30,
            ),
          ),
    );
  }
}

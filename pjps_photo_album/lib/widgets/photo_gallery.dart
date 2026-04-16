// photo_gallery.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_colors.dart';

class PhotoGallery extends StatelessWidget {
  final List<Map<String, dynamic>> photos;
  final Function(String) onPhotoTap;

  const PhotoGallery({
    super.key,
    required this.photos,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap in SizedBox to give bounded height
    return SizedBox(
      height: 300, // adjust depending on number of rows
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          final imageUrl = photo['medium_url'] ?? photo['full_url'];

          return GestureDetector(
            onTap: () => onPhotoTap(photo['full_url'] ?? ''),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.lightGrey,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.lightGrey,
                  child: const Icon(
                    Icons.broken_image,
                    color: AppColors.secondaryAsh,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

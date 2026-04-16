import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_colors.dart';
import '../models/staff_model.dart';

class StaffCard extends StatelessWidget {
  final StaffListModel staff;
  final VoidCallback onTap;

  const StaffCard({
    super.key,
    required this.staff,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Profile Photo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightGrey,
                  image: staff.profilePhotoThumbnail != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                            staff.profilePhotoThumbnail!,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: staff.profilePhotoThumbnail == null
                    ? const Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.secondaryAsh,
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      staff.position,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryAsh,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (staff.categoryName != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              staff.categoryName!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primaryGoldDark,
                              ),
                            ),
                          ),
                        ],
                        if (staff.departmentName != null) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryAsh.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              staff.departmentName!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.secondaryAshDark,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.chevron_right,
                color: AppColors.secondaryAsh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

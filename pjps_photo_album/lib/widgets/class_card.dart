import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/class_model.dart';

class ClassCard extends StatelessWidget {
  final ClassGroupModel classGroup;
  final VoidCallback onTap;

  const ClassCard({
    super.key,
    required this.classGroup,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and Year
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.class_,
                      color: AppColors.primaryGold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classGroup.yearLevelName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryAsh,
                          ),
                        ),
                        Text(
                          classGroup.academicYearName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.secondaryAshLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Class Name
              Text(
                classGroup.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Student Count
              Row(
                children: [
                  const Icon(
                    Icons.people,
                    size: 14,
                    color: AppColors.secondaryAsh,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${classGroup.studentCount} Students',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryAsh,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

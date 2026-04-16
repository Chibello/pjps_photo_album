import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/year_level_model.dart';

class YearLevelCard extends StatelessWidget {
  final YearLevelModel year;
  final VoidCallback onTap;

  const YearLevelCard({
    super.key,
    required this.year,
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGold.withOpacity(0.1),
                AppColors.secondaryAsh.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGold,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  year.name.replaceAll('Year ', ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Year Name
              Text(
                year.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      //  Text(
                      //    year.classCount.toString(),
                      //    style: const TextStyle(
                      //      fontSize: 14,
                      //      fontWeight: FontWeight.bold,
                      //      color: AppColors.primaryGold,
                      //    ),
                      //  ),
                      // const Text(
                      //   'Classes',
                      //   style: TextStyle(
                      //     fontSize: 10,
                      //     color: AppColors.secondaryAsh,
                      //    ),
                      //  ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text(
                        year.studentCount.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                      ),
                      const Text(
                        'Students',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.secondaryAsh,
                        ),
                      ),
                    ],
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

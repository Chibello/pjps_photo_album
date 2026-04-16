import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../models/remark_model.dart';

class RemarkCard extends StatelessWidget {
  final RemarkModel remark;
  final VoidCallback onTap;

  const RemarkCard({
    super.key,
    required this.remark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(remark.remarkType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      remark.remarkType,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _getTypeColor(remark.remarkType),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Visibility Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getVisibilityColor(remark.visibility)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      remark.visibility,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _getVisibilityColor(remark.visibility),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Comment Count
                  if (remark.commentCount > 0)
                    Row(
                      children: [
                        const Icon(
                          Icons.comment,
                          size: 14,
                          color: AppColors.secondaryAsh,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          remark.commentCount.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryAsh,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                remark.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // Content Preview
              Text(
                remark.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryAsh,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.secondaryAsh,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    remark.authorName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryAsh,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.secondaryAsh,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(DateTime.parse(remark.createdAt)),
                    style: const TextStyle(
                      fontSize: 10,
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ACADEMIC':
        return Colors.blue;
      case 'BEHAVIORAL':
        return Colors.orange;
      case 'ACHIEVEMENT':
        return Colors.green;
      case 'ATTENDANCE':
        return Colors.purple;
      default:
        return AppColors.primaryGold;
    }
  }

  Color _getVisibilityColor(String visibility) {
    switch (visibility) {
      case 'PRIVATE':
        return Colors.red;
      case 'INTERNAL':
        return Colors.orange;
      case 'PUBLIC':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

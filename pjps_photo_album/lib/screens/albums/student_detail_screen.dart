import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../widgets/remark_book_button.dart';
import '../../widgets/photo_gallery.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  final String studentId;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
  });

  @override
  ConsumerState<StudentDetailScreen> createState() =>
      _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Delay async call until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(albumProvider.notifier).loadStudentDetails(widget.studentId);
    });
  }

  void _showFullPhoto(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(imageUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final albumState = ref.watch(albumProvider);
    final student = albumState.currentStudent;

    if (student == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(student.fullName),
        actions: [
          RemarkBookButton(
            contentType: 'student',
            objectId: student.id,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Photo
            GestureDetector(
              onTap: () {
                if (student.profilePhotoOriginal != null) {
                  _showFullPhoto(student.profilePhotoOriginal!);
                }
              },
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  image: student.profilePhotoMedium != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                              student.profilePhotoMedium!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: student.profilePhotoMedium == null
                    ? const Center(
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: AppColors.secondaryAsh,
                        ),
                      )
                    : null,
              ),
            ),

            // Student Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Registration
                  Text(
                    student.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reg No: ${student.registrationNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryAsh,
                    ),
                  ),

                  const Divider(height: 32),

                  // Personal Details
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                      'Diocese', student.dioceseName ?? 'Not specified'),
                  _buildInfoRow(
                      'Hometown',
                      student.hometown.isEmpty
                          ? 'Not specified'
                          : student.hometown),
                  _buildInfoRow(
                      'State of Origin', student.stateName ?? 'Not specified'),
                  _buildInfoRow(
                      'Date of Birth', student.dateOfBirth ?? 'Not specified'),

                  const SizedBox(height: 16),

                  // Academic Details (Year and Year Level)
                  const Text(
                    'Academic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                      'Year Level', student.yearLevel ?? 'Not assigned'),
                  //_buildInfoRow('Year', student.year ?? ''),
                  _buildInfoRow(
                      'Year Level', student.yearLevelName ?? 'Not assigned'),
                  _buildInfoRow(
                      'Enrollment Date', _formatDate(student.enrollmentDate)),

                  const Divider(height: 32),

                  // Personal Remarks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Personal Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          context.push('/remarks/student/${student.id}');
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      student.personalNotes?.isNotEmpty == true
                          ? student.personalNotes!
                          : 'No personal notes available',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  // Additional Photos
                  if (student.additionalPhotos?.isNotEmpty ?? false) ...[
                    const Divider(height: 32),
                    const Text(
                      'Additional Photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PhotoGallery(
                      photos: student.additionalPhotos!,
                      onPhotoTap: _showFullPhoto,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryAsh,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

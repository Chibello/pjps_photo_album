import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../widgets/contact_info_tile.dart';

class StaffDetailScreen extends ConsumerStatefulWidget {
  final String staffId;

  const StaffDetailScreen({
    super.key,
    required this.staffId,
  });

  @override
  ConsumerState<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends ConsumerState<StaffDetailScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(staffProvider.notifier).loadStaffDetails(widget.staffId);
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(staffProvider);
    final staff = staffState.currentStaff;

    if (staff == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(staff.fullName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppColors.goldAshGradient,
              ),
              child: Row(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: staff.profilePhotoMedium != null
                        ? NetworkImage(staff.profilePhotoMedium!)
                        : null,
                    child: staff.profilePhotoMedium == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primaryGold,
                          )
                        : null,
                  ),
                  const SizedBox(width: 20),
                  // Basic Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staff.position,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          staff.departmentName ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Staff ID: ${staff.staffId}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contact Information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ContactInfoTile(
                    icon: Icons.email,
                    label: 'Work Email',
                    value: staff.workEmail,
                    onTap: () => _launchEmail(staff.workEmail),
                  ),

                  ContactInfoTile(
                    icon: Icons.phone,
                    label: 'Work Phone',
                    value: staff.workPhone,
                    onTap: () => _launchPhone(staff.workPhone),
                  ),

                  if (staff.officeLocation != null &&
                      staff.officeLocation!.isNotEmpty)
                    ContactInfoTile(
                      icon: Icons.location_on,
                      label: 'Office Location',
                      value: staff.officeLocation!,
                      onTap: null,
                    ),

                  if (staff.officeHours != null &&
                      staff.officeHours!.isNotEmpty)
                    ContactInfoTile(
                      icon: Icons.access_time,
                      label: 'Office Hours',
                      value: staff.officeHours!,
                      onTap: null,
                    ),

                  const Divider(height: 32),

                  // Professional Information
                  const Text(
                    'Professional Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (staff.adminRole != null) ...[
                    _buildInfoSection('Administrative Role', staff.adminRole!),
                    if (staff.managesDepartment != null)
                      _buildInfoSection('Manages Department',
                          staff.managesDepartment!['name']),
                  ],

                  if (staff.librarySection != null) ...[
                    _buildInfoSection(
                        'Library Section', staff.librarySection!['name']),
                    if (staff.librarianRank != null)
                      _buildInfoSection('Rank', staff.librarianRank!),
                  ],

                  if (staff.qualifications != null &&
                      staff.qualifications!.isNotEmpty)
                    _buildInfoSection('Qualifications', staff.qualifications!),

                  if (staff.responsibilities != null &&
                      staff.responsibilities!.isNotEmpty)
                    _buildInfoSection(
                        'Responsibilities', staff.responsibilities!),

                  // Bio
                  if (staff.bio != null && staff.bio!.isNotEmpty) ...[
                    const Divider(height: 32),
                    const Text(
                      'Biography',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      staff.bio!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
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

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryAsh,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

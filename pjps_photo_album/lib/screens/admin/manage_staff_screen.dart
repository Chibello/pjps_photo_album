import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../models/staff_model.dart';

class ManageStaffScreen extends ConsumerStatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  ConsumerState<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends ConsumerState<ManageStaffScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    await ref.read(staffProvider.notifier).loadAllStaff();
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(staffProvider);
    final allStaff = staffState.allStaff;

    // Filter staff
    final filteredStaff = allStaff.where((staff) {
      if (_searchQuery.isNotEmpty) {
        return staff.fullName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (staff.staffId
                .toLowerCase()
                .contains(_searchQuery.toLowerCase())) ||
            (staff.departmentName
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Staff'),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/staff/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, staff ID, or department...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Staff Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filteredStaff.length} staff members',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryAsh,
                  ),
                ),
                const Spacer(),
                if (staffState.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          // Staff List
          Expanded(
            child: staffState.isLoading && allStaff.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredStaff.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: AppColors.secondaryAsh,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No staff members found',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.secondaryAsh,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredStaff.length,
                        itemBuilder: (context, index) {
                          final staff = filteredStaff[index];
                          return _buildStaffCard(staff);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(StaffListModel staff) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/staff/${staff.staffId}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Profile Photo
              CircleAvatar(
                radius: 30,
                backgroundImage: staff.profilePhotoThumbnail != null
                    ? NetworkImage(staff.profilePhotoThumbnail!)
                    : null,
                child: staff.profilePhotoThumbnail == null
                    ? const Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.primaryGold,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Staff Info
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
                        fontSize: 12,
                        color: AppColors.secondaryAsh,
                      ),
                    ),
                    if (staff.staffId.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${staff.staffId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryAsh,
                        ),
                      ),
                    ],
                    if (staff.departmentName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Department: ${staff.departmentName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryAsh,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status and Actions
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: staff.isActive
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      staff.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 10,
                        color: staff.isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () =>
                            context.push('/admin/staff/${staff.staffId}/edit'),
                        color: AppColors.primaryGold,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => _showDeleteConfirmationDialog(staff),
                        color: Colors.red,
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

  void _showDeleteConfirmationDialog(StaffListModel staff) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Staff Member'),
          content: Text(
            'Are you sure you want to delete ${staff.fullName}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteStaff(staff.staffId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStaff(String staffId) async {
    // TODO: Implement delete functionality using your API
    // After deleting, reload the staff list
    await ref.read(staffProvider.notifier).loadAllStaff();
  }
}

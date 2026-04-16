import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../models/student_model.dart';

class ManageStudentsScreen extends ConsumerStatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  ConsumerState<ManageStudentsScreen> createState() =>
      _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends ConsumerState<ManageStudentsScreen> {
  String _selectedYearFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    await ref.read(albumProvider.notifier).loadAllStudents();
  }

  @override
  Widget build(BuildContext context) {
    final albumState = ref.watch(albumProvider);
    //final allStudents = albumState.students ?? [];
    final allStudents = albumState.currentStudents;
    //final yearLevels = albumState.yearLevels ?? [];
    final yearLevels = albumState.yearLevels;

    // Filter students
    List<StudentListModel> filteredStudents = allStudents.where((student) {
      if (_selectedYearFilter != 'All' &&
          student.yearLevel != _selectedYearFilter) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        return student.fullName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            student.registrationNumber
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }

      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/admin/students/add');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search...',
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // Filter
          if (yearLevels.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedYearFilter == 'All',
                    onSelected: (_) {
                      setState(() => _selectedYearFilter = 'All');
                    },
                  ),
                  const SizedBox(width: 8),
                  ...yearLevels.map((year) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(year.name),
                          selected: _selectedYearFilter == year.name,
                          onSelected: (_) {
                            setState(() => _selectedYearFilter = year.name);
                          },
                        ),
                      )),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Count + loading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${filteredStudents.length} students'),
                const Spacer(),
                if (albumState.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          // List
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(child: Text('No students found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredStudents.length,
                    itemBuilder: (_, i) =>
                        _buildStudentCard(filteredStudents[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(StudentListModel student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: student.profilePhotoThumbnail != null
              ? NetworkImage(student.profilePhotoThumbnail!)
              : null,
          child: student.profilePhotoThumbnail == null
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(student.fullName),
        subtitle: Text(student.registrationNumber),
        onTap: () => context.push('/students/${student.id}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/admin/students/${student.id}/edit');
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(student),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(StudentListModel student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Delete ${student.fullName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStudent(student.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudent(String id) async {
    final success = await ref.read(albumProvider.notifier).deleteStudent(id);

    if (success) {
      await ref.read(albumProvider.notifier).loadAllStudents();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed')),
      );
    }
  }
}

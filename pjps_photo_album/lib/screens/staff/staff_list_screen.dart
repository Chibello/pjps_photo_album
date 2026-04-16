import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../widgets/staff_card.dart';
import '../../widgets/custom_text_field.dart';

class StaffListScreen extends ConsumerStatefulWidget {
  final String? categoryId;

  const StaffListScreen({
    super.key,
    this.categoryId,
  });

  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    await ref.read(staffProvider.notifier).loadStaff(
          categoryId: widget.categoryId,
        );
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(staffProvider);
    //final allStaff = staffState.staff;
    final allStaff = staffState.allStaff;

    final filteredStaff = _searchQuery.isEmpty
        ? allStaff
        : allStaff.where((staff) {
            return staff.fullName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                staff.staffId
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                staff.position
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Directory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              controller: _searchController,
              label: 'Search staff...',
              prefixIcon: Icons.search,
              // Use onChanged only if the CustomTextField supports it
              onChanged: (value) => _performSearch(value),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStaff,
        child: filteredStaff.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 64,
                      color: AppColors.secondaryAsh.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No staff found'
                          : 'No results for "$_searchQuery"',
                      style: const TextStyle(
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
                  final staffMember = filteredStaff[index];
                  return StaffCard(
                    staff: staffMember,
                    onTap: () {
                      context.push('/staff/${staffMember.id}');
                    },
                  );
                },
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/student_card.dart';
import '../../widgets/staff_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<dynamic> _results = [];
  bool _isSearching = false;
  String _selectedTab = 'students';

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      if (_selectedTab == 'students') {
        await ref.read(albumProvider.notifier).searchStudents(_searchQuery);
      } else {
        await ref.read(staffProvider.notifier).searchStaff(_searchQuery);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }

    // ✅ Move this OUTSIDE finally
    if (!mounted) return;

    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomTextField(
                  controller: _searchController,
                  label: 'Search...',
                  hint: 'Enter name or registration number',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTab = 'students';
                          _performSearch();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTab == 'students'
                                  ? AppColors.primaryGold
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Students',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 'students'
                                ? AppColors.primaryGold
                                : AppColors.secondaryAsh,
                            fontWeight: _selectedTab == 'students'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTab = 'staff';
                          _performSearch();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTab == 'staff'
                                  ? AppColors.primaryGold
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Staff',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTab == 'staff'
                                ? AppColors.primaryGold
                                : AppColors.secondaryAsh,
                            fontWeight: _selectedTab == 'staff'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.secondaryAsh.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Start typing to search'
                            : 'No results found',
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
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    if (_selectedTab == 'students') {
                      return StudentCard(
                        student: item,
                        onTap: () {
                          context.push('/students/${item.id}');
                        },
                      );
                    } else {
                      return StaffCard(
                        staff: item,
                        onTap: () {
                          context.push('/staff/${item.id}');
                        },
                      );
                    }
                  },
                ),
    );
  }
}

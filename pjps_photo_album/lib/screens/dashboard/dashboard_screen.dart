import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/year_level_card.dart';
//import '../../models/user_model.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await Future.wait([
      ref.read(albumProvider.notifier).loadYearLevels(),
      ref.read(albumProvider.notifier).loadDashboardStats(),
      ref.read(staffProvider.notifier).loadStaffCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final yearLevels = ref.watch(albumProvider).yearLevels;
    final stats = ref.watch(albumProvider).dashboardStats;
    final staffCategories = ref.watch(staffProvider).categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  context.push('/profile');
                  break;
                case 'admin':
                  if (user?.isAdmin ?? false) {
                    context.push('/admin');
                  }
                  break;
                case 'logout':
                  final authNotifier = ref.read(authProvider.notifier);
                  await authNotifier.logout();
                  if (mounted) {
                    context.go('/home');
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              if (user?.isAdmin ?? false)
                const PopupMenuItem(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings),
                      SizedBox(width: 8),
                      Text('Admin Panel'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.goldAshGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      user?.fullName ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (user?.userType != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user!.userType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats Cards
              if (stats != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'Students',
                        value: stats['total_students'].toString(),
                        icon: Icons.people,
                        color: AppColors.primaryGold,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardCard(
                        title: 'Classes',
                        value: stats['total_classes'].toString(),
                        icon: Icons.class_,
                        color: AppColors.secondaryAsh,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'Year Levels',
                        value: stats['total_year_levels'].toString(),
                        icon: Icons.school,
                        color: AppColors.primaryGoldLight,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardCard(
                        title: 'Staff',
                        value: '${staffCategories.length} Depts',
                        icon: Icons.badge,
                        color: AppColors.secondaryAshLight,
                        onTap: () {
                          context.push('/staff');
                        },
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Quick Access
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAccessCard(
                      title: 'Photo Album',
                      icon: Icons.photo_album,
                      onTap: () => context.push('/albums'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAccessCard(
                      title: 'Staff Directory',
                      icon: Icons.badge,
                      onTap: () => context.push('/staff'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Year Levels Section
              const Text(
                'Browse by Year',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: yearLevels.length,
                itemBuilder: (context, index) {
                  final year = yearLevels[index];
                  return YearLevelCard(
                    year: year,
                    onTap: () {
                      context.push('/albums/year/${year.id}');
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // Staff Categories
              const Text(
                'Staff Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: staffCategories.length,
                  itemBuilder: (context, index) {
                    final category = staffCategories[index];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            context.push('/staff?category=${category['id']}');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getCategoryIcon(category['name']),
                                color: AppColors.primaryGold,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category['name'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${category['staff_count'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.secondaryAsh,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGold,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'administrative':
        return Icons.admin_panel_settings;
      case 'academic':
        return Icons.school;
      case 'library':
        return Icons.local_library;
      case 'technical':
        return Icons.computer;
      case 'support':
        return Icons.support_agent;
      default:
        return Icons.badge;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Corrected: watch the provider state, then access `user`
    final user = ref.watch(authProvider).user;

    if (user == null || !user.isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.block,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You do not have permission to access this page.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.go('/dashboard');
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primaryGoldDark,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildAdminCard(
            context,
            title: 'Manage Users',
            icon: Icons.people,
            color: Colors.blue,
            onTap: () => context.push('/admin/users'),
          ),
          _buildAdminCard(
            context,
            title: 'Manage Classes',
            icon: Icons.class_,
            color: Colors.green,
            onTap: () => context.push('/admin/classes'),
          ),
          _buildAdminCard(
            context,
            title: 'Add Student',
            icon: Icons.person_add,
            color: Colors.orange,
            onTap: () => context.push('/admin/students/add'),
          ),
          _buildAdminCard(
            context,
            title: 'Add Staff',
            icon: Icons.badge,
            color: Colors.purple,
            onTap: () => context.push('/admin/staff/add'),
          ),
          _buildAdminCard(
            context,
            title: 'Academic Years',
            icon: Icons.calendar_today,
            color: Colors.teal,
            onTap: () {
              // Navigate to academic years management
            },
          ),
          _buildAdminCard(
            context,
            title: 'Reports',
            icon: Icons.assessment,
            color: Colors.red,
            onTap: () {
              // Navigate to reports
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

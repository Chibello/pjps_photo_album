import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/user_service.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await UserService.fetchUsers();
      setState(() => _users = users);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load users: $e'),
            backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredUsers {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _users;
    return _users.where((user) {
      final name = user['name'].toString().toLowerCase();
      final regNo = user['regNo'].toString().toLowerCase();
      return name.contains(query) || regNo.contains(query);
    }).toList();
  }

  void _showAddUserDialog() {
    final regController = TextEditingController();
    final nameController = TextEditingController();
    String userType = 'STUDENT';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
                controller: regController, label: 'Registration Number'),
            const SizedBox(height: 12),
            CustomTextField(controller: nameController, label: 'Full Name'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: userType,
              decoration: const InputDecoration(
                  labelText: 'User Type', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'STUDENT', child: Text('Student')),
                DropdownMenuItem(value: 'STAFF', child: Text('Staff')),
                DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
              ],
              onChanged: (value) => userType = value ?? 'STUDENT',
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await UserService.addUser({
                  'regNo': regController.text,
                  'name': nameController.text,
                  'type': userType,
                  'active': true,
                });
                await _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('User created successfully'),
                      backgroundColor: AppColors.success),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed to create user: $e'),
                      backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  /// ✅ This is the missing method that caused your error
  void _showUserOptions(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Reset Password'),
              onTap: () {
                Navigator.pop(context);
                _showResetPasswordDialog(user);
              },
            ),
            ListTile(
              leading: Icon(
                user['active'] ? Icons.block : Icons.check_circle,
                color: user['active'] ? Colors.orange : Colors.green,
              ),
              title: Text(user['active'] ? 'Deactivate User' : 'Activate User'),
              onTap: () {
                Navigator.pop(context);
                _toggleUserStatus(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete User',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteUser(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetPasswordDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Reset password for ${user['name']}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Password reset for ${user['name']}'),
                    backgroundColor: AppColors.success),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) async {
    try {
      final newStatus = !user['active'];
      await UserService.updateUser(user['id'], {'active': newStatus});
      await _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'User ${user['name']} ${newStatus ? 'activated' : 'deactivated'}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update user: $e'),
            backgroundColor: AppColors.error),
      );
    }
  }

  void _deleteUser(Map<String, dynamic> user) async {
    try {
      await UserService.deleteUser(user['id']);
      await _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('User ${user['name']} deleted'),
            backgroundColor: AppColors.success),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete user: $e'),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddUserDialog)
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              controller: _searchController,
              label: 'Search users...',
              prefixIcon: Icons.search,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadUsers,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: user['type'] == 'STUDENT'
                                ? AppColors.primaryGold
                                : AppColors.secondaryAsh,
                            child: Text(user['name'][0]),
                          ),
                          title: Text(user['name']),
                          subtitle: Text('${user['regNo']} • ${user['type']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!user['active'])
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('Inactive',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 10)),
                                ),
                              IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () => _showUserOptions(user)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
//import '../../core/providers/providers.dart';
import '../../models/staff_model.dart';
import '../../notifiers/staff_notifier.dart';

class AddEditStaffScreen extends ConsumerStatefulWidget {
  final String? staffId; // Null = add, not null = edit

  const AddEditStaffScreen({super.key, this.staffId});

  @override
  ConsumerState<AddEditStaffScreen> createState() => _AddEditStaffScreenState();
}

class _AddEditStaffScreenState extends ConsumerState<AddEditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _staffIdController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _bioController = TextEditingController();

  List<String> _selectedRoles = [];
  bool _isActive = true;
  bool _isLoading = false;
  bool _sendWelcomeEmail = true;

  final List<String> _availableRoles = [
    'Teacher',
    'Administrator',
    'Accountant',
    'Librarian',
    'Principal',
    'Vice Principal',
    'Secretary',
    'IT Staff',
    'Counselor',
    'Sports Coach',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.staffId != null) _loadStaffDetails();
  }

  Future<void> _loadStaffDetails() async {
    await ref.read(staffProvider.notifier).loadStaffDetails(widget.staffId!);
    final staff = ref.read(staffProvider).currentStaff;
    if (staff != null) {
      setState(() {
        _firstNameController.text = staff.firstName;
        _lastNameController.text = staff.lastName;
        _emailController.text = staff.email ?? '';
        _phoneController.text = staff.phoneNumber ?? '';
        _staffIdController.text = staff.staffId;
        _positionController.text = staff.position;
        _departmentController.text = staff.department ?? '';
        _bioController.text = staff.bio ?? '';
        _selectedRoles = staff.roles;
        _isActive = staff.isActive;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _staffIdController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveStaff() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Convert form fields to StaffDetailModel
    final staff = StaffDetailModel(
      id: widget.staffId ?? '', // empty id for new staff
      staffId: _staffIdController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      fullName:
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      position: _positionController.text.trim(),
      employmentDate: DateTime.now().toIso8601String(),
      workEmail: _emailController.text.trim(),
      workPhone: _phoneController.text.trim(),
      department: _departmentController.text.trim(),
      bio: _bioController.text.trim(),
      adminRole: _selectedRoles.join(','),
      isActive: _isActive,
    );

    bool success;
    if (widget.staffId == null) {
      // Create new staff
      success = await ref.read(staffProvider.notifier).createStaff(staff);
      //  .createStaff(staff, sendWelcomeEmail: _sendWelcomeEmail);
    } else {
      // Update existing staff
      success = await ref
          .read(staffProvider.notifier)
          .updateStaff(widget.staffId!, staff);
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.staffId == null
                ? 'Staff member added successfully'
                : 'Staff member updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true); // return true to indicate success
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save staff member'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.staffId == null ? 'Add Staff Member' : 'Edit Staff Member'),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    const Text(
                      'Personal Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                          labelText: 'First Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person)),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter first name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                          labelText: 'Last Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person)),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter last name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email Address *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email)),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter email';
                        if (!value.contains('@')) return 'Enter valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone)),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _staffIdController,
                      decoration: const InputDecoration(
                          labelText: 'Staff ID',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _positionController,
                      decoration: const InputDecoration(
                          labelText: 'Position',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _departmentController,
                      decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio / About',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Roles & Permissions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12)),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableRoles.map((role) {
                          final isSelected = _selectedRoles.contains(role);
                          return FilterChip(
                            label: Text(role),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedRoles.add(role);
                                } else {
                                  _selectedRoles.remove(role);
                                }
                              });
                            },
                            selectedColor:
                                AppColors.primaryGold.withOpacity(0.2),
                            checkmarkColor: AppColors.primaryGold,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.staffId == null)
                      SwitchListTile(
                        title: const Text('Send Welcome Email'),
                        subtitle: const Text(
                            'Send an email with login credentials to this staff member'),
                        value: _sendWelcomeEmail,
                        onChanged: (value) =>
                            setState(() => _sendWelcomeEmail = value),
                        activeColor: AppColors.primaryGold,
                      ),
                    SwitchListTile(
                      title: const Text('Active Status'),
                      subtitle: const Text(
                          'Inactive staff members cannot access the system'),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                      activeColor: AppColors.primaryGold,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveStaff,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                            widget.staffId == null
                                ? 'Add Staff'
                                : 'Update Staff',
                            style: const TextStyle(fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

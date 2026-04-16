import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../notifiers/album_notifier.dart' as album_notifier;
import '../../notifiers/student_notifier.dart';
import '../../models/student_model.dart';
import '../../services/student_service.dart';
import '../../services/api_service.dart';

final studentNotifierProvider =
    StateNotifierProvider<StudentNotifier, StudentState>((ref) {
  final apiService = ApiService(); // or get from ref if already provided
  final service = StudentService(apiService); // pass required argument
  return StudentNotifier(service);
});

class AddEditStudentScreen extends ConsumerStatefulWidget {
  final String? studentId;

  const AddEditStudentScreen({super.key, this.studentId});

  @override
  ConsumerState<AddEditStudentScreen> createState() =>
      _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends ConsumerState<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _otherNamesController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _hometownController = TextEditingController();
  final _personalNotesController = TextEditingController();
  final _enrollmentDateController = TextEditingController();
  bool _isGraduatedController = false;

  String? _selectedYearId;
  String? _selectedDioceseId;
  String? _selectedStateId;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.studentId != null) {
      _loadStudentDetails();
    }
  }

  Future<void> _loadData() async {
    final notifier = ref.read(studentNotifierProvider.notifier);
    await notifier.loadDioceses();
    await notifier.loadStates();
    await ref.read(album_notifier.albumProvider.notifier).loadYearLevels();
  }

  Future<void> _loadStudentDetails() async {
    final notifier = ref.read(studentNotifierProvider.notifier);
    await notifier.loadStudentDetails(widget.studentId!);
    final student = ref.read(studentNotifierProvider).currentStudent;
    if (student != null) {
      setState(() {
        _firstNameController.text = student.firstName;
        _lastNameController.text = student.lastName;
        _otherNamesController.text = student.otherNames ?? '';
        _registrationNumberController.text = student.registrationNumber;
        _dateOfBirthController.text = student.dateOfBirth ?? '';
        _hometownController.text = student.hometown;
        _personalNotesController.text = student.personalNotes ?? '';
        _selectedYearId = student.yearLevel ?? '';
        _selectedDioceseId = student.diocese ?? '';
        _selectedStateId = student.stateOfOrigin ?? '';
        _isActive = student.isActive;
        _enrollmentDateController.text = student.enrollmentDate;
        _isGraduatedController = student.isGraduated;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _otherNamesController.dispose();
    _registrationNumberController.dispose();
    _dateOfBirthController.dispose();
    _hometownController.dispose();
    _personalNotesController.dispose();
    _enrollmentDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final notifier = ref.read(studentNotifierProvider.notifier);

    final student = StudentDetailModel(
      id: widget.studentId ?? '',
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      otherNames: _otherNamesController.text.trim(),
      fullName:
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      registrationNumber: _registrationNumberController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim(),
      hometown: _hometownController.text.trim(),
      enrollmentDate: _enrollmentDateController.text.trim(),
      isGraduated: _isGraduatedController,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      diocese: _selectedDioceseId ?? '',
      stateOfOrigin: _selectedStateId ?? '',
      yearLevel: _selectedYearId ?? '',
      personalNotes: _personalNotesController.text.trim(),
      isActive: _isActive,
    );

    bool success;
    if (widget.studentId == null) {
      success = await notifier.createStudent(student);
    } else {
      success = await notifier.updateStudent(student);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.studentId == null
                ? 'Student added successfully'
                : 'Student updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save student'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentNotifierProvider);
    final albumState = ref.watch(album_notifier.albumProvider);

    final dioceses = studentState.dioceses;
    final states = studentState.states;
    final yearLevels = albumState.yearLevels;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentId == null ? 'Add Student' : 'Edit Student'),
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
                    const Text(
                      'Personal Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // First Name
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter first name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    // Last Name
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter last name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    // Other Names
                    TextFormField(
                      controller: _otherNamesController,
                      decoration: const InputDecoration(
                        labelText: 'Other Names',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Registration Number
                    TextFormField(
                      controller: _registrationNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Registration Number *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter registration number'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    // Date of Birth
                    TextFormField(
                      controller: _dateOfBirthController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.cake),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () =>
                              _selectDate(context, _dateOfBirthController),
                        ),
                      ),
                      onTap: () => _selectDate(context, _dateOfBirthController),
                    ),
                    const SizedBox(height: 12),
                    // Hometown
                    TextFormField(
                      controller: _hometownController,
                      decoration: const InputDecoration(
                        labelText: 'Hometown *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter hometown'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    // State Dropdown
                    DropdownButtonFormField<String>(
                      initialValue:
                          (_selectedStateId != null && _selectedStateId != '')
                              ? _selectedStateId
                              : null,
                      decoration: const InputDecoration(
                        labelText: 'State of Origin',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Select State'),
                        ),
                        ...states.map((s) => DropdownMenuItem(
                              value: s['id'].toString(),
                              child: Text(s['name']),
                            )),
                      ],
                      onChanged: (v) => setState(() => _selectedStateId = v),
                    ),
                    const SizedBox(height: 12),
                    // Diocese Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: (_selectedDioceseId != null &&
                              _selectedDioceseId != '')
                          ? _selectedDioceseId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Diocese',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.church),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Select Diocese'),
                        ),
                        ...dioceses.map((d) => DropdownMenuItem(
                              value: d['id'].toString(),
                              child: Text(d['name']),
                            )),
                      ],
                      onChanged: (v) => setState(() => _selectedDioceseId = v),
                    ),
                    const SizedBox(height: 12),
                    // Year Level Dropdown
                    DropdownButtonFormField<String>(
                      initialValue:
                          (_selectedYearId != null && _selectedYearId != '')
                              ? _selectedYearId
                              : null,
                      decoration: const InputDecoration(
                        labelText: 'Year Level *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Select Year Level'),
                        ),
                        ...yearLevels.map((y) => DropdownMenuItem(
                              value: y.id,
                              child: Text(y.name),
                            )),
                      ],
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please select year level'
                          : null,
                      onChanged: (v) => setState(() => _selectedYearId = v),
                    ),
                    const SizedBox(height: 12),
                    // Personal Notes
                    TextFormField(
                      controller: _personalNotesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Personal Notes',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Active Status
                    SwitchListTile(
                      title: const Text('Active Status'),
                      subtitle: const Text(
                          'Inactive students will not appear in public views'),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeThumbColor: AppColors.primaryGold,
                    ),
                    const SizedBox(height: 24),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.studentId == null
                              ? 'Add Student'
                              : 'Update Student',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

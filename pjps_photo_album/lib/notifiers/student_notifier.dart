import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/student_service.dart';
import '../models/student_model.dart';

class StudentState {
  final List<Map<String, dynamic>> dioceses;
  final List<Map<String, dynamic>> states;
  final StudentDetailModel? currentStudent;
  final bool isLoading;
  final String? error;

  StudentState({
    this.dioceses = const [],
    this.states = const [],
    this.currentStudent,
    this.isLoading = false,
    this.error,
  });

  factory StudentState.initial() {
    return StudentState();
  }

  StudentState copyWith({
    List<Map<String, dynamic>>? dioceses,
    List<Map<String, dynamic>>? states,
    StudentDetailModel? currentStudent,
    bool? isLoading,
    String? error,
  }) {
    return StudentState(
      dioceses: dioceses ?? this.dioceses,
      states: states ?? this.states,
      currentStudent: currentStudent ?? this.currentStudent,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StudentNotifier extends StateNotifier<StudentState> {
  final StudentService _studentService;

  StudentNotifier(this._studentService) : super(StudentState.initial());

  // ================================
  // LOAD DIOCESES
  // ================================
  Future<void> loadDioceses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _studentService.getDioceses();
      state = state.copyWith(dioceses: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ================================
  // LOAD STATES
  // ================================
  Future<void> loadStates() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _studentService.getStates();
      state = state.copyWith(states: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ================================
  // LOAD STUDENT DETAILS
  // ================================
  Future<void> loadStudentDetails(String studentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final student = await _studentService.getStudentDetails(studentId);

      state = state.copyWith(
        isLoading: false,
        currentStudent: student,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load student details',
        currentStudent: null,
      );
    }
  }

  // ================================
  // CREATE STUDENT
  // ================================
  Future<bool> createStudent(StudentDetailModel student) async {
    try {
      final data = _mapStudentToRequest(student);

      await _studentService.createStudent(data);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // ================================
  // UPDATE STUDENT
  // ================================
  Future<bool> updateStudent(StudentDetailModel student) async {
    try {
      final data = _mapStudentToRequest(student);

      final int? studentId = int.tryParse(student.id);

      if (studentId == null) {
        throw Exception('Invalid student ID');
      }

      await _studentService.updateStudent(studentId, data);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // ================================
  // MAPPER (INSIDE CLASS ✅)
  // ================================
  Map<String, dynamic> _mapStudentToRequest(StudentDetailModel student) {
    return {
      'registration_number': student.registrationNumber,
      'first_name': student.firstName,
      'last_name': student.lastName,
      'other_names': student.otherNames,
      'date_of_birth': student.dateOfBirth,
      'diocese': student.diocese,
      'hometown': student.hometown,
      'state_of_origin': student.stateOfOrigin,
      'year_level': student.yearLevel,
      'enrollment_date': student.enrollmentDate,
      'is_graduated': student.isGraduated,
      'is_active': student.isActive,
      'personal_notes': student.personalNotes,
    };
  }
}

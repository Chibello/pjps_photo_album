// lib/providers/admin_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// --- Admin State ---
class AdminState {
  final bool isLoading;
  final String? error;

  AdminState({this.isLoading = false, this.error});

  AdminState copyWith({bool? isLoading, String? error}) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// --- Admin Notifier ---
final adminNotifierProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(AdminState());

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://your-api.com', // 🔥 SET YOUR REAL BASE URL HERE
    ),
  );

  // --- Delete Student ---
  Future<bool> deleteStudent(String studentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _dio.delete('/students/$studentId');

      // 🔥 OPTIONAL: trigger refresh if you implement it
      await loadAllStudents();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // --- Delete Staff ---
  Future<bool> deleteStaff(String staffId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _dio.delete('/staff/$staffId');

      // 🔥 OPTIONAL: trigger refresh
      await loadAllStaff();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // --- Load All Students ---
  Future<void> loadAllStudents() async {
    try {
      await _dio.get('/students');
      // 👉 You should update your main student list provider here
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // --- Load All Staff ---
  Future<void> loadAllStaff() async {
    try {
      await _dio.get('/staff');
      // 👉 Same here — update your staff list if needed
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

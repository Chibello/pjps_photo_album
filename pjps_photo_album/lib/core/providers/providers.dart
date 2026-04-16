import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../services/album_service.dart';
import '../../services/staff_service.dart';
import '../../services/remarks_service.dart';
import '../../services/connectivity_service.dart';

import '../../repositories/student_repository.dart';

import '../../notifiers/auth_notifier.dart';
import '../../notifiers/album_notifier.dart';
import '../../notifiers/staff_notifier.dart';
import '../../notifiers/student_notifier.dart';
import '../../notifiers/remarks_notifier.dart';
import '../../notifiers/sync_notifier.dart';

import '../database/database_helper.dart';
import '../routes/app_router.dart';

import '../../models/student_model.dart';
import '../../services/student_service.dart';
// ---------------------- Services ----------------------

// API Service
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Biometric Service
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

// Database Helper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Connectivity
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

// ---------------------- Auth ----------------------

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.read(apiServiceProvider),
    ref.read(biometricServiceProvider),
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(biometricServiceProvider),
  );
});

// ---------------------- Repository ----------------------

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(
    apiService: ref.read(apiServiceProvider),
    dbHelper: ref.read(databaseHelperProvider),
    connectivity: ref.read(connectivityProvider.notifier),
  );
});

// ---------------------- Album ----------------------

final albumServiceProvider = Provider<AlbumService>((ref) {
  return AlbumService(ref.read(apiServiceProvider));
});

final albumProvider = StateNotifierProvider<AlbumNotifier, AlbumState>((ref) {
  return AlbumNotifier(ref.read(albumServiceProvider));
});

// ✅ THIS IS THE ONLY CORRECT ONE
final studentsByYearProvider =
    FutureProvider.family<List<StudentListModel>, String>((ref, yearId) async {
  final albumService = ref.watch(albumServiceProvider);
  return albumService.getStudentsByYear(yearId);
});

// ---------------------- Staff ----------------------

final staffServiceProvider = Provider<StaffService>((ref) {
  return StaffService(ref.read(apiServiceProvider));
});

final staffProvider = StateNotifierProvider<StaffNotifier, StaffState>((ref) {
  return StaffNotifier(ref.read(staffServiceProvider));
});

// ---------------------- Remarks ----------------------

final remarksServiceProvider = Provider<RemarksService>((ref) {
  return RemarksService(ref.read(apiServiceProvider));
});

final remarksProvider =
    StateNotifierProvider<RemarksNotifier, RemarksState>((ref) {
  return RemarksNotifier(ref.read(remarksServiceProvider));
});

// ---------------------- Sync ----------------------

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier();
});

// ---------------------- Theme ----------------------

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

// ---------------------- Router ----------------------

final appRouterProvider = Provider((ref) {
  return appRouter;
});

// ---------------------- Remark Book ----------------------

final remarkBookProvider = FutureProvider.family(
  (ref, Map<String, String> params) async {
    final service = ref.read(remarksServiceProvider);
    return service.getRemarkBook(
      params['contentType']!,
      params['objectId']!,
    );
  },
);

// Provide AlbumService (used for students)
//final albumServiceProvider = Provider<AlbumService>((ref) {
//  final apiService = ref.read(apiServiceProvider);
//  return AlbumService(apiService);
//});

// ------------------------------
// Student Service Provider
// ------------------------------
final studentServiceProvider = Provider<StudentService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return StudentService(apiService); // ✅ Pass ApiService to StudentService
});

// ------------------------------
// Student Notifier Provider
// ------------------------------
final studentNotifierProvider =
    StateNotifierProvider<StudentNotifier, StudentState>((ref) {
  final studentService = ref.read(studentServiceProvider);
  return StudentNotifier(studentService);
});

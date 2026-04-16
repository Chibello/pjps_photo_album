// album_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_model.dart';
import '../models/year_level_model.dart';
import '../services/album_service.dart';
import '../repositories/student_repository.dart';
import '../services/connectivity_service.dart';
import '../services/image_cache_service.dart';
import '../core/database/database_helper.dart';

class AlbumState {
  final bool isLoadingYears;
  final bool isLoadingStudents;
  final bool isLoadingStudentDetail;

  final List<YearLevelModel> yearLevels;
  final List<StudentListModel> currentStudents;
  final StudentDetailModel? currentStudent;

  final Map<String, dynamic>? dashboardStats;
  final String? error;
  final bool isOffline;

  const AlbumState({
    this.isLoadingYears = false,
    this.isLoadingStudents = false,
    this.isLoadingStudentDetail = false,
    this.yearLevels = const [],
    this.currentStudents = const [],
    this.currentStudent,
    this.dashboardStats,
    this.error,
    this.isOffline = false,
  });

  AlbumState copyWith({
    bool? isLoadingYears,
    bool? isLoadingStudents,
    bool? isLoadingStudentDetail,
    List<YearLevelModel>? yearLevels,
    List<StudentListModel>? currentStudents,
    StudentDetailModel? currentStudent,
    bool clearCurrentStudent = false, // ✅ important fix
    Map<String, dynamic>? dashboardStats,
    String? error,
    bool? isOffline,
  }) {
    return AlbumState(
      isLoadingYears: isLoadingYears ?? this.isLoadingYears,
      isLoadingStudents: isLoadingStudents ?? this.isLoadingStudents,
      isLoadingStudentDetail:
          isLoadingStudentDetail ?? this.isLoadingStudentDetail,
      yearLevels: yearLevels ?? this.yearLevels,
      currentStudents: currentStudents ?? this.currentStudents,
      currentStudent:
          clearCurrentStudent ? null : currentStudent ?? this.currentStudent,
      dashboardStats: dashboardStats ?? this.dashboardStats,
      error: error,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class AlbumNotifier extends StateNotifier<AlbumState> {
  final Ref ref;
  final AlbumService _albumService;
  final StudentRepository _studentRepository;
  final ImageCacheService _imageCache = ImageCacheService();

  AlbumNotifier(this.ref, this._albumService, this._studentRepository)
      : super(const AlbumState());

  Future<bool> _isOnline() async =>
      await ref.read(connectivityProvider.notifier).isOnline;

  void _preloadStudentImages(List<StudentListModel> students) {
    final urls = students
        .map((s) => s.profilePhotoThumbnail)
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .toList();

    if (urls.isNotEmpty) {
      _imageCache.preloadImages(urls);
    }
  }

  // =========================
  // LOAD YEAR LEVELS
  // =========================
  Future<void> loadYearLevels() async {
    state = state.copyWith(
      isLoadingYears: true,
      error: null,
    );

    try {
      final isOnline = await _isOnline();

      if (isOnline) {
        try {
          final yearLevels = await _albumService.getYearLevels();

          state = state.copyWith(
            yearLevels: yearLevels,
            isLoadingYears: false,
            isOffline: false,
          );
          return;
        } catch (e) {
          print('Online fetch yearLevels failed: $e');
        }
      }

      // Offline fallback
      final cached = await DatabaseHelper().query('year_levels');

      final yearLevels = cached
          .map((json) => YearLevelModel.fromJson({
                'id': json['id'],
                'name': json['name'],
                'display_order': json['display_order'],
                'student_count': json['student_count'],
              }))
          .toList();

      state = state.copyWith(
        yearLevels: yearLevels,
        isLoadingYears: false,
        isOffline: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingYears: false,
        error: e.toString(),
      );
    }
  }

  // =========================
  // LOAD STUDENTS BY YEAR
  // =========================
  Future<void> loadStudentsInYear(String yearId) async {
    state = state.copyWith(
      isLoadingStudents: true,
      error: null,
    );

    try {
      final students = await _albumService.getStudentsByYear(yearId); // ✅ FIXED
      _preloadStudentImages(students);

      final isOffline = !(await _isOnline());

      state = state.copyWith(
        currentStudents: students,
        isLoadingStudents: false,
        isOffline: isOffline,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingStudents: false,
        error: e.toString(),
      );
    }
  }

  // =========================
  // LOAD STUDENT DETAILS
  // =========================
  Future<void> loadStudentDetails(String studentId) async {
    state = state.copyWith(
      isLoadingStudentDetail: true,
      error: null,
    );

    try {
      final student = await _albumService.getStudentDetails(studentId);

      if (student.additionalPhotos != null) {
        final urls = student.additionalPhotos!
            .map((p) => p['medium_url'] as String)
            .where((url) => url.isNotEmpty)
            .toList();

        _imageCache.preloadImages(urls);
      }

      final isOffline = !(await _isOnline());

      state = state.copyWith(
        currentStudent: student,
        isLoadingStudentDetail: false,
        isOffline: isOffline,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingStudentDetail: false,
        error: e.toString(),
      );
    }
  }

  // =========================
  // SEARCH STUDENTS
  // =========================
  Future<List<StudentListModel>> searchStudents(String query) async {
    state = state.copyWith(error: null);

    try {
      final students = await _albumService.searchStudents(query);
      _preloadStudentImages(students);

      final isOffline = !(await _isOnline());

      state = state.copyWith(
        currentStudents: students,
        isOffline: isOffline,
      );

      return students;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  // =========================
  // UTILITIES
  // =========================
  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCurrentStudent() {
    state = state.copyWith(clearCurrentStudent: true);
  }
}

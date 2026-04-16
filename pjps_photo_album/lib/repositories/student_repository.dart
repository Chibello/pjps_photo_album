// lib/repositories/student_repository.dart
import '../models/student_model.dart';
import '../services/api_service.dart';
import '../core/database/database_helper.dart';
import '../services/connectivity_service.dart';
import 'package:sqflite/sqflite.dart';

class StudentRepository {
  final ApiService apiService;
  final DatabaseHelper dbHelper;
  final ConnectivityNotifier connectivity;

  StudentRepository({
    required this.apiService,
    required this.dbHelper,
    required this.connectivity,
  });

  // ===============================
  // ONLINE-FIRST: Fetch students by year
  // ===============================
  Future<List<StudentListModel>> getStudentsByYear(String yearId) async {
    if (connectivity.isOnline == true) {
      try {
        final response = await apiService.get(
          '/students/',
          queryParameters: {'year_level': yearId},
        );

        final studentsData = response.data;
        if (studentsData == null || studentsData is! List) return [];

        return studentsData
            .map((json) =>
                StudentListModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } catch (_) {
        return getCachedStudentsInYear(yearId);
      }
    } else {
      return getCachedStudentsInYear(yearId);
    }
  }

  // ===============================
  // ONLINE-FIRST: Fetch students in a year with caching
  // ===============================
  Future<List<StudentListModel>> getStudentsInYear(String yearId) async {
    if (connectivity.isOnline == true) {
      try {
        final response =
            await apiService.get('/albums/students/', queryParameters: {
          'year_level': yearId,
        });

        final studentsData = (response.data['results'] ?? []) as List<dynamic>;

        final students = studentsData
            .map((json) =>
                StudentListModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        // Cache details
        for (var student in students) {
          final detail = await getStudentDetails(student.id);
          if (detail != null) await cacheStudentDetail(detail);
        }

        return students;
      } catch (_) {
        return getCachedStudentsInYear(yearId);
      }
    } else {
      return getCachedStudentsInYear(yearId);
    }
  }

  // ===============================
  // OFFLINE: Get cached students for a year
  // ===============================
  Future<List<StudentListModel>> getCachedStudentsInYear(String yearId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'students',
      where: 'year_level = ?',
      whereArgs: [yearId],
    );

    return result
        .map((json) => StudentListModel(
              id: json['id'] as String,
              registrationNumber: json['registration_number'] as String,
              fullName: json['full_name'] as String,
              profilePhotoThumbnail: json['profile_photo_original'] as String?,
              yearLevel: json['year_level'] as String?,
              yearLevelName: json['year_level_name'] as String?,
              isActive: (json['is_active'] as int) == 1,
              isGraduated: (json['is_graduated'] as int) == 1,
            ))
        .toList();
  }

  // ===============================
  // Get single student detail (online-first)
  // ===============================
  Future<StudentDetailModel?> getStudentDetails(String studentId) async {
    if (connectivity.isOnline == true) {
      try {
        final response = await apiService.get('/albums/students/$studentId/');
        if (response.data != null) {
          final student = StudentDetailModel.fromJson(
              Map<String, dynamic>.from(response.data));
          await cacheStudentDetail(student);
          return student;
        }
      } catch (_) {
        // fallback to cache
      }
    }
    return getCachedStudentDetail(studentId);
  }

  // ===============================
  // Cache student detail locally
  // ===============================
  Future<void> cacheStudentDetail(StudentDetailModel student) async {
    final db = await dbHelper.database;
    await db.insert(
      'students',
      {
        'id': student.id,
        'registration_number': student.registrationNumber,
        'full_name': student.fullName,
        'first_name': student.firstName,
        'last_name': student.lastName,
        'other_names': student.otherNames,
        'year_level': student.yearLevel,
        'year_level_name': student.yearLevelName,
        'profile_photo_original': student.profilePhotoOriginal,
        'is_graduated': student.isGraduated ? 1 : 0,
        'is_active': student.isActive ? 1 : 0,
        'personal_notes': student.personalNotes,
        'created_at': student.createdAt,
        'updated_at': student.updatedAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===============================
  // Get cached student detail
  // ===============================
  Future<StudentDetailModel?> getCachedStudentDetail(String studentId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [studentId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return StudentDetailModel.fromJson(result.first);
    }
    return null;
  }

  // ===============================
  // ONLINE-FIRST: Search students
  // ===============================
  Future<List<StudentListModel>> searchStudents(String query) async {
    if (connectivity.isOnline == true) {
      try {
        final response = await apiService.get(
          '/albums/students/',
          queryParameters: {'search': query},
        );

        final studentsData = response.data;
        if (studentsData == null || studentsData is! List) return [];

        final students = studentsData
            .map((json) =>
                StudentListModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        // Cache details
        for (var student in students) {
          final detail = await getStudentDetails(student.id);
          if (detail != null) await cacheStudentDetail(detail);
        }

        return students;
      } catch (_) {
        return searchCachedStudents(query);
      }
    } else {
      return searchCachedStudents(query);
    }
  }

  // ===============================
  // OFFLINE: Search cached students
  // ===============================
  Future<List<StudentListModel>> searchCachedStudents(String query) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'students',
      where: 'full_name LIKE ? OR registration_number LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return result
        .map((json) => StudentListModel(
              id: json['id'] as String,
              registrationNumber: json['registration_number'] as String,
              fullName: json['full_name'] as String,
              profilePhotoThumbnail: json['profile_photo_original'] as String?,
              yearLevel: json['year_level'] as String?,
              yearLevelName: json['year_level_name'] as String?,
              isActive: (json['is_active'] as int) == 1,
              isGraduated: (json['is_graduated'] as int) == 1,
            ))
        .toList();
  }

  // ===============================
  // Fetch all years (cached)
  // ===============================
  Future<List<String>> getAllYears() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'students',
      columns: ['year_level'],
      distinct: true,
    );
    return result.map((row) => row['year_level'] as String).toList();
  }
}

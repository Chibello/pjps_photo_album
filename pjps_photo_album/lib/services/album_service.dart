import 'package:dio/dio.dart';
import '../models/student_model.dart';
import '../models/year_level_model.dart';
import 'api_service.dart';

class AlbumService {
  final ApiService _apiService;

  AlbumService(this._apiService);

  // ================================
  // HELPER: Parse List of Maps
  // ================================
  List<T> _parseList<T>(
      dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is List) {
      return data.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  // ================================
  // GET YEAR LEVELS
  // ================================
  Future<List<YearLevelModel>> getYearLevels() async {
    try {
      final response = await _apiService.get('/albums/year-levels/');
      final data = response.data;

      // Handle both cases: list directly or { "results": [...] }
      final results = data is List ? data : (data['results'] ?? []);
      return _parseList(results, (json) => YearLevelModel.fromJson(json));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ================================
  // GET STUDENTS BY YEAR
  // ================================
  Future<List<StudentListModel>> getStudentsByYear(String yearLevelId) async {
    try {
      final response =
          await _apiService.get('/albums/students/by-year/$yearLevelId/');
      final data = response.data;
      final results = data is List ? data : (data['results'] ?? []);
      return _parseList(results, (json) => StudentListModel.fromJson(json));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ================================
  // GET ALL STUDENTS
  // ================================
  Future<List<StudentListModel>> getAllStudents() async {
    try {
      final response = await _apiService.get('/albums/students/');
      final data = response.data;
      final results = data is List ? data : (data['results'] ?? []);
      return _parseList(results, (json) => StudentListModel.fromJson(json));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ================================
  // GET STUDENT DETAILS
  // ================================
  // Future<StudentDetailModel> getStudentDetails(String studentId) async {
  //   try {
  //     final response = await _apiService.get('/albums/students/$studentId/');
  //     return StudentDetailModel.fromJson(
  //         Map<String, dynamic>.from(response.data));
  //   } on DioException catch (e) {
  //     throw Exception(_handleError(e));
  //   }
  // }
//=======================================
// ================================
  // GET FULL STUDENT DETAILS
  // ================================
  Future<StudentDetailModel> getStudentFullDetails(String studentId) async {
    try {
      // Call the correct API endpoint for full student info
      final response = await _apiService.get('/albums/students/$studentId/');
      //final response = await _apiService.get('/students/$studentId/');
      final data = response.data as Map<String, dynamic>;

      return StudentDetailModel.fromJson(data);
    } catch (e) {
      print('Error fetching student details: $e');
      rethrow;
    }
  }

//=======================================
//Future<StudentDetailModel> getStudentFullDetails(String studentId) async {
//  final response = await apiService.get('/students/$studentId/');
//  return StudentDetailModel.fromJson(response);
//}
  //=====================================
  Future<StudentDetailModel> getStudentDetails(String studentId) async {
    try {
      final response = await _apiService.get('/albums/students/$studentId/');
      final data = response.data;

      // Ensure data is a map
      final map =
          data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data);

      return StudentDetailModel.fromJson(map);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ================================
  // SEARCH STUDENTS
  // ================================
  Future<List<StudentListModel>> searchStudents(String query) async {
    try {
      final response = await _apiService
          .get('/albums/students/', queryParameters: {'search': query});
      final data = response.data;
      final results = data is List ? data : (data['results'] ?? []);
      return _parseList(results, (json) => StudentListModel.fromJson(json));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ================================
  // DELETE STUDENT
  // ================================
  Future<void> deleteStudent(String studentId) async {
    try {
      await _apiService.delete('/albums/students/$studentId/');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ================================
  // DASHBOARD STATS
  // ================================
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiService.get('/albums/dashboard/stats/');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ================================
  // ERROR HANDLER
  // ================================
  String _handleError(DioException e) {
    if (e.response?.data != null) {
      if (e.response?.data is Map) {
        return e.response?.data['error'] ??
            e.response?.data['message'] ??
            'An error occurred';
      }
      return e.response?.data.toString() ?? 'An error occurred';
    }
    return 'Network error. Please check your connection.';
  }
}

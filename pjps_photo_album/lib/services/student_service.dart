import 'package:dio/dio.dart';
import '../models/student_model.dart';
import 'api_service.dart';

class StudentService {
  final ApiService _apiService;

  StudentService(this._apiService);

  // =======================
  // GET DIOCESES
  // =======================
  Future<List<Map<String, dynamic>>> getDioceses() async {
    try {
      final response = await _apiService.get('/dioceses/');

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Invalid dioceses response format');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // =======================
  // GET STATES
  // =======================
  Future<List<Map<String, dynamic>>> getStates() async {
    try {
      final response = await _apiService.get('/states/');

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Invalid states response format');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // =======================
  // GET STUDENT DETAILS
  // =======================
  Future<StudentDetailModel> getStudentDetails(String studentId) async {
    try {
      final response = await _apiService.get('/students/$studentId/');

      if (response.data is Map<String, dynamic>) {
        return StudentDetailModel.fromJson(response.data);
      } else {
        throw Exception('Invalid student response format');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // =======================
  // CREATE STUDENT
  // =======================
  Future<void> createStudent(Map<String, dynamic> studentData) async {
    try {
      final response = await _apiService.post('/students/', data: studentData);

      if (response.statusCode != 201) {
        throw Exception('Failed to create student');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // =======================
  // UPDATE STUDENT
  // =======================
  Future<void> updateStudent(
    int studentId,
    Map<String, dynamic> studentData,
  ) async {
    try {
      final response = await _apiService.put(
        '/students/$studentId/',
        data: studentData,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update student');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // =======================
  // ERROR HANDLER
  // =======================
  String _handleError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;

      if (data is Map<String, dynamic>) {
        return data['error'] ?? data['message'] ?? data.toString();
      }

      return data.toString();
    }

    return 'Network error. Please check your connection.';
  }
}

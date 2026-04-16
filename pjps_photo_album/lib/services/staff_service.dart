import 'package:dio/dio.dart';
import '../models/staff_model.dart';
import 'api_service.dart';

class StaffService {
  final ApiService _apiService;

  StaffService(this._apiService);

  // Staff Categories
  Future<List<Map<String, dynamic>>> getStaffCategories() async {
    try {
      final response = await _apiService.get('/staff/categories/');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Staff List
  Future<List<StaffListModel>> getStaff({String? categoryId}) async {
    try {
      final queryParams = categoryId != null ? {'category': categoryId} : null;
      final response = await _apiService.get(
        '/staff/staff/',
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((json) => StaffListModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Staff Details
  Future<StaffDetailModel> getStaffDetails(String staffId) async {
    try {
      final response = await _apiService.get('/staff/staff/$staffId/');
      return StaffDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Search Staff
  Future<List<StaffListModel>> searchStaff(String query) async {
    try {
      final response = await _apiService.get(
        '/staff/staff/',
        queryParameters: {'search': query},
      );
      return (response.data as List)
          .map((json) => StaffListModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // =======================
  // CREATE STAFF
  // =======================
  Future<void> createStaff(Map<String, dynamic> staffData) async {
    try {
      final response = await _apiService.post('/staff/staff/', data: staffData);
      if (response.statusCode != 201) {
        throw Exception('Failed to create staff');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // =======================
  // UPDATE STAFF
  // =======================
  Future<void> updateStaff(
      String staffId, Map<String, dynamic> staffData) async {
    try {
      final response =
          await _apiService.put('/staff/staff/$staffId/', data: staffData);
      if (response.statusCode != 200) {
        throw Exception('Failed to update staff');
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

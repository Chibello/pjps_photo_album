// lib/repositories/staff_repository.dart
import 'package:dio/dio.dart';
import '../models/staff_model.dart';

class StaffRepository {
  final Dio _dio;

  StaffRepository({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetch all active staff members
  Future<List<StaffListModel>> getAllStaff() async {
    try {
      final response = await _dio.get('/staff');
      final data = response.data as List<dynamic>;
      return data.map((json) => StaffListModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching staff list: $e');
      return [];
    }
  }

  /// Fetch staff details by staffId
  Future<StaffDetailModel?> getStaffDetails(String staffId) async {
    try {
      final response = await _dio.get('/staff/$staffId');
      if (response.statusCode == 200 && response.data != null) {
        return StaffDetailModel.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetching staff details: $e');
    }
    return null;
  }
}

import 'package:dio/dio.dart';
import '../models/remark_model.dart';
import 'api_service.dart';

class RemarksService {
  final ApiService _apiService;

  RemarksService(this._apiService);

  Future<RemarkBookModel> getRemarkBook(
      String contentType, String objectId) async {
    try {
      final response = await _apiService.get(
        '/remarks/books/$contentType/$objectId/',
      );
      return RemarkBookModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<RemarkModel> addRemark({
    required String contentType,
    required String objectId,
    required String title,
    required String content,
    String remarkType = 'GENERAL',
    String visibility = 'INTERNAL',
  }) async {
    try {
      final response = await _apiService.post(
        '/remarks/books/$contentType/$objectId/',
        data: {
          'title': title,
          'content': content,
          'remark_type': remarkType,
          'visibility': visibility,
        },
      );
      return RemarkModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

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

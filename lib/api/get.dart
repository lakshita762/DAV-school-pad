import 'package:dio/dio.dart';

import '../extras/string.dart';
import 'client.dart';
import 'models/student_detail_model.dart';

class GetApi {
  final Dio _dio = DioClient().dio;

  Future<StudentDetailResponse> fetchStudentDetail({
    required String token,
    String endpoint = '/api/student-detail',
  }) async {
    try {
      final Response<dynamic> response = await _dio.get(
        endpoint,
        options: Options(
          headers: <String, dynamic>{
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final Map<String, dynamic> body = _asMap(response.data);
      return StudentDetailResponse.fromJson(body);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timed out. Please try again.');
      case DioExceptionType.badResponse:
        final int? statusCode = e.response?.statusCode;
        final dynamic body = e.response?.data;
        final String message = _asMap(body)['message']?.toString() ??
            'Something went wrong';
        if (statusCode == 401) {
          return Exception(
            Strings.errorServer(401, 'Unauthorized. Please log in again.'),
          );
        }
        return Exception('Server error ($statusCode): $message');
      case DioExceptionType.connectionError:
        return Exception('No internet connection.');
      default:
        return Exception('Unexpected error: ${e.message}');
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}

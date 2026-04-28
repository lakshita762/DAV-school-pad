import 'package:dio/dio.dart';

import '../extras/string.dart';
import 'client.dart';
import 'models/config_model.dart';
import 'models/login_model.dart';

class Post {
  final Dio _dio = DioClient().dio;

  Future<LoginResponse> login(LoginRequest request, String url) async {
    try {
      final response = await _dio.post(url, data: request.toJson());

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<ConfigModel>> fetchConfig() async {
    try {
      final response = await _dio.post('/api/org-codes');

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((item) => ConfigModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> updateStudent({
    required String token,
    String? dob,
    String? email,
    String? mobile,
  }) async {
    final Map<String, dynamic> fields = <String, dynamic>{};
    if (dob != null && dob.trim().isNotEmpty) fields['dob'] = dob.trim();
    if (email != null && email.trim().isNotEmpty) {
      fields['email'] = email.trim();
    }
    if (mobile != null && mobile.trim().isNotEmpty) {
      fields['mobile'] = mobile.trim();
    }

    try {
      final Response<dynamic> response = await _dio.post(
        '/update-student',
        data: FormData.fromMap(fields),
        options: Options(
          headers: <String, dynamic>{'Authorization': 'Bearer $token'},
        ),
      );

      return _asMap(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getHash({
    required String hashName,
    required String hashString,
    String? postSalt,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/api/generate-hash',
        data: {
          'hashName': hashName,
          'hashString': hashString,
          'postSalt': postSalt,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Map<String, dynamic>.from(response.data);
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
        final statusCode = e.response?.statusCode;
        final Map<String, dynamic> body = _asMap(e.response?.data);
        final String message =
            body['message']?.toString() ?? 'Something went wrong';
        if (statusCode == 401) {
          return Exception(
            Strings.errorServer(401, 'Invalid admission number or DOB.'),
          );
        }
        if (statusCode == 422) {
          return Exception(
            Strings.errorServer(422, 'Validation error: $message'),
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

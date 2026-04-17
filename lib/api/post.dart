import 'package:dio/dio.dart';

import '../extras/string.dart';
import 'client.dart';
import 'models/config_model.dart';
import 'models/login_model.dart';


class Post {
  final Dio _dio = DioClient().dio;

  Future<LoginResponse> login(LoginRequest request, String url) async {
    try {
      final response = await _dio.post(
        url,
        data: request.toJson(),
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<ConfigModel>> fetchConfig() async {
    try {
      final response = await _dio.post('/api/org-codes');

      final List<dynamic> data = response.data as List<dynamic>;
      print(data);
      return data.map((item) => ConfigModel.fromJson(item)).toList();

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
       print('hashName $hashName hashString $hashString');
       final response = await _dio.post(
         '/api/generate-hash',
         data: {
           'hashName': hashName,
           'hashString': hashString,
           'postSalt': postSalt,
         },
         options: Options(
           headers: {
             'Authorization': 'Bearer $token',
           },
         ),
       );
       print('responses $response');

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
        final message = e.response?.data['message'] ?? 'Something went wrong';
        if (statusCode == 401) return Exception(Strings.errorServer(401, 'Invalid admission number or DOB.'));
        if (statusCode == 422) return Exception(Strings.errorServer(422, 'Validation error: $message'));
        return Exception('Server error ($statusCode): $message');
      case DioExceptionType.connectionError:
        return Exception('No internet connection.');
      default:
        return Exception('Unexpected error: ${e.message}');
    }
  }
}

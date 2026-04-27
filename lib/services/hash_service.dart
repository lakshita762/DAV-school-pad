import 'dart:convert';
import 'package:http/http.dart' as http;

class HashService {
  static const String _baseUrl = 'http://school.loc';

  /// Called by PayU SDK via generateHash() callback
  /// Sends hashString to backend → returns { hashName, hash }
  static Future<Map<String, String>> getHash2({
    required String hashName,
    required String hashString,
    required String hashType,
    String? postSalt,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/generate-hash'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hashName': hashName,
        'hashString': hashString,
        'hashType': hashType,
        if (postSalt != null) 'postSalt': postSalt,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'hashName': data['hashName'],
        'hash': data['hash'],
      };
    } else {
      throw Exception('Hash generation failed: ${response.body}');
    }
  }
}
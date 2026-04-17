import 'dart:convert';
import 'package:crypto/crypto.dart';

class LocalHashService {
  // ⚠️ TEST ONLY
  static const String _salt = 'iBQxbo2R5jG0bLfiQRSnOCcqe2ov3ZLi';

  static String generateHash({
    required String hashName,
    required String hashString,
    String hashType = 'V1',
    String? postSalt,
  }) {
    try {
      String finalHashString = hashString + _salt;

      if (postSalt != null && postSalt.isNotEmpty) {
        finalHashString += postSalt;
      }

      final bytes = utf8.encode(finalHashString);
      final digest = sha512.convert(bytes);

      return digest.toString().toLowerCase();
    } catch (e) {
      print('Local hash error: $e');
      return '';
    }
  }
}
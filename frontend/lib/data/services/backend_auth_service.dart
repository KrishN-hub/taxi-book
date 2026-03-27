import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../app/config/app_config.dart';

class BackendAuthService {
  Future<String> exchangeFirebaseForBackendToken({
    required String firebaseUid,
    required String email,
    required String name,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/firebase-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebaseUid': firebaseUid,
          'email': email,
          'name': name,
          'role': role,
        }),
      );

      final data = (response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{}) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(data['message'] ?? 'Failed to exchange auth token');
      }
      return data['token'] as String;
    } on SocketException {
      throw Exception(
        'Cannot reach backend server. Start backend and set BACKEND_BASE_URL for physical phone. Current URL: ${AppConfig.baseUrl}',
      );
    }
  }
}

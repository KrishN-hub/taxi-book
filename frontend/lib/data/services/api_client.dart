import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../app/config/app_config.dart';

class ApiClient {
  Future<Map<String, dynamic>> get(
    String path, {
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final decoded = (response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{}) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw Exception(decoded['message'] ?? 'API error ${response.statusCode}');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class BaseApiService {
  final AuthService authService;

  BaseApiService(this.authService);

  String get baseUrl {
    return dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await authService.getIdToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw ApiException(
        'Request failed with status ${response.statusCode}: ${response.body}',
        response.statusCode,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}


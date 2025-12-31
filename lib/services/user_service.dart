import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_service.dart';

class UserService extends BaseApiService {
  UserService(super.authService);

  Future<Map<String, dynamic>> createUser({
    required String firebaseUid,
    required String email,
    required String username,
    String? displayName,
    String? photoURL,
  }) async {
    final headers = await getHeaders();
    final body = {
      'firebaseUid': firebaseUid,
      'email': email,
      'username': username,
      if (displayName != null) 'displayName': displayName,
      if (photoURL != null) 'photoURL': photoURL,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/user'),
      headers: headers,
      body: json.encode(body),
    );

    return handleResponse(response);
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: headers,
    );

    return handleResponse(response);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user/all'),
      headers: headers,
    );

    final data = handleResponse(response);
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<Map<String, dynamic>> getUserById(String id) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user/$id'),
      headers: headers,
    );

    return handleResponse(response);
  }

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user/email/$email'),
      headers: headers,
    );

    return handleResponse(response);
  }

  Future<Map<String, dynamic>> getUserByFirebaseUid(String firebaseUid) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user/firebase/$firebaseUid'),
      headers: headers,
    );

    return handleResponse(response);
  }

  Future<Map<String, dynamic>> getUserByUsername(String username) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user/username/$username'),
      headers: headers,
    );

    return handleResponse(response);
  }

  Future<Map<String, dynamic>> updateUser({
    required String id,
    String? displayName,
    String? photoURL,
  }) async {
    final headers = await getHeaders();
    final body = <String, dynamic>{};
    if (displayName != null) body['displayName'] = displayName;
    if (photoURL != null) body['photoURL'] = photoURL;

    final response = await http.patch(
      Uri.parse('$baseUrl/user/$id'),
      headers: headers,
      body: json.encode(body),
    );

    return handleResponse(response);
  }

  Future<void> deleteUser(String id) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/user/$id'),
      headers: headers,
    );

    handleResponse(response);
  }
}


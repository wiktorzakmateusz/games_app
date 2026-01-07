import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:games_app/core/error/exceptions.dart';
import 'package:games_app/core/utils/error_parser.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> createUser({
    required String firebaseUid,
    required String email,
    required String username,
    String? displayName,
    String? photoURL,
  });

  Future<UserModel> getUserByFirebaseUid(String firebaseUid);

  Future<UserModel> getCurrentUser();

  Future<UserModel> updateUser({
    required String id,
    String? username,
    String? displayName,
    String? photoURL,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final Future<String> Function() getIdToken;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.getIdToken,
  });

  String get baseUrl {
    return dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }


  @override
  Future<UserModel> createUser({
    required String firebaseUid,
    required String email,
    required String username,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'firebaseUid': firebaseUid,
        'email': email,
        'username': username,
        if (displayName != null) 'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
      };

      final response = await client.post(
        Uri.parse('$baseUrl/user'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(jsonData);
      } else {
        final errorMessage = ErrorParser.parseErrorMessage(response);
        throw ServerException(
          errorMessage,
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to create user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getUserByFirebaseUid(String firebaseUid) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/user/firebase/$firebaseUid'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw CacheException('User not found');
      } else {
        final errorMessage = ErrorParser.parseErrorMessage(response);
        throw ServerException(
          errorMessage,
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException || e is CacheException) rethrow;
      throw ServerException('Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/user'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(jsonData);
      } else {
        final errorMessage = ErrorParser.parseErrorMessage(response);
        throw ServerException(
          errorMessage,
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUser({
    required String id,
    String? username,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};
      if (username != null) body['username'] = username;
      if (displayName != null) body['displayName'] = displayName;
      if (photoURL != null) body['photoURL'] = photoURL;

      final response = await client.patch(
        Uri.parse('$baseUrl/user/$id'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(jsonData);
      } else {
        final errorMessage = ErrorParser.parseErrorMessage(response);
        throw ServerException(
          errorMessage,
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update user: ${e.toString()}');
    }
  }
}


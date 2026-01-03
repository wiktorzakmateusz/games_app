import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../auth/data/datasources/auth_firebase_datasource.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Remote data source for game operations (Backend API)
abstract class GameRemoteDataSource {
  Future<JsonMap> startGame(String lobbyId);
  Future<void> makeMove({required String gameId, required int position});
  Future<void> abandonGame(String gameId);
  Future<JsonMap> getGame(String gameId);
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final AuthFirebaseDataSource authDataSource;
  final http.Client client;

  GameRemoteDataSourceImpl({
    required this.authDataSource,
    required this.client,
  });

  String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';

  Future<Map<String, String>> _getHeaders() async {
    final token = await authDataSource.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<JsonMap> startGame(String lobbyId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl/games/start/$lobbyId'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as JsonMap;
        return data['game'] as JsonMap;
      } else {
        throw ServerException(
          'Failed to start game: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to start game: $e');
    }
  }

  @override
  Future<void> makeMove({
    required String gameId,
    required int position,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({'position': position});

      final response = await client.post(
        Uri.parse('$baseUrl/games/$gameId/move'),
        headers: headers,
        body: body,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
          'Failed to make move: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to make move: $e');
    }
  }

  @override
  Future<void> abandonGame(String gameId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl/games/$gameId/abandon'),
        headers: headers,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
          'Failed to abandon game: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to abandon game: $e');
    }
  }

  @override
  Future<JsonMap> getGame(String gameId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/games/$gameId'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as JsonMap;
        return data['game'] as JsonMap;
      } else {
        throw ServerException(
          'Failed to get game: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get game: $e');
    }
  }
}


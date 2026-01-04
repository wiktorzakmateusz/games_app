import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../models/enums.dart';
import '../../../auth/data/datasources/auth_firebase_datasource.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class LobbyRemoteDataSource {
  Future<JsonMap> createLobby({
    required String name,
    required GameType gameType,
    required int maxPlayers,
  });
  Future<void> joinLobby(String lobbyId);
  Future<void> leaveLobby(String lobbyId);
  Future<void> toggleReady(String lobbyId);
  Future<JsonMap> getLobby(String lobbyId);
  Future<List<JsonMap>> getAvailableLobbies();
  Future<JsonMap?> getCurrentUserLobby();
}

class LobbyRemoteDataSourceImpl implements LobbyRemoteDataSource {
  final AuthFirebaseDataSource authDataSource;
  final http.Client client;

  LobbyRemoteDataSourceImpl({
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
  Future<JsonMap> createLobby({
    required String name,
    required GameType gameType,
    required int maxPlayers,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'name': name,
        'gameType': gameType.value,
        'maxPlayers': maxPlayers,
      });

      final response = await client.post(
        Uri.parse('$baseUrl/lobbies'),
        headers: headers,
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as JsonMap;
        return data['lobby'] as JsonMap;
      } else {
        throw ServerException(
          'Failed to create lobby: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to create lobby: $e');
    }
  }

  @override
  Future<void> joinLobby(String lobbyId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl/lobbies/$lobbyId/join'),
        headers: headers,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
          'Failed to join lobby: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to join lobby: $e');
    }
  }

  @override
  Future<void> leaveLobby(String lobbyId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl/lobbies/$lobbyId/leave'),
        headers: headers,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
          'Failed to leave lobby: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to leave lobby: $e');
    }
  }

  @override
  Future<void> toggleReady(String lobbyId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl/lobbies/$lobbyId/ready'),
        headers: headers,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
          'Failed to toggle ready: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to toggle ready: $e');
    }
  }

  @override
  Future<JsonMap> getLobby(String lobbyId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/lobbies/$lobbyId'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as JsonMap;
        return data['lobby'] as JsonMap;
      } else {
        throw ServerException(
          'Failed to get lobby: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get lobby: $e');
    }
  }

  @override
  Future<List<JsonMap>> getAvailableLobbies() async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/lobbies'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as JsonMap;
        final lobbiesData = data['lobbies'] as List;
        return lobbiesData.map((l) => l as JsonMap).toList();
      } else {
        throw ServerException(
          'Failed to get lobbies: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get lobbies: $e');
    }
  }

  @override
  Future<JsonMap?> getCurrentUserLobby() async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/lobbies/user/current'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as JsonMap;
        return data['lobby'] as JsonMap?;
      } else {
        throw ServerException(
          'Failed to get current user lobby: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get current user lobby: $e');
    }
  }
}


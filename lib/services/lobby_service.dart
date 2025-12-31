import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lobby.dart';
import '../models/enums.dart';
import 'base_api_service.dart';

class LobbyService extends BaseApiService {
  LobbyService(super.authService);

  Future<Lobby> createLobby({
    required String name,
    required GameType gameType,
    required int maxPlayers,
  }) async {
    final headers = await getHeaders();
    final body = json.encode({
      'name': name,
      'gameType': gameType.value,
      'maxPlayers': maxPlayers,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/lobbies'),
      headers: headers,
      body: body,
    );

    final data = handleResponse(response);
    return Lobby.fromJson(data['lobby'] as Map<String, dynamic>);
  }

  Future<List<Lobby>> getAvailableLobbies() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/lobbies'),
      headers: headers,
    );

    final data = handleResponse(response);
    final lobbiesData = data['lobbies'] as List;
    return lobbiesData
        .map((l) => Lobby.fromJson(l as Map<String, dynamic>))
        .toList();
  }

  Future<Lobby> getLobby(String lobbyId) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/lobbies/$lobbyId'),
      headers: headers,
    );

    final data = handleResponse(response);
    return Lobby.fromJson(data['lobby'] as Map<String, dynamic>);
  }

  Future<void> joinLobby(String lobbyId) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/lobbies/$lobbyId/join'),
      headers: headers,
    );

    handleResponse(response);
  }

  Future<void> leaveLobby(String lobbyId) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/lobbies/$lobbyId/leave'),
      headers: headers,
    );

    handleResponse(response);
  }

  Future<void> toggleReady(String lobbyId) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/lobbies/$lobbyId/ready'),
      headers: headers,
    );

    handleResponse(response);
  }

  Future<Lobby?> getCurrentUserLobby() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/lobbies/user/current'),
      headers: headers,
    );

    final data = handleResponse(response);
    final lobbyData = data['lobby'];
    if (lobbyData == null) return null;
    return Lobby.fromJson(lobbyData as Map<String, dynamic>);
  }
}


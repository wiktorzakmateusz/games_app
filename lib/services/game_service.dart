import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';
import 'base_api_service.dart';

class GameService extends BaseApiService {
  GameService(super.authService);

  Future<Game> startGame(String lobbyId) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/games/start/$lobbyId'),
      headers: headers,
    );

    final data = handleResponse(response);
    return Game.fromJson(data['game'] as Map<String, dynamic>);
  }

  Future<Game> getGame(String gameId) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/games/$gameId'),
      headers: headers,
    );

    final data = handleResponse(response);
    return Game.fromJson(data['game'] as Map<String, dynamic>);
  }

  Future<void> makeMove({
    required String gameId,
    required int position,
  }) async {
    final headers = await getHeaders();
    final body = json.encode({
      'position': position,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/games/$gameId/move'),
      headers: headers,
      body: body,
    );

    handleResponse(response);
  }

  Future<void> abandonGame(String gameId) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/games/$gameId/abandon'),
      headers: headers,
    );

    handleResponse(response);
  }

  Future<List<Map<String, dynamic>>> getGameMoves(String gameId) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/games/$gameId/moves'),
      headers: headers,
    );

    final data = handleResponse(response);
    return List<Map<String, dynamic>>.from(data['moves'] as List);
  }
}


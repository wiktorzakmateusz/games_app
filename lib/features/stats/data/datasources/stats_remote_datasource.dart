import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:games_app/core/error/exceptions.dart';
import 'package:games_app/core/utils/error_parser.dart';
import '../models/stats_model.dart';
import '../../../../core/shared/enums.dart';

abstract class StatsRemoteDataSource {
  Future<List<StatsModel>> getUserStats(String userId);
  
  Future<StatsModel?> getUserStatsByGameType(
    String userId,
    GameType gameType,
  );
  
  Future<AggregateStatsModel> getAggregateStats(String userId);
}

class StatsRemoteDataSourceImpl implements StatsRemoteDataSource {
  final http.Client client;
  final Future<String> Function() getIdToken;

  StatsRemoteDataSourceImpl({
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
  Future<List<StatsModel>> getUserStats(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/stats/user/$userId'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final statsList = jsonData['stats'] as List;
        return statsList
            .map((stat) => StatsModel.fromJson(stat as Map<String, dynamic>))
            .toList();
      } else {
        final errorMessage = ErrorParser.parseErrorMessage(response);
        throw ServerException(
          errorMessage,
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get user stats: ${e.toString()}');
    }
  }

  @override
  Future<StatsModel?> getUserStatsByGameType(
    String userId,
    GameType gameType,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/stats/user/$userId/game/${gameType.value}'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final statsData = jsonData['stats'] as Map<String, dynamic>;
        
        // If all values are 0, return null (no stats yet)
        if (statsData['played'] == 0 && statsData['wins'] == 0) {
          return null;
        }
        
        return StatsModel.fromJson(statsData);
      } else {
        final errorMessage = ErrorParser.parseErrorMessage(response);
        throw ServerException(
          errorMessage,
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        'Failed to get stats by game type: ${e.toString()}',
      );
    }
  }

  @override
  Future<AggregateStatsModel> getAggregateStats(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/stats/user/$userId/summary'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final statsData = jsonData['stats'] as Map<String, dynamic>;
        return AggregateStatsModel.fromJson(statsData);
      } else {
        final errorMessage = ErrorParser.parseErrorMessage(response);
        throw ServerException(
          errorMessage,
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        'Failed to get aggregate stats: ${e.toString()}',
      );
    }
  }
}


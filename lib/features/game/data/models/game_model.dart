import '../../../../core/utils/typedefs.dart';
import '../../../../models/enums.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/game_player_entity.dart';
import '../../domain/entities/game_state_entity.dart';
import 'game_state_model.dart';

class GameModel {
  final String id;
  final String lobbyId;
  final GameType gameType;
  final GameStatus status;
  final String currentPlayerId;
  final List<GamePlayerEntity> players;
  final BaseGameStateEntity state;
  final String? winnerId;
  final DateTime startedAt;
  final DateTime? endedAt;

  GameModel({
    required this.id,
    required this.lobbyId,
    required this.gameType,
    required this.status,
    required this.currentPlayerId,
    required this.players,
    required this.state,
    this.winnerId,
    required this.startedAt,
    this.endedAt,
  });

  factory GameModel.fromJson(JsonMap json) {
    final playersData = json['players'] as List? ?? [];
    final players = playersData
        .map((p) => GamePlayerEntity(
              userId: p['userId'] as String,
              username: p['username'] as String,
              displayName: p['displayName'] as String,
              symbol: p['symbol'] as String?,
            ))
        .toList();

    final gameType =
        GameType.fromString(json['gameType'] as String? ?? 'TIC_TAC_TOE');
    final stateData = json['state'] as JsonMap? ?? {};
    final state = GameStateModel.fromJson(gameType, stateData);

    return GameModel(
      id: json['id'] as String,
      lobbyId: json['lobbyId'] as String,
      gameType: gameType,
      status:
          GameStatus.fromString(json['status'] as String? ?? 'IN_PROGRESS'),
      currentPlayerId: json['currentPlayerId'] as String,
      players: players,
      state: state,
      winnerId: json['winnerId'] as String?,
      startedAt: _parseDateTime(json['startedAt']),
      endedAt: json['endedAt'] != null ? _parseDateTime(json['endedAt']) : null,
    );
  }

  JsonMap toJson() {
    return {
      'id': id,
      'lobbyId': lobbyId,
      'gameType': gameType.value,
      'status': status.value,
      'currentPlayerId': currentPlayerId,
      'players': players
          .map((p) => {
                'userId': p.userId,
                'username': p.username,
                'displayName': p.displayName,
                if (p.symbol != null) 'symbol': p.symbol,
              })
          .toList(),
      'state': (state as GameStateModel).toJson(),
      'winnerId': winnerId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
    };
  }

  GameEntity toEntity() {

    final stateEntity = (state as TicTacToeGameStateModel).toEntity();
    
    return GameEntity(
      id: id,
      lobbyId: lobbyId,
      gameType: gameType,
      status: status,
      currentPlayerId: currentPlayerId,
      players: players,
      state: stateEntity,
      winnerId: winnerId,
      startedAt: startedAt,
      endedAt: endedAt,
    );
  }

  factory GameModel.fromEntity(GameEntity entity) {
    return GameModel(
      id: entity.id,
      lobbyId: entity.lobbyId,
      gameType: entity.gameType,
      status: entity.status,
      currentPlayerId: entity.currentPlayerId,
      players: entity.players,
      state: entity.state,
      winnerId: entity.winnerId,
      startedAt: entity.startedAt,
      endedAt: entity.endedAt,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is Map && value['seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['seconds'] as int) * 1000,
      );
    }
    return DateTime.now();
  }
}


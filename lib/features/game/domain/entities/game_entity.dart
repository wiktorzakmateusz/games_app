import 'package:equatable/equatable.dart';
import '../../../../models/enums.dart';
import 'game_player_entity.dart';
import 'game_state_entity.dart';

class GameEntity extends Equatable {
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

  const GameEntity({
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

  bool isPlayerTurn(String userId) => currentPlayerId == userId;

  GamePlayerEntity? get currentPlayer {
    try {
      return players.firstWhere((p) => p.userId == currentPlayerId);
    } catch (e) {
      return players.isNotEmpty ? players.first : null;
    }
  }

  bool get isOver => state.gameOver || status != GameStatus.inProgress;

  GamePlayerEntity? get winner {
    if (winnerId == null) return null;
    try {
      return players.firstWhere((p) => p.userId == winnerId);
    } catch (e) {
      return null;
    }
  }

  GameEntity copyWith({
    String? id,
    String? lobbyId,
    GameType? gameType,
    GameStatus? status,
    String? currentPlayerId,
    List<GamePlayerEntity>? players,
    BaseGameStateEntity? state,
    String? winnerId,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return GameEntity(
      id: id ?? this.id,
      lobbyId: lobbyId ?? this.lobbyId,
      gameType: gameType ?? this.gameType,
      status: status ?? this.status,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      players: players ?? this.players,
      state: state ?? this.state,
      winnerId: winnerId ?? this.winnerId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        lobbyId,
        gameType,
        status,
        currentPlayerId,
        players,
        state,
        winnerId,
        startedAt,
        endedAt,
      ];
}


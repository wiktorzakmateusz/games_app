import 'enums.dart';
import 'player.dart';
import 'game_state.dart';

class Game {
  final String id;
  final String lobbyId;
  final GameType gameType;
  final GameStatus status;
  final String currentPlayerId;
  final List<GamePlayer> players;
  final BaseGameState state;
  final String? winnerId;
  final DateTime startedAt;
  final DateTime? endedAt;

  Game({
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

  factory Game.fromJson(Map<String, dynamic> json) {
    final playersData = json['players'] as List? ?? [];
    final players = playersData
        .map((p) => GamePlayer.fromJson(p as Map<String, dynamic>))
        .toList();

    final gameType = GameType.fromString(json['gameType'] as String? ?? 'TIC_TAC_TOE');
    final stateData = json['state'] as Map<String, dynamic>? ?? {};
    final state = BaseGameState.fromJson(gameType, stateData);

    return Game(
      id: json['id'] as String,
      lobbyId: json['lobbyId'] as String,
      gameType: gameType,
      status: GameStatus.fromString(json['status'] as String? ?? 'IN_PROGRESS'),
      currentPlayerId: json['currentPlayerId'] as String,
      players: players,
      state: state,
      winnerId: json['winnerId'] as String?,
      startedAt: _parseDateTime(json['startedAt']),
      endedAt: json['endedAt'] != null 
          ? _parseDateTime(json['endedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lobbyId': lobbyId,
      'gameType': gameType.value,
      'status': status.value,
      'currentPlayerId': currentPlayerId,
      'players': players.map((p) => p.toJson()).toList(),
      'state': state.toJson(),
      'winnerId': winnerId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
    };
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

  bool isPlayerTurn(String userId) => currentPlayerId == userId;

  GamePlayer? get currentPlayer {
    return players.firstWhere(
      (p) => p.userId == currentPlayerId,
      orElse: () => players.first,
    );
  }

  bool get isOver => state.gameOver || status != GameStatus.inProgress;

  GamePlayer? get winner {
    if (winnerId == null) return null;
    return players.firstWhere(
      (p) => p.userId == winnerId,
      orElse: () => players.first,
    );
  }
}


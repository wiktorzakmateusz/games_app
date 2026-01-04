import 'enums.dart';
import 'player.dart';

class Lobby {
  final String id;
  final String name;
  final String ownerId;
  final int maxPlayers;
  final LobbyStatus status;
  final GameType gameType;
  final List<Player> players;
  final String? gameId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lobby({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.maxPlayers,
    required this.status,
    required this.gameType,
    required this.players,
    this.gameId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) {
    final playersData = json['players'] as List? ?? [];
    final players = playersData
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList();

    return Lobby(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      maxPlayers: json['maxPlayers'] as int,
      status: LobbyStatus.fromString(json['status'] as String? ?? 'WAITING'),
      gameType: GameType.fromString(json['gameType'] as String? ?? 'TIC_TAC_TOE'),
      players: players,
      gameId: json['gameId'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'maxPlayers': maxPlayers,
      'status': status.value,
      'gameType': gameType.value,
      'players': players.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    
    if (gameId != null) {
      json['gameId'] = gameId!;
    }
    
    return json;
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

  int get currentPlayerCount => players.length;

  bool get isFull => currentPlayerCount >= maxPlayers;

  bool isOwner(String userId) => ownerId == userId;

  bool hasPlayer(String userId) {
    return players.any((p) => p.userId == userId);
  }

  bool get isWaiting => status == LobbyStatus.waiting;
}


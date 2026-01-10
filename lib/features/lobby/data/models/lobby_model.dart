import '../../../../core/utils/typedefs.dart';
import '../../../../core/shared/enums.dart';
import '../../domain/entities/lobby_entity.dart';
import '../../domain/entities/lobby_player_entity.dart';

class LobbyModel {
  final String id;
  final String name;
  final String ownerId;
  final int maxPlayers;
  final LobbyStatus status;
  final GameType gameType;
  final List<LobbyPlayerEntity> players;
  final String? gameId;
  final DateTime createdAt;
  final DateTime updatedAt;

  LobbyModel({
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

  factory LobbyModel.fromJson(JsonMap json) {
    final playersData = json['players'] as List? ?? [];
    final players = playersData
        .map((p) => LobbyPlayerEntity(
              userId: p['userId'] as String,
              username: p['username'] as String,
              displayName: p['displayName'] as String? ?? p['username'] as String,
              photoURL: p['photoURL'] as String?,
              isReady: p['isReady'] as bool? ?? false,
              joinedAt: _parseDateTime(p['joinedAt']),
            ))
        .toList();

    return LobbyModel(
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

  JsonMap toJson() {
    final json = {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'maxPlayers': maxPlayers,
      'status': status.value,
      'gameType': gameType.value,
      'players': players
          .map((p) => {
                'userId': p.userId,
                'username': p.username,
                'displayName': p.displayName,
                'photoURL': p.photoURL,
                'isReady': p.isReady,
                'joinedAt': p.joinedAt.toIso8601String(),
              })
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    
    if (gameId != null) {
      json['gameId'] = gameId!;
    }
    
    return json;
  }

  LobbyEntity toEntity() {
    return LobbyEntity(
      id: id,
      name: name,
      ownerId: ownerId,
      maxPlayers: maxPlayers,
      status: status,
      gameType: gameType,
      players: players,
      gameId: gameId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory LobbyModel.fromEntity(LobbyEntity entity) {
    return LobbyModel(
      id: entity.id,
      name: entity.name,
      ownerId: entity.ownerId,
      maxPlayers: entity.maxPlayers,
      status: entity.status,
      gameType: entity.gameType,
      players: entity.players,
      gameId: entity.gameId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
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

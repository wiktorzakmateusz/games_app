import 'package:equatable/equatable.dart';
import '../../../../models/enums.dart';
import 'lobby_player_entity.dart';

class LobbyEntity extends Equatable {
  final String id;
  final String name;
  final String ownerId;
  final int maxPlayers;
  final LobbyStatus status;
  final GameType gameType;
  final List<LobbyPlayerEntity> players;
  final String? gameId; // Set when game starts
  final DateTime createdAt;
  final DateTime updatedAt;

  const LobbyEntity({
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

  int get currentPlayerCount => players.length;

  bool get isFull => currentPlayerCount >= maxPlayers;

  bool isOwner(String userId) => ownerId == userId;

  bool hasPlayer(String userId) {
    return players.any((p) => p.userId == userId);
  }

  bool get isWaiting => status == LobbyStatus.waiting;

  bool get allPlayersReady {
    if (players.isEmpty) return false;
    return players.every((p) => p.isReady);
  }

  bool get canStartGame {
    return players.length >= 2 && allPlayersReady && status == LobbyStatus.waiting;
  }

  LobbyPlayerEntity? getPlayer(String userId) {
    try {
      return players.firstWhere((p) => p.userId == userId);
    } catch (e) {
      return null;
    }
  }

  LobbyEntity togglePlayerReady(String userId) {
    final updatedPlayers = players.map((player) {
      if (player.userId == userId) {
        return player.copyWith(isReady: !player.isReady);
      }
      return player;
    }).toList();

    return copyWith(players: updatedPlayers);
  }

  LobbyEntity addPlayer(LobbyPlayerEntity player) {
    if (isFull || hasPlayer(player.userId)) return this;
    
    final updatedPlayers = [...players, player];
    return copyWith(players: updatedPlayers);
  }

  LobbyEntity copyWith({
    String? id,
    String? name,
    String? ownerId,
    int? maxPlayers,
    LobbyStatus? status,
    GameType? gameType,
    List<LobbyPlayerEntity>? players,
    String? gameId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LobbyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      status: status ?? this.status,
      gameType: gameType ?? this.gameType,
      players: players ?? this.players,
      gameId: gameId ?? this.gameId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        ownerId,
        maxPlayers,
        status,
        gameType,
        players,
        gameId,
        createdAt,
        updatedAt,
      ];
}


import 'package:equatable/equatable.dart';

class LobbyPlayerEntity extends Equatable {
  final String userId;
  final String username;
  final String displayName;
  final String? photoURL;
  final bool isReady;
  final DateTime joinedAt;

  const LobbyPlayerEntity({
    required this.userId,
    required this.username,
    required this.displayName,
    this.photoURL,
    required this.isReady,
    required this.joinedAt,
  });

  LobbyPlayerEntity copyWith({
    String? userId,
    String? username,
    String? displayName,
    String? photoURL,
    bool? isReady,
    DateTime? joinedAt,
  }) {
    return LobbyPlayerEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isReady: isReady ?? this.isReady,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        username,
        displayName,
        photoURL,
        isReady,
        joinedAt,
      ];
}


import 'package:equatable/equatable.dart';
import '../../domain/entities/lobby_entity.dart';

sealed class LobbyWaitingState extends Equatable {
  const LobbyWaitingState();

  @override
  List<Object?> get props => [];
}

class LobbyWaitingInitial extends LobbyWaitingState {
  const LobbyWaitingInitial();
}

class LobbyWaitingLoading extends LobbyWaitingState {
  const LobbyWaitingLoading();
}

class LobbyWaitingLoaded extends LobbyWaitingState {
  final LobbyEntity lobby;
  final bool isPerformingAction;

  const LobbyWaitingLoaded(
    this.lobby, {
    this.isPerformingAction = false,
  });

  LobbyWaitingLoaded copyWith({
    LobbyEntity? lobby,
    bool? isPerformingAction,
  }) {
    return LobbyWaitingLoaded(
      lobby ?? this.lobby,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
    );
  }

  @override
  List<Object?> get props => [lobby, isPerformingAction];
}

class LobbyWaitingError extends LobbyWaitingState {
  final String message;
  final LobbyEntity? previousLobby;

  const LobbyWaitingError(this.message, {this.previousLobby});

  @override
  List<Object?> get props => [message, previousLobby];
}

class LobbyLeft extends LobbyWaitingState {
  const LobbyLeft();
}

class GameStarting extends LobbyWaitingState {
  const GameStarting();
}

class GameStarted extends LobbyWaitingState {
  final String gameId;

  const GameStarted(this.gameId);

  @override
  List<Object?> get props => [gameId];
}


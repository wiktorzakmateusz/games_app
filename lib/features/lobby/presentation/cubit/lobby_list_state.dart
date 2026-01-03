import 'package:equatable/equatable.dart';
import '../../domain/entities/lobby_entity.dart';

sealed class LobbyListState extends Equatable {
  const LobbyListState();

  @override
  List<Object?> get props => [];
}

class LobbyListInitial extends LobbyListState {
  const LobbyListInitial();
}

class LobbyListLoading extends LobbyListState {
  const LobbyListLoading();
}

class LobbyListLoaded extends LobbyListState {
  final List<LobbyEntity> lobbies;
  final bool isPerformingAction;

  const LobbyListLoaded(
    this.lobbies, {
    this.isPerformingAction = false,
  });

  LobbyListLoaded copyWith({
    List<LobbyEntity>? lobbies,
    bool? isPerformingAction,
  }) {
    return LobbyListLoaded(
      lobbies ?? this.lobbies,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
    );
  }

  @override
  List<Object?> get props => [lobbies, isPerformingAction];
}

class LobbyListError extends LobbyListState {
  final String message;

  const LobbyListError(this.message);

  @override
  List<Object?> get props => [message];
}

class LobbyCreated extends LobbyListState {
  final LobbyEntity lobby;

  const LobbyCreated(this.lobby);

  @override
  List<Object?> get props => [lobby];
}

class LobbyJoined extends LobbyListState {
  final String lobbyId;

  const LobbyJoined(this.lobbyId);

  @override
  List<Object?> get props => [lobbyId];
}


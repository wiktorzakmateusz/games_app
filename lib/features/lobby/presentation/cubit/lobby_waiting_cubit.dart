import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/enums.dart';
import '../../../game/domain/usecases/start_game_usecase.dart';
import '../../domain/usecases/leave_lobby_usecase.dart';
import '../../domain/usecases/toggle_ready_usecase.dart';
import '../../domain/usecases/update_game_type_usecase.dart';
import '../../domain/usecases/watch_lobby_usecase.dart';
import 'lobby_waiting_state.dart';

class LobbyWaitingCubit extends Cubit<LobbyWaitingState> {
  final WatchLobbyUseCase watchLobbyUseCase;
  final LeaveLobbyUseCase leaveLobbyUseCase;
  final ToggleReadyUseCase toggleReadyUseCase;
  final UpdateGameTypeUseCase updateGameTypeUseCase;
  final StartGameUseCase startGameUseCase;

  StreamSubscription? _lobbySubscription;
  String? _currentLobbyId;
  String? _currentUserId;
  bool _isLeaving = false;

  LobbyWaitingCubit({
    required this.watchLobbyUseCase,
    required this.leaveLobbyUseCase,
    required this.toggleReadyUseCase,
    required this.updateGameTypeUseCase,
    required this.startGameUseCase,
  }) : super(const LobbyWaitingInitial());

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  void watchLobby(String lobbyId) {
    if (_currentLobbyId == lobbyId && state is LobbyWaitingLoaded) {
      return;
    }

    _currentLobbyId = lobbyId;
    emit(const LobbyWaitingLoading());

    _lobbySubscription?.cancel();
      _lobbySubscription = watchLobbyUseCase(lobbyId).listen(
          (lobby) {
            if (lobby.status == LobbyStatus.inGame && lobby.gameId != null) {
              // Game started, navigate immediately with gameId from lobby
              emit(GameStarted(lobby.gameId!));
              return;
            }
            
            // Show starting state if status is IN_GAME but gameId not yet available
            if (lobby.status == LobbyStatus.inGame && lobby.gameId == null) {
              emit(const GameStarting());
              return;
            }

          // Always update the lobby from Firestore
          if (state is LobbyWaitingLoaded && (state as LobbyWaitingLoaded).isPerformingAction) {
            final previousLobby = (state as LobbyWaitingLoaded).lobby;
            // If gameType changed, reset loading
            if (previousLobby.gameType != lobby.gameType) {
              emit(LobbyWaitingLoaded(lobby, isPerformingAction: false));
            } else {
              emit(LobbyWaitingLoaded(lobby, isPerformingAction: true));
            }
          } else {
            emit(LobbyWaitingLoaded(lobby));
          }
        },
      onError: (error) {
        // Don't emit error if we're leaving (stream was cancelled)
        if (!_isLeaving) {
          emit(LobbyWaitingError(
            'Failed to load lobby: $error',
            previousLobby: state is LobbyWaitingLoaded
                ? (state as LobbyWaitingLoaded).lobby
                : null,
          ));
        }
      },
    );
  }

  Future<void> toggleReady() async {
    final currentState = state;
    if (currentState is! LobbyWaitingLoaded) return;
    if (_currentUserId == null || _currentLobbyId == null) return;

    final lobby = currentState.lobby;

    final optimisticLobby = lobby.togglePlayerReady(_currentUserId!);

    emit(LobbyWaitingLoaded(optimisticLobby, isPerformingAction: true));

    final result = await toggleReadyUseCase(_currentLobbyId!);

    result.fold(
      (failure) {
        emit(LobbyWaitingLoaded(lobby, isPerformingAction: false));
        emit(LobbyWaitingError(
          failure.message,
          previousLobby: lobby,
        ));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (state is LobbyWaitingError) {
            emit(LobbyWaitingLoaded(lobby));
          }
        });
      },
      (_) {
        if (state is LobbyWaitingLoaded) {
          emit((state as LobbyWaitingLoaded).copyWith(isPerformingAction: false));
        }
      },
    );
  }

  Future<void> leaveLobby() async {
    final currentState = state;
    if (currentState is! LobbyWaitingLoaded) return;
    if (_currentLobbyId == null) return;

    final lobby = currentState.lobby;

    _isLeaving = true;
    _lobbySubscription?.cancel();
    _lobbySubscription = null;

    emit(LobbyWaitingLoaded(lobby, isPerformingAction: true));

    final result = await leaveLobbyUseCase(_currentLobbyId!);

    result.fold(
      (failure) {
        _isLeaving = false;
        if (_currentLobbyId != null) {
          watchLobby(_currentLobbyId!);
        }
        emit(LobbyWaitingLoaded(lobby, isPerformingAction: false));
        emit(LobbyWaitingError(
          failure.message,
          previousLobby: lobby,
        ));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (state is LobbyWaitingError) {
            emit(LobbyWaitingLoaded(lobby));
          }
        });
      },
      (_) {
        emit(const LobbyLeft());
      },
    );
  }

  Future<void> startGame() async {
    final currentState = state;
    if (currentState is! LobbyWaitingLoaded) return;
    if (_currentLobbyId == null) return;

    final lobby = currentState.lobby;

    emit(LobbyWaitingLoaded(lobby, isPerformingAction: true));

    final result = await startGameUseCase(_currentLobbyId!);

    result.fold(
      (failure) {
        emit(LobbyWaitingLoaded(lobby, isPerformingAction: false));
        emit(LobbyWaitingError(
          failure.message,
          previousLobby: lobby,
        ));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (state is LobbyWaitingError) {
            emit(LobbyWaitingLoaded(lobby));
          }
        });
      },
      (game) {
        emit(GameStarted(game.id));
      },
    );
  }

  Future<void> updateGameType(GameType gameType) async {
    final currentState = state;
    if (currentState is! LobbyWaitingLoaded) return;
    if (_currentLobbyId == null) return;

    final lobby = currentState.lobby;

    emit(LobbyWaitingLoaded(lobby, isPerformingAction: true));

    final result = await updateGameTypeUseCase(_currentLobbyId!, gameType);

    result.fold(
      (failure) {
        // On error, reset loading state and show error
        emit(LobbyWaitingLoaded(lobby, isPerformingAction: false));
        emit(LobbyWaitingError(
          failure.message,
          previousLobby: lobby,
        ));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (state is LobbyWaitingError) {
            emit(LobbyWaitingLoaded(lobby));
          }
        });
      },
      (_) {
        // On success, set a flag to reset loading when we see the expected gameType
        // The Firestore stream will emit the updated lobby soon
      },
    );
  }

  void retry() {
    if (_currentLobbyId != null) {
      watchLobby(_currentLobbyId!);
    }
  }

  @override
  Future<void> close() {
    _lobbySubscription?.cancel();
    return super.close();
  }
}


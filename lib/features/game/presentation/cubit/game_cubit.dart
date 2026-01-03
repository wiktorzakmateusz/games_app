import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../domain/usecases/abandon_game_usecase.dart';
import '../../domain/usecases/make_move_usecase.dart';
import '../../domain/usecases/watch_game_usecase.dart';
import 'game_state.dart';

/// Cubit for managing game state with optimistic updates
class GameCubit extends Cubit<GameState> {
  final WatchGameUseCase watchGameUseCase;
  final MakeMoveUseCase makeMoveUseCase;
  final AbandonGameUseCase abandonGameUseCase;

  StreamSubscription<GameEntity>? _gameSubscription;
  String? _currentGameId;
  String? _currentUserId;

  GameCubit({
    required this.watchGameUseCase,
    required this.makeMoveUseCase,
    required this.abandonGameUseCase,
  }) : super(const GameInitial());

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> watchGame(String gameId) async {
    if (_currentGameId == gameId && state is GameLoaded) {
      return; // Already watching this game
    }

    _currentGameId = gameId;
    emit(const GameLoading());

    // Cancel previous subscription
    await _gameSubscription?.cancel();

    try {
      _gameSubscription = watchGameUseCase(gameId).listen(
        (game) {
          if (state is! GameLoaded ||
              !(state as GameLoaded).isPerformingAction) {
            emit(GameLoaded(game));
          } else {
            emit(GameLoaded(game, isPerformingAction: true));
          }
        },
        onError: (error) {
          emit(GameError(
            'Failed to load game: $error',
            previousGame: state is GameLoaded ? (state as GameLoaded).game : null,
          ));
        },
      );
    } catch (e) {
      emit(GameError('Failed to watch game: $e'));
    }
  }

  Future<void> makeMove(int position) async {
    final currentState = state;
    if (currentState is! GameLoaded) return;

    final game = currentState.game;

    if (game.isOver) return;
    if (_currentUserId == null) return;
    if (!game.isPlayerTurn(_currentUserId!)) return;

    final gameState = game.state;
    if (gameState is! TicTacToeGameStateEntity) return;
    if (!gameState.isEmpty(position)) return;

    final currentPlayer = game.currentPlayer;
    if (currentPlayer == null || currentPlayer.symbol == null) return;

    final optimisticGameState = gameState.makeOptimisticMove(
      position,
      currentPlayer.symbol!,
    );

    final nextPlayerId = game.players
        .firstWhere((p) => p.userId != game.currentPlayerId)
        .userId;

    final optimisticGame = game.copyWith(
      state: optimisticGameState,
      currentPlayerId: nextPlayerId,
    );

    emit(GameLoaded(optimisticGame, isPerformingAction: true));

    final result = await makeMoveUseCase(
      gameId: game.id,
      position: position,
    );

    result.fold(
      (failure) {
        // Rollback to previous state on error
        emit(GameLoaded(game, isPerformingAction: false));
        emit(GameError(
          failure.message,
          previousGame: game,
        ));
        // Return to loaded state after showing error
        Future.delayed(const Duration(milliseconds: 100), () {
          if (state is GameError) {
            emit(GameLoaded(game));
          }
        });
      },
      (_) {
        // Success - Firestore stream will update with real state
        // Just clear the action flag
        if (state is GameLoaded) {
          emit((state as GameLoaded).copyWith(isPerformingAction: false));
        }
      },
    );
  }

  Future<void> abandonGame() async {
    final currentState = state;
    if (currentState is! GameLoaded) return;

    final game = currentState.game;

    // Show loading state
    emit(GameLoaded(game, isPerformingAction: true));

    final result = await abandonGameUseCase(game.id);

    result.fold(
      (failure) {
        emit(GameError(
          failure.message,
          previousGame: game,
        ));
        // Return to loaded state
        Future.delayed(const Duration(milliseconds: 100), () {
          if (state is GameError) {
            emit(GameLoaded(game));
          }
        });
      },
      (_) {
        emit(const GameAbandoned());
      },
    );
  }

  void retry() {
    if (_currentGameId != null) {
      watchGame(_currentGameId!);
    }
  }

  @override
  Future<void> close() {
    _gameSubscription?.cancel();
    return super.close();
  }
}


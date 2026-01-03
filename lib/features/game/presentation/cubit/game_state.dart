import 'package:equatable/equatable.dart';
import '../../domain/entities/game_entity.dart';

sealed class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {
  const GameInitial();
}

class GameLoading extends GameState {
  const GameLoading();
}

class GameLoaded extends GameState {
  final GameEntity game;
  final bool isPerformingAction;

  const GameLoaded(
    this.game, {
    this.isPerformingAction = false,
  });

  GameLoaded copyWith({
    GameEntity? game,
    bool? isPerformingAction,
  }) {
    return GameLoaded(
      game ?? this.game,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
    );
  }

  @override
  List<Object?> get props => [game, isPerformingAction];
}

class GameError extends GameState {
  final String message;
  final GameEntity? previousGame; // Keep previous game for retry

  const GameError(this.message, {this.previousGame});

  @override
  List<Object?> get props => [message, previousGame];
}

class GameAbandoned extends GameState {
  const GameAbandoned();
}


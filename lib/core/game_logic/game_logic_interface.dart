library;

import 'game_state.dart';
import 'game_types.dart';

abstract class GameLogic<TState extends GameState, TMove> {
  GameType get gameType;

  TState createInitialState({
    required PlayerSymbol startingPlayer,
  });

  bool isValidMove(TState state, TMove move);

  TState applyMove(TState state, TMove move);

  WinCheckResult checkWinner(TState state);

  PlayerSymbol getNextPlayer(PlayerSymbol currentPlayer);

  List<TMove> getValidMoves(TState state);
}

abstract class AIGameLogic<TState extends GameState, TMove>
    extends GameLogic<TState, TMove> {
  TMove getAIMove({
    required TState state,
    required GameDifficulty difficulty,
    required PlayerSymbol aiPlayer,
  });
}


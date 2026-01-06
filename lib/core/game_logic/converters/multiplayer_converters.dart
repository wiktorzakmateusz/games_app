library;

import '../../shared/enums.dart' as shared;
import '../../../features/game/domain/entities/game_state_entity.dart';
import '../game_logic.dart';

String playerSymbolToString(PlayerSymbol symbol) {
  return symbol.symbol;
}

PlayerSymbol? stringToPlayerSymbol(String? str) {
  if (str == null || str.isEmpty) return null;
  return str.toUpperCase() == 'X' ? PlayerSymbol.x : PlayerSymbol.o;
}

shared.GameType gameTypeToShared(GameType type) {
  switch (type) {
    case GameType.ticTacToe:
      return shared.GameType.ticTacToe;
    case GameType.connect4:
      return shared.GameType.connect4;
    default:
      throw ArgumentError('Unsupported game type: $type');
  }
}

GameType sharedToGameType(shared.GameType type) {
  switch (type) {
    case shared.GameType.ticTacToe:
      return GameType.ticTacToe;
    case shared.GameType.connect4:
      return GameType.connect4;
    default:
      throw ArgumentError('Unsupported game type: $type');
  }
}

TicTacToeGameStateEntity ticTacToeStateToEntity(TicTacToeState state) {
  final board = state.board.map((symbol) => symbol?.symbol).toList();

  return TicTacToeGameStateEntity(
    board: board,
    gameOver: state.isGameOver,
    winner: state.winnerSymbol?.symbol,
    isDraw: state.isDraw,
  );
}

TicTacToeState ticTacToeEntityToState(TicTacToeGameStateEntity entity) {
  final board = entity.board
      .map((str) => stringToPlayerSymbol(str))
      .toList();

  final moveCount = board.where((s) => s != null).length;
  final currentPlayer = moveCount % 2 == 0 ? PlayerSymbol.x : PlayerSymbol.o;

  GameResult result;
  if (entity.gameOver) {
    result = entity.isDraw ? GameResult.draw : GameResult.win;
  } else {
    result = GameResult.ongoing;
  }

  return TicTacToeState(
    board: board,
    isGameOver: entity.gameOver,
    result: result,
    winnerSymbol: stringToPlayerSymbol(entity.winner),
    currentPlayerSymbol: entity.gameOver ? null : currentPlayer,
    winningPattern: entity.getWinningPattern(),
  );
}

Connect4GameStateEntity connect4StateToEntity(Connect4State state) {
  final board = state.board.map((symbol) => symbol?.symbol).toList();

  return Connect4GameStateEntity(
    board: board,
    gameOver: state.isGameOver,
    winner: state.winnerSymbol?.symbol,
    isDraw: state.isDraw,
  );
}

Connect4State connect4EntityToState(Connect4GameStateEntity entity) {
  final board = entity.board
      .map((str) => stringToPlayerSymbol(str))
      .toList();

  final moveCount = board.where((s) => s != null).length;
  final currentPlayer = moveCount % 2 == 0 ? PlayerSymbol.x : PlayerSymbol.o;

  GameResult result;
  if (entity.gameOver) {
    result = entity.isDraw ? GameResult.draw : GameResult.win;
  } else {
    result = GameResult.ongoing;
  }

  return Connect4State(
    board: board,
    isGameOver: entity.gameOver,
    result: result,
    winnerSymbol: stringToPlayerSymbol(entity.winner),
    currentPlayerSymbol: entity.gameOver ? null : currentPlayer,
    winningPattern: entity.getWinningPattern(),
  );
}

TicTacToeGameStateEntity applyTicTacToeMoveOptimistically({
  required TicTacToeGameStateEntity currentEntity,
  required int position,
  required String playerSymbol,
}) {
  final state = ticTacToeEntityToState(currentEntity);
  final logic = TicTacToeLogic();

  final move = TicTacToeMove(position);
  final symbol = stringToPlayerSymbol(playerSymbol);

  if (symbol == null || !logic.isValidMove(state, move)) {
    return currentEntity;
  }

  final newState = logic.applyMove(state, move);

  return ticTacToeStateToEntity(newState);
}

Connect4GameStateEntity applyConnect4MoveOptimistically({
  required Connect4GameStateEntity currentEntity,
  required int column,
  required String playerSymbol,
}) {
  final state = connect4EntityToState(currentEntity);
  final logic = Connect4Logic();

  final move = Connect4Move(column);
  final symbol = stringToPlayerSymbol(playerSymbol);

  if (symbol == null || !logic.isValidMove(state, move)) {
    return currentEntity;
  }

  final newState = logic.applyMove(state, move);

  return connect4StateToEntity(newState);
}


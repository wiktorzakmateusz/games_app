library;

import 'dart:math' as math;
import '../game_logic_interface.dart';
import '../game_state.dart';
import '../game_types.dart';
import 'connect4_state.dart';

class Connect4Logic extends AIGameLogic<Connect4State, Connect4Move> {
  @override
  GameType get gameType => GameType.connect4;

  @override
  Connect4State createInitialState({
    required PlayerSymbol startingPlayer,
  }) {
    return Connect4State.initial(startingPlayer: startingPlayer);
  }

  @override
  bool isValidMove(Connect4State state, Connect4Move move) {
    if (state.isGameOver) return false;

    if (move.column < 0 || move.column >= Connect4State.columns) return false;

    return !state.isColumnFull(move.column);
  }

  @override
  Connect4State applyMove(Connect4State state, Connect4Move move) {
    if (!isValidMove(state, move)) {
      throw ArgumentError('Invalid move: $move');
    }

    final currentPlayer = state.currentPlayerSymbol!;
    final row = state.getDropRow(move.column);

    if (row == -1) {
      throw ArgumentError('Column ${move.column} is full');
    }

    final newBoard = List<PlayerSymbol?>.from(state.board);
    final index = row * Connect4State.columns + move.column;
    newBoard[index] = currentPlayer;

    final winCheck = _checkWinnerFromBoard(newBoard);

    final isFull = !newBoard.contains(null);
    final isDraw = !winCheck.hasWinner && isFull;

    GameResult result = GameResult.ongoing;
    if (winCheck.hasWinner) {
      result = GameResult.win;
    } else if (isDraw) {
      result = GameResult.draw;
    }

    final nextPlayer =
        (winCheck.hasWinner || isDraw) ? null : getNextPlayer(currentPlayer);

    return Connect4State(
      board: newBoard,
      isGameOver: winCheck.hasWinner || isDraw,
      result: result,
      winnerSymbol: winCheck.winner,
      currentPlayerSymbol: nextPlayer,
      winningPattern: winCheck.winningPattern,
    );
  }

  @override
  WinCheckResult checkWinner(Connect4State state) {
    return _checkWinnerFromBoard(state.board);
  }

  WinCheckResult _checkWinnerFromBoard(List<PlayerSymbol?> board) {
    for (int row = 0; row < Connect4State.rows; row++) {
      for (int col = 0; col < Connect4State.columns; col++) {
        final index = row * Connect4State.columns + col;
        final symbol = board[index];
        if (symbol == null) continue;

        if (col <= Connect4State.columns - 4) {
          final pattern = [index, index + 1, index + 2, index + 3];
          if (_checkPattern(board, pattern, symbol)) {
            return WinCheckResult(
              hasWinner: true,
              winner: symbol,
              winningPattern: pattern,
            );
          }
        }

        if (row <= Connect4State.rows - 4) {
          final pattern = [
            index,
            index + Connect4State.columns,
            index + 2 * Connect4State.columns,
            index + 3 * Connect4State.columns,
          ];
          if (_checkPattern(board, pattern, symbol)) {
            return WinCheckResult(
              hasWinner: true,
              winner: symbol,
              winningPattern: pattern,
            );
          }
        }

        if (col <= Connect4State.columns - 4 &&
            row <= Connect4State.rows - 4) {
          final pattern = [
            index,
            index + Connect4State.columns + 1,
            index + 2 * (Connect4State.columns + 1),
            index + 3 * (Connect4State.columns + 1),
          ];
          if (_checkPattern(board, pattern, symbol)) {
            return WinCheckResult(
              hasWinner: true,
              winner: symbol,
              winningPattern: pattern,
            );
          }
        }

        if (col >= 3 && row <= Connect4State.rows - 4) {
          final pattern = [
            index,
            index + Connect4State.columns - 1,
            index + 2 * (Connect4State.columns - 1),
            index + 3 * (Connect4State.columns - 1),
          ];
          if (_checkPattern(board, pattern, symbol)) {
            return WinCheckResult(
              hasWinner: true,
              winner: symbol,
              winningPattern: pattern,
            );
          }
        }
      }
    }

    return WinCheckResult.noWinner;
  }

  bool _checkPattern(
      List<PlayerSymbol?> board, List<int> pattern, PlayerSymbol symbol) {
    return pattern.every((idx) =>
        idx >= 0 && idx < Connect4State.totalCells && board[idx] == symbol);
  }

  @override
  PlayerSymbol getNextPlayer(PlayerSymbol currentPlayer) {
    return currentPlayer.opposite;
  }

  @override
  List<Connect4Move> getValidMoves(Connect4State state) {
    if (state.isGameOver) return [];

    final validMoves = <Connect4Move>[];
    for (int col = 0; col < Connect4State.columns; col++) {
      if (!state.isColumnFull(col)) {
        validMoves.add(Connect4Move(col));
      }
    }
    return validMoves;
  }

  @override
  Connect4Move getAIMove({
    required Connect4State state,
    required GameDifficulty difficulty,
    required PlayerSymbol aiPlayer,
  }) {
    final opponentPlayer = aiPlayer.opposite;

    if (difficulty != GameDifficulty.easy) {
      final winMove = _findWinningMove(state, aiPlayer);
      if (winMove != null) return winMove;

      final blockMove = _findWinningMove(state, opponentPlayer);
      if (blockMove != null) return blockMove;
    }

    switch (difficulty) {
      case GameDifficulty.easy:
        return _getRandomMove(state);
      case GameDifficulty.medium:
        final playStrategic = math.Random().nextDouble() < 0.7;
        return playStrategic
            ? _getBestMove(state, aiPlayer)
            : _getRandomMove(state);
      case GameDifficulty.hard:
        return _getBestMove(state, aiPlayer);
    }
  }

  Connect4Move? _findWinningMove(Connect4State state, PlayerSymbol player) {
    for (final move in getValidMoves(state)) {
      final row = state.getDropRow(move.column);
      if (row == -1) continue;

      final index = row * Connect4State.columns + move.column;
      final testBoard = List<PlayerSymbol?>.from(state.board);
      testBoard[index] = player;

      final result = _checkWinnerFromBoard(testBoard);
      if (result.hasWinner && result.winner == player) {
        return move;
      }
    }
    return null;
  }

  Connect4Move _getRandomMove(Connect4State state) {
    final validMoves = getValidMoves(state);
    if (validMoves.isEmpty) {
      throw StateError('No valid moves available');
    }
    validMoves.shuffle();
    return validMoves.first;
  }

  /// Get the best move using minimax with alpha-beta pruning
  Connect4Move _getBestMove(Connect4State state, PlayerSymbol aiPlayer) {
    int bestScore = -100000;
    Connect4Move? bestMove;

    final validMoves = getValidMoves(state);

    for (final move in validMoves) {
      final newState = applyMove(state, move);

      // Evaluate move with limited depth for performance
      final score = _minimax(
        newState,
        0,
        false,
        aiPlayer,
        aiPlayer.opposite,
        -100000, // alpha
        100000, // beta
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? _getRandomMove(state);
  }

  /// Minimax algorithm with alpha-beta pruning
  int _minimax(
    Connect4State state,
    int depth,
    bool isMaximizing,
    PlayerSymbol aiPlayer,
    PlayerSymbol humanPlayer,
    int alpha,
    int beta,
  ) {
    // Check terminal states
    if (state.isGameOver) {
      if (state.winnerSymbol == aiPlayer) {
        return 10000 - depth;
      } else if (state.winnerSymbol == humanPlayer) {
        return depth - 10000;
      } else {
        return 0; // Draw
      }
    }

    // Limit depth for performance (Connect4 has more complexity than TicTacToe)
    if (depth >= 5) {
      return _evaluatePosition(state, aiPlayer, humanPlayer);
    }

    if (isMaximizing) {
      int maxScore = -100000;
      final validMoves = getValidMoves(state);

      for (final move in validMoves) {
        final newState = applyMove(state, move);
        final score =
            _minimax(newState, depth + 1, false, aiPlayer, humanPlayer, alpha, beta);

        maxScore = math.max(score, maxScore);
        alpha = math.max(alpha, score);
        if (beta <= alpha) break; // Beta cutoff
      }

      return maxScore;
    } else {
      int minScore = 100000;
      final validMoves = getValidMoves(state);

      for (final move in validMoves) {
        final newState = applyMove(state, move);
        final score =
            _minimax(newState, depth + 1, true, aiPlayer, humanPlayer, alpha, beta);

        minScore = math.min(score, minScore);
        beta = math.min(beta, score);
        if (beta <= alpha) break; // Alpha cutoff
      }

      return minScore;
    }
  }

  /// Evaluate a board position heuristically
  int _evaluatePosition(
      Connect4State state, PlayerSymbol aiPlayer, PlayerSymbol humanPlayer) {
    int score = 0;

    // Center column preference (important in Connect 4 strategy)
    for (int row = 0; row < Connect4State.rows; row++) {
      final index = row * Connect4State.columns + 3;
      if (state.board[index] == aiPlayer) {
        score += 3;
      }
    }

    // Evaluate all possible windows of 4
    score += _scoreAllWindows(state, aiPlayer, humanPlayer);

    return score;
  }

  /// Score all possible 4-cell windows
  int _scoreAllWindows(
      Connect4State state, PlayerSymbol aiPlayer, PlayerSymbol humanPlayer) {
    int score = 0;

    // Horizontal windows
    for (int row = 0; row < Connect4State.rows; row++) {
      for (int col = 0; col < Connect4State.columns - 3; col++) {
        final window = [
          state.board[row * Connect4State.columns + col],
          state.board[row * Connect4State.columns + col + 1],
          state.board[row * Connect4State.columns + col + 2],
          state.board[row * Connect4State.columns + col + 3],
        ];
        score += _evaluateWindow(window, aiPlayer, humanPlayer);
      }
    }

    // Vertical windows
    for (int col = 0; col < Connect4State.columns; col++) {
      for (int row = 0; row < Connect4State.rows - 3; row++) {
        final window = [
          state.board[row * Connect4State.columns + col],
          state.board[(row + 1) * Connect4State.columns + col],
          state.board[(row + 2) * Connect4State.columns + col],
          state.board[(row + 3) * Connect4State.columns + col],
        ];
        score += _evaluateWindow(window, aiPlayer, humanPlayer);
      }
    }

    // Diagonal windows (down-right)
    for (int row = 0; row < Connect4State.rows - 3; row++) {
      for (int col = 0; col < Connect4State.columns - 3; col++) {
        final window = [
          state.board[row * Connect4State.columns + col],
          state.board[(row + 1) * Connect4State.columns + col + 1],
          state.board[(row + 2) * Connect4State.columns + col + 2],
          state.board[(row + 3) * Connect4State.columns + col + 3],
        ];
        score += _evaluateWindow(window, aiPlayer, humanPlayer);
      }
    }

    // Diagonal windows (down-left)
    for (int row = 0; row < Connect4State.rows - 3; row++) {
      for (int col = 3; col < Connect4State.columns; col++) {
        final window = [
          state.board[row * Connect4State.columns + col],
          state.board[(row + 1) * Connect4State.columns + col - 1],
          state.board[(row + 2) * Connect4State.columns + col - 2],
          state.board[(row + 3) * Connect4State.columns + col - 3],
        ];
        score += _evaluateWindow(window, aiPlayer, humanPlayer);
      }
    }

    return score;
  }

  /// Evaluate a window of 4 cells
  int _evaluateWindow(
      List<PlayerSymbol?> window, PlayerSymbol aiPlayer, PlayerSymbol humanPlayer) {
    int score = 0;

    final aiCount = window.where((cell) => cell == aiPlayer).length;
    final humanCount = window.where((cell) => cell == humanPlayer).length;
    final emptyCount = window.where((cell) => cell == null).length;

    // AI scoring
    if (aiCount == 4) {
      score += 100;
    } else if (aiCount == 3 && emptyCount == 1) {
      score += 5;
    } else if (aiCount == 2 && emptyCount == 2) {
      score += 2;
    }

    // Opponent penalty
    if (humanCount == 3 && emptyCount == 1) {
      score -= 4;
    }

    return score;
  }
}


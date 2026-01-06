library;

import 'dart:math' as math;
import '../game_logic_interface.dart';
import '../game_state.dart';
import '../game_types.dart';
import 'tic_tac_toe_state.dart';

class TicTacToeLogic extends AIGameLogic<TicTacToeState, TicTacToeMove> {
  @override
  GameType get gameType => GameType.ticTacToe;

  static const List<List<int>> _winPatterns = [
    [0, 1, 2], // Top row
    [3, 4, 5], // Middle row
    [6, 7, 8], // Bottom row
    [0, 3, 6], // Left column
    [1, 4, 7], // Middle column
    [2, 5, 8], // Right column
    [0, 4, 8], // Diagonal top-left to bottom-right
    [2, 4, 6], // Diagonal top-right to bottom-left
  ];

  @override
  TicTacToeState createInitialState({
    required PlayerSymbol startingPlayer,
  }) {
    return TicTacToeState.initial(startingPlayer: startingPlayer);
  }

  @override
  bool isValidMove(TicTacToeState state, TicTacToeMove move) {
    if (state.isGameOver) return false;

    if (move.position < 0 || move.position >= 9) return false;

    return state.isEmpty(move.position);
  }

  @override
  TicTacToeState applyMove(TicTacToeState state, TicTacToeMove move) {
    if (!isValidMove(state, move)) {
      throw ArgumentError('Invalid move: $move');
    }

    final currentPlayer = state.currentPlayerSymbol!;

    final newBoard = List<PlayerSymbol?>.from(state.board);
    newBoard[move.position] = currentPlayer;

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

    return TicTacToeState(
      board: newBoard,
      isGameOver: winCheck.hasWinner || isDraw,
      result: result,
      winnerSymbol: winCheck.winner,
      currentPlayerSymbol: nextPlayer,
      winningPattern: winCheck.winningPattern,
    );
  }

  @override
  WinCheckResult checkWinner(TicTacToeState state) {
    return _checkWinnerFromBoard(state.board);
  }

  WinCheckResult _checkWinnerFromBoard(List<PlayerSymbol?> board) {
    for (final pattern in _winPatterns) {
      final a = pattern[0];
      final b = pattern[1];
      final c = pattern[2];

      if (board[a] != null &&
          board[a] == board[b] &&
          board[a] == board[c]) {
        return WinCheckResult(
          hasWinner: true,
          winner: board[a],
          winningPattern: pattern,
        );
      }
    }

    return WinCheckResult.noWinner;
  }

  @override
  PlayerSymbol getNextPlayer(PlayerSymbol currentPlayer) {
    return currentPlayer.opposite;
  }

  @override
  List<TicTacToeMove> getValidMoves(TicTacToeState state) {
    if (state.isGameOver) return [];

    final validMoves = <TicTacToeMove>[];
    for (int i = 0; i < 9; i++) {
      if (state.isEmpty(i)) {
        validMoves.add(TicTacToeMove(i));
      }
    }
    return validMoves;
  }

  @override
  TicTacToeMove getAIMove({
    required TicTacToeState state,
    required GameDifficulty difficulty,
    required PlayerSymbol aiPlayer,
  }) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return _getRandomMove(state);
      case GameDifficulty.medium:
        // 50% chance to play optimally, 50% random
        final playOptimal = math.Random().nextBool();
        return playOptimal ? _getBestMove(state, aiPlayer) : _getRandomMove(state);
      case GameDifficulty.hard:
        return _getBestMove(state, aiPlayer);
    }
  }

  /// Get a random valid move
  TicTacToeMove _getRandomMove(TicTacToeState state) {
    final validMoves = getValidMoves(state);
    if (validMoves.isEmpty) {
      throw StateError('No valid moves available');
    }
    validMoves.shuffle();
    return validMoves.first;
  }

  /// Get the best move using minimax algorithm
  TicTacToeMove _getBestMove(TicTacToeState state, PlayerSymbol aiPlayer) {
    int bestScore = -1000;
    TicTacToeMove? bestMove;

    final validMoves = getValidMoves(state);
    
    for (final move in validMoves) {
      // Try the move
      final newState = applyMove(state, move);
      
      // Evaluate the move
      final score = _minimax(
        newState,
        0,
        false,
        aiPlayer,
        aiPlayer.opposite,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? _getRandomMove(state);
  }

  /// Minimax algorithm for optimal play
  int _minimax(
    TicTacToeState state,
    int depth,
    bool isMaximizing,
    PlayerSymbol aiPlayer,
    PlayerSymbol humanPlayer,
  ) {
    // Check terminal states
    if (state.isGameOver) {
      if (state.winnerSymbol == aiPlayer) {
        return 10 - depth; // Prefer faster wins
      } else if (state.winnerSymbol == humanPlayer) {
        return depth - 10; // Prefer slower losses
      } else {
        return 0; // Draw
      }
    }

    if (isMaximizing) {
      int maxScore = -1000;
      final validMoves = getValidMoves(state);
      
      for (final move in validMoves) {
        final newState = applyMove(state, move);
        final score = _minimax(newState, depth + 1, false, aiPlayer, humanPlayer);
        maxScore = math.max(score, maxScore);
      }
      
      return maxScore;
    } else {
      int minScore = 1000;
      final validMoves = getValidMoves(state);
      
      for (final move in validMoves) {
        final newState = applyMove(state, move);
        final score = _minimax(newState, depth + 1, true, aiPlayer, humanPlayer);
        minScore = math.min(score, minScore);
      }
      
      return minScore;
    }
  }
}


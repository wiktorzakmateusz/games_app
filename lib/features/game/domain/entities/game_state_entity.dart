import 'package:equatable/equatable.dart';

abstract class BaseGameStateEntity extends Equatable {
  final bool gameOver;
  final String? winner;
  final bool isDraw;

  const BaseGameStateEntity({
    required this.gameOver,
    this.winner,
    required this.isDraw,
  });

  @override
  List<Object?> get props => [gameOver, winner, isDraw];
}

class TicTacToeGameStateEntity extends BaseGameStateEntity {
  final List<String?> board;

  const TicTacToeGameStateEntity({
    required this.board,
    required super.gameOver,
    super.winner,
    required super.isDraw,
  });

  String? getCell(int index) {
    if (index < 0 || index >= 9) return null;
    return board[index];
  }

  bool isEmpty(int index) {
    return getCell(index) == null;
  }

  List<int>? getWinningPattern() {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      final a = pattern[0], b = pattern[1], c = pattern[2];
      if (board[a] != null &&
          board[a] == board[b] &&
          board[a] == board[c]) {
        return pattern;
      }
    }
    return null;
  }

  TicTacToeGameStateEntity makeOptimisticMove(int position, String symbol) {
    if (!isEmpty(position)) return this;

    final newBoard = List<String?>.from(board);
    newBoard[position] = symbol;

    final hasWinner = _checkWinner(newBoard) != null;
    final isFull = !newBoard.contains(null);

    return TicTacToeGameStateEntity(
      board: newBoard,
      gameOver: hasWinner || isFull,
      winner: hasWinner ? symbol : null,
      isDraw: !hasWinner && isFull,
    );
  }

  String? _checkWinner(List<String?> board) {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      final a = pattern[0], b = pattern[1], c = pattern[2];
      if (board[a] != null &&
          board[a] == board[b] &&
          board[a] == board[c]) {
        return board[a];
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [board, gameOver, winner, isDraw];
}

class Connect4GameStateEntity extends BaseGameStateEntity {
  final List<String?> board; // 42 cells (7 columns x 6 rows)

  const Connect4GameStateEntity({
    required this.board,
    required super.gameOver,
    super.winner,
    required super.isDraw,
  });

  String? getCell(int row, int col) {
    if (row < 0 || row >= 6 || col < 0 || col >= 7) return null;
    final index = row * 7 + col;
    if (index < 0 || index >= 42) return null;
    return board[index];
  }

  bool isEmpty(int row, int col) {
    return getCell(row, col) == null;
  }

  /// Get the row where a piece would land in a column (gravity)
  /// Returns -1 if column is full
  int getDropRow(int column) {
    if (column < 0 || column >= 7) return -1;
    // Start from bottom row and go up
    for (int row = 5; row >= 0; row--) {
      final index = row * 7 + column;
      if (board[index] == null) {
        return row;
      }
    }
    return -1; // Column is full
  }

  /// Check if a column is full
  bool isColumnFull(int column) {
    return getDropRow(column) == -1;
  }

  List<int>? getWinningPattern() {
    // Check all possible 4-in-a-row patterns
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 7; col++) {
        final index = row * 7 + col;
        final symbol = board[index];
        if (symbol == null) continue;

        // Check horizontal (right)
        if (col <= 3) {
          final pattern = [index, index + 1, index + 2, index + 3];
          if (_checkPattern(pattern, symbol)) {
            return pattern;
          }
        }

        // Check vertical (down)
        if (row <= 2) {
          final pattern = [
            index,
            index + 7,
            index + 14,
            index + 21,
          ];
          if (_checkPattern(pattern, symbol)) {
            return pattern;
          }
        }

        // Check diagonal (down-right)
        if (col <= 3 && row <= 2) {
          final pattern = [index, index + 8, index + 16, index + 24];
          if (_checkPattern(pattern, symbol)) {
            return pattern;
          }
        }

        // Check diagonal (down-left)
        if (col >= 3 && row <= 2) {
          final pattern = [index, index + 6, index + 12, index + 18];
          if (_checkPattern(pattern, symbol)) {
            return pattern;
          }
        }
      }
    }
    return null;
  }

  bool _checkPattern(List<int> pattern, String? symbol) {
    return pattern.every((idx) => idx >= 0 && idx < 42 && board[idx] == symbol);
  }

  Connect4GameStateEntity makeOptimisticMove(int column, String symbol) {
    final row = getDropRow(column);
    if (row == -1) return this; // Column is full

    final index = row * 7 + column;
    final newBoard = List<String?>.from(board);
    newBoard[index] = symbol;

    final winningPattern = _checkWinner(newBoard);
    final hasWinner = winningPattern != null;
    final isFull = !newBoard.contains(null);

    return Connect4GameStateEntity(
      board: newBoard,
      gameOver: hasWinner || isFull,
      winner: hasWinner ? symbol : null,
      isDraw: !hasWinner && isFull,
    );
  }

  List<int>? _checkWinner(List<String?> board) {
    // Check all possible 4-in-a-row patterns
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 7; col++) {
        final index = row * 7 + col;
        final symbol = board[index];
        if (symbol == null) continue;

        // Check horizontal (right)
        if (col <= 3) {
          final pattern = [index, index + 1, index + 2, index + 3];
          if (_checkPattern(pattern, symbol)) {
            return pattern;
          }
        }

        // Check vertical (down)
        if (row <= 2) {
          final pattern = [index, index + 7, index + 14, index + 21];
          if (_checkPattern(pattern, symbol)) {
            return pattern;
          }
        }

        // Check diagonal (down-right)
        if (col <= 3 && row <= 2) {
          final pattern = [index, index + 8, index + 16, index + 24];
          if (_checkPattern(pattern, symbol)) {
            return pattern;
          }
        }

        // Check diagonal (down-left)
        if (col >= 3 && row <= 2) {
          final pattern = [index, index + 6, index + 12, index + 18];
          if (_checkPattern(pattern, symbol)) {
            return pattern;
          }
        }
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [board, gameOver, winner, isDraw];
}


import 'dart:math' as math;

/// Connect 4 game logic
/// Board: 7 columns x 6 rows (42 cells total)
/// Represented as List<String> where index = row * 7 + col
class Connect4Logic {
  static const int columns = 7;
  static const int rows = 6;
  static const int totalCells = 42;

  bool isColumnFull(List<String> board, int column) {
    // Check top row (row 0) of the column
    return board[column] != '';
  }

  int getDropRow(List<String> board, int column) {
    for (int row = rows - 1; row >= 0; row--) {
      final index = row * columns + column;
      if (board[index] == '') {
        return row;
      }
    }
    return -1;
  }

  int dropPiece(List<String> board, int column, String symbol) {
    final row = getDropRow(board, column);
    if (row == -1) return -1;
    final index = row * columns + column;
    board[index] = symbol;
    return index;
  }

  /// Returns: {'winner': 'X', 'pattern': [indices]} or null
  Map<String, dynamic>? checkWinner(List<String> board) {
    // Check all possible 4-in-a-row patterns
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final index = row * columns + col;
        final symbol = board[index];
        if (symbol == '') continue;

        // Check horizontal (right)
        if (col <= columns - 4) {
          final pattern = [
            index,
            index + 1,
            index + 2,
            index + 3,
          ];
          if (_checkPattern(board, pattern, symbol)) {
            return {'winner': symbol, 'pattern': pattern};
          }
        }

        // Check vertical (down)
        if (row <= rows - 4) {
          final pattern = [
            index,
            index + columns,
            index + 2 * columns,
            index + 3 * columns,
          ];
          if (_checkPattern(board, pattern, symbol)) {
            return {'winner': symbol, 'pattern': pattern};
          }
        }

        // Check diagonal (down-right)
        if (col <= columns - 4 && row <= rows - 4) {
          final pattern = [
            index,
            index + columns + 1,
            index + 2 * (columns + 1),
            index + 3 * (columns + 1),
          ];
          if (_checkPattern(board, pattern, symbol)) {
            return {'winner': symbol, 'pattern': pattern};
          }
        }

        // Check diagonal (down-left)
        if (col >= 3 && row <= rows - 4) {
          final pattern = [
            index,
            index + columns - 1,
            index + 2 * (columns - 1),
            index + 3 * (columns - 1),
          ];
          if (_checkPattern(board, pattern, symbol)) {
            return {'winner': symbol, 'pattern': pattern};
          }
        }
      }
    }

    // Check for draw (board is full)
    if (!board.contains('')) {
      return {'winner': 'draw', 'pattern': null};
    }

    return null;
  }

  bool _checkPattern(List<String> board, List<int> pattern, String symbol) {
    return pattern.every((idx) => board[idx] == symbol);
  }

  int getComputerMove({
    required List<String> board,
    required String difficulty,
    required String currentPlayer,
  }) {
    final opponentSym = currentPlayer == 'X' ? 'O' : 'X';

    if (difficulty != 'Easy') {
      final winMove = _findWinningMove(board, currentPlayer);
      if (winMove != -1) return winMove;

      final blockMove = _findWinningMove(board, opponentSym);
      if (blockMove != -1) return blockMove;
    }

    if (difficulty == 'Easy') {
      return _getRandomMove(board);
    } else if (difficulty == 'Medium') {
      // Medium: 70% strategic, 30% random
      bool playRandomly = math.Random().nextDouble() < 0.3;
      return playRandomly ? _getRandomMove(board) : _getBestMove(board, currentPlayer);
    } else {
      return _getBestMove(board, currentPlayer);
    }
  }

  int _findWinningMove(List<String> board, String symbol) {
    for (int col = 0; col < columns; col++) {
      final row = getDropRow(board, col);
      if (row == -1) continue;

      final index = row * columns + col;
      board[index] = symbol;
      
      final result = checkWinner(board);
      board[index] = '';

      if (result != null && result['winner'] == symbol) {
        return col;
      }
    }
    return -1;
  }

  int _getRandomMove(List<String> board) {
    final validColumns = <int>[];
    for (int col = 0; col < columns; col++) {
      if (getDropRow(board, col) != -1) {
        validColumns.add(col);
      }
    }
    if (validColumns.isEmpty) return -1;
    return (validColumns..shuffle()).first;
  }

  int _getBestMove(List<String> board, String computerSym) {
    int bestScore = -100000;
    int move = -1;
    String opponentSym = computerSym == 'X' ? 'O' : 'X';

    for (int col = 0; col < columns; col++) {
      final row = getDropRow(board, col);
      if (row == -1) continue;

      final index = row * columns + col;
      board[index] = computerSym;

      // Evaluate move with alpha-beta pruning
      int score = _minimax(
        board, 
        0, 
        false, 
        computerSym, 
        opponentSym,
        -100000, // alpha
        100000,  // beta
      );
      
      board[index] = ''; // Undo move

      if (score > bestScore) {
        bestScore = score;
        move = col;
      }
    }

    return move != -1 ? move : _getRandomMove(board);
  }

  /// Minimax algorithm with alpha-beta pruning
  int _minimax(
    List<String> board,
    int depth,
    bool isMaximizing,
    String computerSym,
    String opponentSym,
    int alpha,
    int beta,
  ) {
    final result = checkWinner(board);
    
    if (result != null) {
      if (result['winner'] == computerSym) return 10000 - depth;
      if (result['winner'] == opponentSym) return depth - 10000;
      if (result['winner'] == 'draw') return 0;
    }

    // Limit depth for performance
    if (depth >= 5) return _evaluateBoard(board, computerSym, opponentSym);

    if (isMaximizing) {
      int maxScore = -100000;
      for (int col = 0; col < columns; col++) {
        final row = getDropRow(board, col);
        if (row == -1) continue;

        final index = row * columns + col;
        board[index] = computerSym;
        
        int score = _minimax(board, depth + 1, false, computerSym, opponentSym, alpha, beta);
        board[index] = '';

        maxScore = math.max(score, maxScore);
        alpha = math.max(alpha, score);
        if (beta <= alpha) break; // Beta cutoff
      }
      return maxScore;
    } else {
      int minScore = 100000;
      for (int col = 0; col < columns; col++) {
        final row = getDropRow(board, col);
        if (row == -1) continue;

        final index = row * columns + col;
        board[index] = opponentSym;
        
        int score = _minimax(board, depth + 1, true, computerSym, opponentSym, alpha, beta);
        board[index] = '';

        minScore = math.min(score, minScore);
        beta = math.min(beta, score);
        if (beta <= alpha) break; // Alpha cutoff
      }
      return minScore;
    }
  }

  /// Evaluate board position heuristically
  int _evaluateBoard(List<String> board, String computerSym, String opponentSym) {
    int score = 0;
    
    // Center column preference (important in Connect 4 strategy)
    for (int row = 0; row < rows; row++) {
      if (board[row * columns + 3] == computerSym) {
        score += 3;
      }
    }

    // Evaluate all possible windows of 4
    score += _scorePosition(board, computerSym, opponentSym);
    
    return score;
  }

  /// Score all possible 4-cell windows
  int _scorePosition(List<String> board, String computerSym, String opponentSym) {
    int score = 0;

    // Horizontal
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns - 3; col++) {
        final window = [
          board[row * columns + col],
          board[row * columns + col + 1],
          board[row * columns + col + 2],
          board[row * columns + col + 3],
        ];
        score += _evaluateWindow(window, computerSym, opponentSym);
      }
    }

    // Vertical
    for (int col = 0; col < columns; col++) {
      for (int row = 0; row < rows - 3; row++) {
        final window = [
          board[row * columns + col],
          board[(row + 1) * columns + col],
          board[(row + 2) * columns + col],
          board[(row + 3) * columns + col],
        ];
        score += _evaluateWindow(window, computerSym, opponentSym);
      }
    }

    // Diagonal (down-right)
    for (int row = 0; row < rows - 3; row++) {
      for (int col = 0; col < columns - 3; col++) {
        final window = [
          board[row * columns + col],
          board[(row + 1) * columns + col + 1],
          board[(row + 2) * columns + col + 2],
          board[(row + 3) * columns + col + 3],
        ];
        score += _evaluateWindow(window, computerSym, opponentSym);
      }
    }

    // Diagonal (down-left)
    for (int row = 0; row < rows - 3; row++) {
      for (int col = 3; col < columns; col++) {
        final window = [
          board[row * columns + col],
          board[(row + 1) * columns + col - 1],
          board[(row + 2) * columns + col - 2],
          board[(row + 3) * columns + col - 3],
        ];
        score += _evaluateWindow(window, computerSym, opponentSym);
      }
    }

    return score;
  }

  /// Evaluate a window of 4 cells
  int _evaluateWindow(List<String> window, String computerSym, String opponentSym) {
    int score = 0;
    
    int computerCount = window.where((cell) => cell == computerSym).length;
    int opponentCount = window.where((cell) => cell == opponentSym).length;
    int emptyCount = window.where((cell) => cell == '').length;

    // Computer scoring
    if (computerCount == 4) {
      score += 100;
    } else if (computerCount == 3 && emptyCount == 1) {
      score += 5;
    } else if (computerCount == 2 && emptyCount == 2) {
      score += 2;
    }

    // Opponent penalty
    if (opponentCount == 3 && emptyCount == 1) {
      score -= 4;
    }

    return score;
  }
}
import 'dart:math' as math;

class TicTacToeLogic {
  
  // 1. Logic to check the winner
  // Returns: {'winner': 'X', 'pattern': [0,1,2]} or null
  Map<String, dynamic>? checkWinner(List<String> board) {
    const List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      final a = pattern[0], b = pattern[1], c = pattern[2];
      if (board[a] != '' && board[a] == board[b] && board[a] == board[c]) {
        return {'winner': board[a], 'pattern': pattern};
      }
    }

    if (!board.contains('')) return {'winner': 'draw', 'pattern': null};
    return null;
  }

  // 2. Logic to calculate the best move
  int getComputerMove({
    required List<String> board, 
    required String difficulty, 
    required String currentPlayer
  }) {
    if (difficulty == 'Easy') {
      return _getRandomMove(board);
    } 
    else if (difficulty == 'Medium') {
      bool playRandomly = math.Random().nextBool(); 
      return playRandomly ? _getRandomMove(board) : _getBestMove(board, currentPlayer);
    } 
    else {
      return _getBestMove(board, currentPlayer);
    }
  }

  // Private helpers (Moved from your main file)
  int _getRandomMove(List<String> board) {
    final emptyIndices = [
      for (int i = 0; i < board.length; i++)
        if (board[i] == '') i
    ];
    if (emptyIndices.isEmpty) return -1;
    return (emptyIndices..shuffle()).first;
  }

  int _getBestMove(List<String> board, String computerSym) {
    int bestScore = -1000;
    int move = -1;
    String opponentSym = computerSym == 'X' ? 'O' : 'X';

    // We must work on a COPY of the board to not mess up the UI
    List<String> tempBoard = List.from(board);

    for (int i = 0; i < 9; i++) {
      if (tempBoard[i] == '') {
        tempBoard[i] = computerSym; 
        int score = _minimax(tempBoard, 0, false, computerSym, opponentSym);
        tempBoard[i] = ''; 
        
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }
    return move != -1 ? move : _getRandomMove(board);
  }

  int _minimax(List<String> tempBoard, int depth, bool isMaximizing, String computerSym, String opponentSym) {
    final result = checkWinner(tempBoard); // Reusing the public checkWinner
    if (result != null) {
        if (result['winner'] == computerSym) return 10 - depth;
        if (result['winner'] == opponentSym) return depth - 10;
        if (result['winner'] == 'draw') return 0;
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (tempBoard[i] == '') {
          tempBoard[i] = computerSym;
          int score = _minimax(tempBoard, depth + 1, false, computerSym, opponentSym);
          tempBoard[i] = '';
          bestScore = math.max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (tempBoard[i] == '') {
          tempBoard[i] = opponentSym;
          int score = _minimax(tempBoard, depth + 1, true, computerSym, opponentSym);
          tempBoard[i] = '';
          bestScore = math.min(score, bestScore);
        }
      }
      return bestScore;
    }
  }
}
import 'dart:math';

class SudokuLogic {
  
  /// Generates a full valid 4x4 solution
  List<int> generateSolvedBoard() {
    List<int> tempBoard = List.filled(16, 0);
    _solveBoardRecursively(tempBoard);
    return tempBoard;
  }

  /// Checks if the board is full and matches the solution exactly
  Map<String, dynamic> validateFullBoard(List<int> currentBoard, List<int> solution) {
    Set<int> wrongIndices = {};
    bool isCorrect = true;

    for (int i = 0; i < 16; i++) {
      if (currentBoard[i] != solution[i]) {
        wrongIndices.add(i);
        isCorrect = false;
      }
    }

    return {
      'isCorrect': isCorrect,
      'wrongIndices': wrongIndices,
      'statusText': isCorrect ? 'Well done!' : 'Wrong. Fix red cells.'
    };
  }

  /// Private backtracking solver
  bool _solveBoardRecursively(List<int> b) {
    int emptyIndex = b.indexOf(0);
    if (emptyIndex == -1) return true; // Board full

    List<int> numbers = [1, 2, 3, 4]..shuffle();
    
    for (int num in numbers) {
      if (isValidMove(b, emptyIndex, num)) {
        b[emptyIndex] = num;
        if (_solveBoardRecursively(b)) return true;
        b[emptyIndex] = 0; // Backtrack
      }
    }
    return false;
  }

  /// Checks if placing [value] at [index] is valid
  bool isValidMove(List<int> b, int index, int value) {
    int row = index ~/ 4;
    int col = index % 4;

    // Check Row
    for (int c = 0; c < 4; c++) {
      if (b[row * 4 + c] == value) return false;
    }
    // Check Column
    for (int r = 0; r < 4; r++) {
      if (b[r * 4 + col] == value) return false;
    }
    // Check 2x2 Box
    int startRow = (row ~/ 2) * 2;
    int startCol = (col ~/ 2) * 2;
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 2; c++) {
        if (b[(startRow + r) * 4 + (startCol + c)] == value) return false;
      }
    }
    return true;
  }
}
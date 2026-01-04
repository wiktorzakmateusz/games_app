// test/sudoku_logic_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../lib/logic/mini_sudoku_logic.dart';

void main() {
  late SudokuLogic logic;

  setUp(() {
    logic = SudokuLogic();
  });

  group('Mini Sudoku Rules (4x4)', () {
    test('isValidMove allows valid placement in empty board', () {
      List<int> emptyBoard = List.filled(16, 0);
      // Placing '1' at index 0 (Top-left) should be valid
      expect(logic.isValidMove(emptyBoard, 0, 1), true);
    });

    test('isValidMove detects Row conflict', () {
      List<int> board = List.filled(16, 0);
      // Row 0: [1, 0, 0, 0]
      board[0] = 1; 
      
      // Try placing '1' at index 3 (Same row) -> Should fail
      expect(logic.isValidMove(board, 3, 1), false);
    });

    test('isValidMove detects Column conflict', () {
      List<int> board = List.filled(16, 0);
      // Col 0 has '1' at top
      board[0] = 1; 
      
      // Try placing '1' at index 8 (Two rows down, same column) -> Should fail
      expect(logic.isValidMove(board, 8, 1), false);
    });

    test('isValidMove detects Box conflict (2x2)', () {
      List<int> board = List.filled(16, 0);
      // Top-left box has '1' at index 0
      board[0] = 1; 
      
      // Index 5 is diagonal (Row 1, Col 1), but inside same 2x2 box -> Should fail
      expect(logic.isValidMove(board, 5, 1), false);
    });

    test('generateSolvedBoard returns a full valid board', () {
      final board = logic.generateSolvedBoard();
      
      // 1. Must be full (no zeros)
      expect(board.contains(0), false);
      
      // 2. Must be length 16
      expect(board.length, 16);
      
      // 3. Simple sum check: Sum of 1..4 is 10. 4 rows * 10 = 40.
      int sum = board.reduce((a, b) => a + b);
      expect(sum, 40);
    });
  });

  group('Sudoku Win Validation', () {
    test('Detects correct full board', () {
      List<int> solution = [
        1, 2, 3, 4,
        3, 4, 1, 2,
        2, 1, 4, 3,
        4, 3, 2, 1
      ];
      // User matches solution exactly
      List<int> userBoard = List.from(solution);

      final result = logic.validateFullBoard(userBoard, solution);

      expect(result['isCorrect'], true);
      expect(result['wrongIndices'], isEmpty);
      expect(result['statusText'], 'Well done!');
    });

    test('Detects incorrect cells', () {
      List<int> solution = [
        1, 2, 3, 4,
        3, 4, 1, 2,
        2, 1, 4, 3,
        4, 3, 2, 1
      ];
      
      List<int> userBoard = List.from(solution);
      
      // User makes a mistake at last cell (index 15)
      userBoard[15] = 9; // Wrong number

      final result = logic.validateFullBoard(userBoard, solution);

      expect(result['isCorrect'], false);
      expect((result['wrongIndices'] as Set).contains(15), true); // Index 15 marked wrong
      expect(result['statusText'], contains('Wrong'));
    });
  });
}
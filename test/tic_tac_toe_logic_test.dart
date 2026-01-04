import 'package:flutter_test/flutter_test.dart';
import '../lib/logic/tic_tac_toe_logic.dart'; 

void main() {
  late TicTacToeLogic logic;

  setUp(() {
    logic = TicTacToeLogic();
  });

  group('TicTacToe Winner Checks', () {
    test('Detects Horizontal Win (Row 1)', () {
      List<String> board = [
        'X', 'X', 'X', // Win
        '',  'O', '',
        'O', '',  ''
      ];
      final result = logic.checkWinner(board);
      
      expect(result, isNotNull);
      expect(result!['winner'], 'X');
      expect(result['pattern'], [0, 1, 2]);
    });

    test('Detects Vertical Win (Column 1)', () {
      List<String> board = [
        'O', 'X', '',
        'O', '',  'X',
        'O', '',  ''  // Win
      ];
      final result = logic.checkWinner(board);

      expect(result, isNotNull);
      expect(result!['winner'], 'O');
      expect(result['pattern'], [0, 3, 6]);
    });

    test('Detects Diagonal Win', () {
      List<String> board = [
        'X', 'O', '',
        '',  'X', '',
        'O', '',  'X' // Win
      ];
      final result = logic.checkWinner(board);

      expect(result, isNotNull);
      expect(result!['winner'], 'X');
      expect(result['pattern'], [0, 4, 8]);
    });

    test('Detects Draw correctly', () {
      // A full board with no winner
      List<String> board = [
        'X', 'O', 'X',
        'X', 'O', 'X',
        'O', 'X', 'O'
      ];
      final result = logic.checkWinner(board);

      expect(result, isNotNull);
      expect(result!['winner'], 'draw');
      expect(result['pattern'], null);
    });

    test('Returns null when game is still in progress', () {
      List<String> board = [
        'X', 'O', '',
        '',  '',  '',
        '',  '',  ''
      ];
      final result = logic.checkWinner(board);

      expect(result, isNull);
    });
  });

  group('TicTacToe AI Logic (Minimax)', () {
    test('Hard AI takes the winning move immediately', () {
      // Setup: 'O' has two in a row. It is 'O's turn.
      List<String> board = [
        'O', 'O', '', // Index 2 is the winning spot
        'X', 'X', '',
        '',  '',  ''
      ];
      
      int move = logic.getComputerMove(
        board: board, 
        difficulty: 'Hard', 
        currentPlayer: 'O'
      );
      
      expect(move, 2, reason: 'AI should take the winning spot index 2');
    });

    test('Hard AI blocks the opponent from winning', () {
      // Setup: 'X' is about to win. AI is 'O'. AI must block.
      List<String> board = [
        'X', 'X', '', // Index 2 is the danger zone
        '',  'O', '',
        '',  '',  ''
      ];
      
      int move = logic.getComputerMove(
        board: board, 
        difficulty: 'Hard', 
        currentPlayer: 'O'
      );
      
      expect(move, 2, reason: 'AI must block X at index 2');
    });

    test('AI does not crash on empty board', () {
      List<String> board = List.filled(9, '');
      
      int move = logic.getComputerMove(
        board: board, 
        difficulty: 'Hard', 
        currentPlayer: 'X'
      );
      
      expect(move, inInclusiveRange(0, 8));
    });

    test('Easy AI returns a valid move (Random)', () {
      List<String> board = List.filled(9, '');
      
      int move = logic.getComputerMove(
        board: board, 
        difficulty: 'Easy', 
        currentPlayer: 'X'
      );
      
      expect(move, inInclusiveRange(0, 8));
    });
  });
}
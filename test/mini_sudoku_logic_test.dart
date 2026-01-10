import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/game_logic/mini_sudoku/mini_sudoku_logic.dart';
import 'package:games_app/core/game_logic/mini_sudoku/mini_sudoku_state.dart';
import 'package:games_app/core/game_logic/game_types.dart';

void main() {
  late MiniSudokuLogic logic;

  setUp(() {
    logic = MiniSudokuLogic();
  });

  group('Mini Sudoku Rules (4x4)', () {
    test('isValidMove allows valid placement in empty board', () {
      final state = MiniSudokuState.initial(
        solution: List.filled(16, 1),
        lockedCells: {},
      );
      // Placing '1' at index 0 (Top-left) should be valid
      final move = MiniSudokuMove(position: 0, number: 1);
      expect(logic.isValidMove(state, move), true);
    });

    test('isValidMove detects Row conflict', () {
      final board = List.filled(16, 0);
      // Row 0: [1, 0, 0, 0]
      board[0] = 1;
      final state = MiniSudokuState(
        board: board,
        solution: List.filled(16, 1),
        lockedCells: {},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );

      // Try placing '1' at index 3 (Same row) -> Should fail
      final move = MiniSudokuMove(position: 3, number: 1);
      expect(logic.isValidMove(state, move), false);
    });

    test('isValidMove detects Column conflict', () {
      final board = List.filled(16, 0);
      // Col 0 has '1' at top
      board[0] = 1;
      final state = MiniSudokuState(
        board: board,
        solution: List.filled(16, 1),
        lockedCells: {},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );

      // Try placing '1' at index 8 (Two rows down, same column) -> Should fail
      final move = MiniSudokuMove(position: 8, number: 1);
      expect(logic.isValidMove(state, move), false);
    });

    test('isValidMove detects Box conflict (2x2)', () {
      final board = List.filled(16, 0);
      // Top-left box has '1' at index 0
      board[0] = 1;
      final state = MiniSudokuState(
        board: board,
        solution: List.filled(16, 1),
        lockedCells: {},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );

      // Index 5 is diagonal (Row 1, Col 1), but inside same 2x2 box -> Should fail
      final move = MiniSudokuMove(position: 5, number: 1);
      expect(logic.isValidMove(state, move), false);
    });

    test('createInitialState returns a valid initial state', () {
      final state = logic.createInitialState(
        startingPlayer: PlayerSymbol.x,
      );

      // 1. Must have a solution
      expect(state.solution.length, 16);
      expect(state.solution.contains(0), false);

      // 2. Board must match locked cells from solution
      expect(state.board.length, 16);
    });

    test('createPuzzle returns a valid puzzle state', () {
      final state = logic.createPuzzle(GameDifficulty.medium);

      // Must have a solution
      expect(state.solution.length, 16);
      expect(state.solution.contains(0), false);

      // Board must have some locked cells
      expect(state.lockedCells.isNotEmpty, true);
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

      final result = logic.validateBoard(userBoard, solution);

      expect(result['isCorrect'], true);
      expect((result['wrongIndices'] as Set).isEmpty, true);
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

      final result = logic.validateBoard(userBoard, solution);

      expect(result['isCorrect'], false);
      expect((result['wrongIndices'] as Set).contains(15), true); // Index 15 marked wrong
      expect(result['statusText'], contains('Wrong'));
    });
  });
}

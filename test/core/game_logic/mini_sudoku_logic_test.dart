import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/game_logic/mini_sudoku/mini_sudoku_logic.dart';
import 'package:games_app/core/game_logic/mini_sudoku/mini_sudoku_state.dart';
import 'package:games_app/core/game_logic/game_types.dart';

void main() {
  late MiniSudokuLogic logic;

  setUp(() {
    logic = MiniSudokuLogic();
  });

  group('MiniSudokuLogic - Initial State', () {
    test('should create initial state with valid solution', () {
      // Act
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

      // Assert
      expect(state.solution.length, 16);
      expect(state.solution.contains(0), false, reason: 'Solution should not contain zeros');
      expect(state.solution.every((n) => n >= 1 && n <= 4), true);
    });

    test('should create initial state with some locked cells', () {
      // Act
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

      // Assert
      expect(state.lockedCells.isNotEmpty, true);
      expect(state.board.length, 16);
    });

    test('should create puzzle with different difficulty levels', () {
      // Act
      final easyState = logic.createPuzzle(GameDifficulty.easy);
      final hardState = logic.createPuzzle(GameDifficulty.hard);

      // Assert
      expect(easyState.lockedCells.length, greaterThan(hardState.lockedCells.length),
          reason: 'Easy puzzle should have more locked cells');
    });
  });

  group('MiniSudokuLogic - Move Validation', () {
    test('isValidMove should allow valid placement in empty cell', () {
      // Arrange
      final board = List.filled(16, 0);
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );
      final move = MiniSudokuMove(position: 0, number: 1);

      // Act & Assert
      expect(logic.isValidMove(state, move), true);
    });

    test('isValidMove should reject placement in locked cell', () {
      // Arrange
      final board = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {0}, // Position 0 is locked
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );
      final move = MiniSudokuMove(position: 0, number: 2);

      // Act & Assert
      expect(logic.isValidMove(state, move), false);
    });

    test('isValidMove should reject number that violates row constraint', () {
      // Arrange
      final board = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {0},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );
      // Try to place '1' at position 3 (same row as existing '1' at position 0)
      final move = MiniSudokuMove(position: 3, number: 1);

      // Act & Assert
      expect(logic.isValidMove(state, move), false);
    });

    test('isValidMove should reject number that violates column constraint', () {
      // Arrange
      final board = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {0},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );
      // Try to place '1' at position 8 (same column as existing '1' at position 0)
      final move = MiniSudokuMove(position: 8, number: 1);

      // Act & Assert
      expect(logic.isValidMove(state, move), false);
    });

    test('isValidMove should reject number that violates box constraint', () {
      // Arrange
      final board = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {0},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );
      // Try to place '1' at position 5 (same 2x2 box as existing '1' at position 0)
      final move = MiniSudokuMove(position: 5, number: 1);

      // Act & Assert
      expect(logic.isValidMove(state, move), false);
    });

    test('isValidMove should allow clearing a cell (number = 0)', () {
      // Arrange
      final board = [0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );
      final move = MiniSudokuMove(position: 1, number: 0);

      // Act & Assert
      expect(logic.isValidMove(state, move), true);
    });

    test('isValidMove should reject out-of-bounds position', () {
      // Arrange
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

      // Act & Assert
      expect(logic.isValidMove(state, MiniSudokuMove(position: -1, number: 1)), false);
      expect(logic.isValidMove(state, MiniSudokuMove(position: 16, number: 1)), false);
    });

    test('isValidMove should reject invalid number', () {
      // Arrange
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

      // Act & Assert
      expect(logic.isValidMove(state, MiniSudokuMove(position: 0, number: -1)), false);
      expect(logic.isValidMove(state, MiniSudokuMove(position: 0, number: 5)), false);
    });

    test('isValidMove should reject move when game is over', () {
      // Arrange
      final board = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: board,
        lockedCells: {},
        errorCells: {},
        isGameOver: true,
        result: GameResult.win,
      );

      // Act & Assert
      expect(logic.isValidMove(state, MiniSudokuMove(position: 0, number: 1)), false);
    });
  });

  group('MiniSudokuLogic - Apply Move', () {
    test('applyMove should update board with valid placement', () {
      // Arrange
      final board = List.filled(16, 0);
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );
      final move = MiniSudokuMove(position: 0, number: 1);

      // Act
      final newState = logic.applyMove(state, move);

      // Assert
      expect(newState.board[0], 1);
      expect(newState.isGameOver, false);
    });

    test('applyMove should detect errors when wrong number is placed', () {
      // Arrange
      final board = List.filled(16, 0);
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );
      // Place wrong number at position 0 (should be 1 according to solution)
      final move = MiniSudokuMove(position: 0, number: 2);

      // Act
      final newState = logic.applyMove(state, move);

      // Assert
      expect(newState.board[0], 2);
      expect(newState.errorCells.contains(0), true);
    });

    test('applyMove should detect win when puzzle is completed correctly', () {
      // Arrange
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final board = List<int>.from(solution);
      board[15] = 0; // Leave one cell empty
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );
      final move = MiniSudokuMove(position: 15, number: 1);

      // Act
      final newState = logic.applyMove(state, move);

      // Assert
      expect(newState.isGameOver, true);
      expect(newState.result, GameResult.win);
      expect(newState.errorCells.isEmpty, true);
    });

    test('applyMove should allow clearing a cell', () {
      // Arrange
      final board = [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {},
        errorCells: {0}, // Position 0 has wrong value
        isGameOver: false,
        result: GameResult.ongoing,
      );
      final move = MiniSudokuMove(position: 0, number: 0);

      // Act
      final newState = logic.applyMove(state, move);

      // Assert
      expect(newState.board[0], 0);
      expect(newState.errorCells.contains(0), false, reason: 'Clearing should remove error');
    });

    test('applyMove should throw on invalid move', () {
      // Arrange
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
      final invalidMove = MiniSudokuMove(position: -1, number: 1);

      // Act & Assert
      expect(() => logic.applyMove(state, invalidMove), throwsA(isA<ArgumentError>()));
    });
  });

  group('MiniSudokuLogic - Helper Methods', () {
    test('getValidMoves should return moves for all unlocked empty cells', () {
      // Arrange
      final board = List.filled(16, 0);
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {0, 1}, // Lock first two cells
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );

      // Act
      final moves = logic.getValidMoves(state);

      // Assert
      expect(moves.isNotEmpty, true);
      // Should not have moves for locked positions 0 and 1
      expect(moves.any((m) => m.position == 0), false);
      expect(moves.any((m) => m.position == 1), false);
    });

    test('getValidMoves should return empty list when game is over', () {
      // Arrange
      final board = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: board,
        lockedCells: {},
        errorCells: {},
        isGameOver: true,
        result: GameResult.win,
      );

      // Act
      final moves = logic.getValidMoves(state);

      // Assert
      expect(moves, isEmpty);
    });

    test('getValidMoves should include clear moves for non-empty cells', () {
      // Arrange
      final board = [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );

      // Act
      final moves = logic.getValidMoves(state);

      // Assert
      // Should include a clear move (number=0) for position 0
      expect(moves.any((m) => m.position == 0 && m.number == 0), true);
    });

    test('getNextPlayer should return same player (single player game)', () {
      // Act & Assert
      expect(logic.getNextPlayer(PlayerSymbol.x), PlayerSymbol.x);
      expect(logic.getNextPlayer(PlayerSymbol.o), PlayerSymbol.o);
    });
  });

  group('MiniSudokuLogic - Winner Detection', () {
    test('checkWinner should detect no winner when puzzle is incomplete', () {
      // Arrange
      final board = List.filled(16, 0);
      board[0] = 1;
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );

      // Act
      final result = logic.checkWinner(state);

      // Assert
      expect(result.hasWinner, false);
    });

    test('checkWinner should detect win when puzzle is completed correctly', () {
      // Arrange
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final state = MiniSudokuState(
        board: solution,
        solution: solution,
        lockedCells: {},
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );

      // Act
      final result = logic.checkWinner(state);

      // Assert
      expect(result.hasWinner, true);
    });

    test('checkWinner should not detect win when puzzle has errors', () {
      // Arrange
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final board = [2, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1]; // Wrong first cell
      final state = MiniSudokuState(
        board: board,
        solution: solution,
        lockedCells: {},
        errorCells: {0},
        isGameOver: false,
        result: GameResult.ongoing,
      );

      // Act
      final result = logic.checkWinner(state);

      // Assert
      expect(result.hasWinner, false);
    });
  });

  group('MiniSudokuLogic - Validation Method', () {
    test('validateBoard should return correct when board matches solution', () {
      // Arrange
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final userBoard = List<int>.from(solution);

      // Act
      final result = logic.validateBoard(userBoard, solution);

      // Assert
      expect(result['isCorrect'], true);
      expect((result['wrongIndices'] as Set).isEmpty, true);
    });

    test('validateBoard should detect incorrect cells', () {
      // Arrange
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final userBoard = List<int>.from(solution);
      userBoard[0] = 2; // Wrong value
      userBoard[5] = 3; // Wrong value

      // Act
      final result = logic.validateBoard(userBoard, solution);

      // Assert
      expect(result['isCorrect'], false);
      expect((result['wrongIndices'] as Set).contains(0), true);
      expect((result['wrongIndices'] as Set).contains(5), true);
    });

    test('validateBoard should ignore empty cells', () {
      // Arrange
      final solution = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1];
      final userBoard = [1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 0]; // Last cell empty

      // Act
      final result = logic.validateBoard(userBoard, solution);

      // Assert
      expect(result['isCorrect'], false);
      expect((result['wrongIndices'] as Set).contains(15), false, 
          reason: 'Empty cells should not be marked as wrong');
    });
  });
}


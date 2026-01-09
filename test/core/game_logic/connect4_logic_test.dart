import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/game_logic/connect4/connect4_logic.dart';
import 'package:games_app/core/game_logic/connect4/connect4_state.dart';
import 'package:games_app/core/game_logic/game_types.dart';

void main() {
  late Connect4Logic logic;

  setUp(() {
    logic = Connect4Logic();
  });

  group('Connect4Logic - Initial State', () {
    test('should create initial state with empty board', () {
      // Act
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

      // Assert
      expect(state.board.length, 42);
      expect(state.board.every((cell) => cell == null), true);
      expect(state.currentPlayerSymbol, PlayerSymbol.x);
      expect(state.isGameOver, false);
    });

    test('should create initial state with correct starting player', () {
      // Act
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.o);

      // Assert
      expect(state.currentPlayerSymbol, PlayerSymbol.o);
    });
  });

  group('Connect4Logic - Move Validation', () {
    test('isValidMove should allow move in empty column', () {
      // Arrange
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
      final move = Connect4Move(3);

      // Act & Assert
      expect(logic.isValidMove(state, move), true);
    });

    test('isValidMove should reject move in full column', () {
      // Arrange
      final board = List<PlayerSymbol?>.filled(42, null);
      // Fill column 0 completely
      for (int row = 0; row < 6; row++) {
        board[row * 7] = PlayerSymbol.x;
      }
      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );
      final move = Connect4Move(0);

      // Act & Assert
      expect(logic.isValidMove(state, move), false);
    });

    test('isValidMove should reject out-of-bounds column', () {
      // Arrange
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

      // Act & Assert
      expect(logic.isValidMove(state, Connect4Move(-1)), false);
      expect(logic.isValidMove(state, Connect4Move(7)), false);
      expect(logic.isValidMove(state, Connect4Move(100)), false);
    });

    test('isValidMove should reject move when game is over', () {
      // Arrange
      final state = Connect4State(
        board: List.filled(42, null),
        isGameOver: true,
        result: GameResult.win,
        winnerSymbol: PlayerSymbol.x,
        currentPlayerSymbol: null,
      );

      // Act & Assert
      expect(logic.isValidMove(state, Connect4Move(0)), false);
    });
  });

  group('Connect4Logic - Apply Move', () {
    test('applyMove should place piece at bottom of empty column', () {
      // Arrange
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
      final move = Connect4Move(3);

      // Act
      final newState = logic.applyMove(state, move);

      // Assert
      // Should be placed at row 5 (bottom), column 3
      final expectedIndex = 5 * 7 + 3;
      expect(newState.board[expectedIndex], PlayerSymbol.x);
      expect(newState.currentPlayerSymbol, PlayerSymbol.o);
    });

    test('applyMove should stack pieces correctly', () {
      // Arrange
      var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

      // Act - Drop multiple pieces in same column
      state = logic.applyMove(state, Connect4Move(0));
      expect(state.board[35], PlayerSymbol.x); // Row 5, Col 0

      state = logic.applyMove(state, Connect4Move(0));
      expect(state.board[28], PlayerSymbol.o); // Row 4, Col 0

      state = logic.applyMove(state, Connect4Move(0));
      expect(state.board[21], PlayerSymbol.x); // Row 3, Col 0
    });

    test('applyMove should detect horizontal win', () {
      // Arrange
      final board = List<PlayerSymbol?>.filled(42, null);
      // Setup: X has 3 in a row at bottom, needs one more
      board[35] = PlayerSymbol.x; // Row 5, Col 0
      board[36] = PlayerSymbol.x; // Row 5, Col 1
      board[37] = PlayerSymbol.x; // Row 5, Col 2

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );

      // Act
      final newState = logic.applyMove(state, Connect4Move(3));

      // Assert
      expect(newState.isGameOver, true);
      expect(newState.result, GameResult.win);
      expect(newState.winnerSymbol, PlayerSymbol.x);
      expect(newState.currentPlayerSymbol, null);
      expect(newState.winningPattern, [35, 36, 37, 38]);
    });

    test('applyMove should detect vertical win', () {
      // Arrange
      final board = List<PlayerSymbol?>.filled(42, null);
      // Setup: O has 3 in a column, needs one more
      board[35] = PlayerSymbol.o; // Row 5, Col 0
      board[28] = PlayerSymbol.o; // Row 4, Col 0
      board[21] = PlayerSymbol.o; // Row 3, Col 0

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );

      // Act
      final newState = logic.applyMove(state, Connect4Move(0));

      // Assert
      expect(newState.isGameOver, true);
      expect(newState.result, GameResult.win);
      expect(newState.winnerSymbol, PlayerSymbol.o);
    });

    test('applyMove should detect diagonal win (down-right)', () {
      // Arrange
      final board = List<PlayerSymbol?>.filled(42, null);
      // Diagonal from top-left to bottom-right
      board[14] = PlayerSymbol.x; // Row 2, Col 0
      board[22] = PlayerSymbol.x; // Row 3, Col 1
      board[30] = PlayerSymbol.x; // Row 4, Col 2
      // Add supporting pieces for gravity
      board[35] = PlayerSymbol.o; board[28] = PlayerSymbol.o; board[21] = PlayerSymbol.o;
      board[36] = PlayerSymbol.o; board[29] = PlayerSymbol.o;
      board[37] = PlayerSymbol.o;

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );

      // Act
      final newState = logic.applyMove(state, Connect4Move(3));

      // Assert
      expect(newState.isGameOver, true);
      expect(newState.result, GameResult.win);
      expect(newState.winnerSymbol, PlayerSymbol.x);
    });

    test('applyMove should detect draw when board is full', () {
      // Arrange
      final board = [
        PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o,
        PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x,
        PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o,
        PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x,
        PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o,
        PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.o, null,
      ];

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );

      // Act
      final newState = logic.applyMove(state, Connect4Move(6));

      // Assert
      expect(newState.isGameOver, true);
      expect(newState.result, GameResult.draw);
      expect(newState.winnerSymbol, null);
    });

    test('applyMove should throw on invalid move', () {
      // Arrange
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

      // Act & Assert
      expect(() => logic.applyMove(state, Connect4Move(-1)), throwsA(isA<ArgumentError>()));
    });
  });

  group('Connect4Logic - AI Logic', () {
    test('AI should take winning move immediately (hard difficulty)', () {
      // Arrange
      final board = List<PlayerSymbol?>.filled(42, null);
      // Setup: O has 3 in a row, needs one more to win
      board[35] = PlayerSymbol.o; board[36] = PlayerSymbol.o; board[37] = PlayerSymbol.o;

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );

      // Act
      final move = logic.getAIMove(
        state: state,
        difficulty: GameDifficulty.hard,
        aiPlayer: PlayerSymbol.o,
      );

      // Assert
      expect(move.column, 3, reason: 'AI should take the winning move at column 3');
    });

    test('AI should block opponent from winning (hard difficulty)', () {
      // Arrange
      final board = List<PlayerSymbol?>.filled(42, null);
      // Setup: X has 3 in a row, AI (O) must block at column 3
      board[35] = PlayerSymbol.x; board[36] = PlayerSymbol.x; board[37] = PlayerSymbol.x;

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );

      // Act
      final move = logic.getAIMove(
        state: state,
        difficulty: GameDifficulty.hard,
        aiPlayer: PlayerSymbol.o,
      );

      // Assert
      expect(move.column, 3, reason: 'AI must block X at column 3');
    });

    test('AI should return valid move on empty board', () {
      // Arrange
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

      // Act
      final move = logic.getAIMove(
        state: state,
        difficulty: GameDifficulty.hard,
        aiPlayer: PlayerSymbol.x,
      );

      // Assert
      expect(move.column, inInclusiveRange(0, 6));
      expect(logic.isValidMove(state, move), true);
    });

    test('Easy AI should return a valid random move', () {
      // Arrange
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

      // Act
      final move = logic.getAIMove(
        state: state,
        difficulty: GameDifficulty.easy,
        aiPlayer: PlayerSymbol.x,
      );

      // Assert
      expect(move.column, inInclusiveRange(0, 6));
      expect(logic.isValidMove(state, move), true);
    });
  });

  group('Connect4Logic - Helper Methods', () {
    test('getValidMoves should return all columns when board is empty', () {
      // Arrange
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

      // Act
      final moves = logic.getValidMoves(state);

      // Assert
      expect(moves.length, 7);
      for (int i = 0; i < 7; i++) {
        expect(moves.any((m) => m.column == i), true);
      }
    });

    test('getValidMoves should exclude full columns', () {
      // Arrange
      final board = List<PlayerSymbol?>.filled(42, null);
      // Fill columns 0 and 6 completely
      for (int row = 0; row < 6; row++) {
        board[row * 7] = PlayerSymbol.x; // Column 0
        board[row * 7 + 6] = PlayerSymbol.o; // Column 6
      }

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );

      // Act
      final moves = logic.getValidMoves(state);

      // Assert
      expect(moves.length, 5);
      expect(moves.any((m) => m.column == 0), false);
      expect(moves.any((m) => m.column == 6), false);
    });

    test('getValidMoves should return empty list when game is over', () {
      // Arrange
      final state = Connect4State(
        board: List.filled(42, PlayerSymbol.x),
        isGameOver: true,
        result: GameResult.draw,
        currentPlayerSymbol: null,
      );

      // Act
      final moves = logic.getValidMoves(state);

      // Assert
      expect(moves, isEmpty);
    });

    test('getNextPlayer should alternate between X and O', () {
      expect(logic.getNextPlayer(PlayerSymbol.x), PlayerSymbol.o);
      expect(logic.getNextPlayer(PlayerSymbol.o), PlayerSymbol.x);
    });
  });

  group('Connect4Logic - Winner Detection', () {
    test('checkWinner should detect no winner in empty board', () {
      // Arrange
      final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

      // Act
      final result = logic.checkWinner(state);

      // Assert
      expect(result.hasWinner, false);
      expect(result.winner, null);
    });

    test('checkWinner should detect horizontal win in middle row', () {
      // Arrange
      final board = List<PlayerSymbol?>.filled(42, null);
      // Middle row (row 3): X X X X
      board[21] = PlayerSymbol.x; board[22] = PlayerSymbol.x; 
      board[23] = PlayerSymbol.x; board[24] = PlayerSymbol.x;

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );

      // Act
      final result = logic.checkWinner(state);

      // Assert
      expect(result.hasWinner, true);
      expect(result.winner, PlayerSymbol.x);
      expect(result.winningPattern, [21, 22, 23, 24]);
    });

    test('checkWinner should detect multiple possible wins correctly', () {
      // Arrange
      final board = List<PlayerSymbol?>.filled(42, null);
      // Create two potential wins, should detect the first one found
      board[35] = PlayerSymbol.o; board[36] = PlayerSymbol.o; 
      board[37] = PlayerSymbol.o; board[38] = PlayerSymbol.o;

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );

      // Act
      final result = logic.checkWinner(state);

      // Assert
      expect(result.hasWinner, true);
      expect(result.winner, PlayerSymbol.o);
    });
  });
}


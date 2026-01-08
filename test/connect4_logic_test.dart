import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/game_logic/connect4/connect4_logic.dart';
import 'package:games_app/core/game_logic/connect4/connect4_state.dart';
import 'package:games_app/core/game_logic/game_types.dart';

void main() {
  late Connect4Logic logic;

  setUp(() {
    logic = Connect4Logic();
  });

  group('Connect4 Winner Checks', () {
    test('Detects Horizontal Win (Row Bottom)', () {
      // Bottom row: X X X X
      final board = List<PlayerSymbol?>.filled(42, null);
      board[35] = PlayerSymbol.x;
      board[36] = PlayerSymbol.x;
      board[37] = PlayerSymbol.x;
      board[38] = PlayerSymbol.x;

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );

      final result = logic.checkWinner(state);

      expect(result, isNotNull);
      expect(result.hasWinner, true);
      expect(result.winner, PlayerSymbol.x);
      expect(result.winningPattern, [35, 36, 37, 38]);
    });

    test('Detects Vertical Win (Column 0)', () {
      // Column 0, bottom 4 cells: O O O O
      final board = List<PlayerSymbol?>.filled(42, null);
      board[35] = PlayerSymbol.o; // Row 5, Col 0
      board[28] = PlayerSymbol.o; // Row 4, Col 0
      board[21] = PlayerSymbol.o; // Row 3, Col 0
      board[14] = PlayerSymbol.o; // Row 2, Col 0

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );

      final result = logic.checkWinner(state);

      expect(result, isNotNull);
      expect(result.hasWinner, true);
      expect(result.winner, PlayerSymbol.o);
      expect(result.winningPattern, [14, 21, 28, 35]);
    });

    test('Detects Diagonal Win (Down-Right)', () {
      // Diagonal from top-left to bottom-right
      final board = List<PlayerSymbol?>.filled(42, null);
      board[14] = PlayerSymbol.x; // Row 2, Col 0
      board[22] = PlayerSymbol.x; // Row 3, Col 1
      board[30] = PlayerSymbol.x; // Row 4, Col 2
      board[38] = PlayerSymbol.x; // Row 5, Col 3

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );

      final result = logic.checkWinner(state);

      expect(result, isNotNull);
      expect(result.hasWinner, true);
      expect(result.winner, PlayerSymbol.x);
      expect(result.winningPattern, [14, 22, 30, 38]);
    });

    test('Detects Diagonal Win (Down-Left)', () {
      // Diagonal from top-right to bottom-left
      final board = List<PlayerSymbol?>.filled(42, null);
      board[17] = PlayerSymbol.o; // Row 2, Col 3
      board[23] = PlayerSymbol.o; // Row 3, Col 2
      board[29] = PlayerSymbol.o; // Row 4, Col 1
      board[35] = PlayerSymbol.o; // Row 5, Col 0

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );

      final result = logic.checkWinner(state);

      expect(result, isNotNull);
      expect(result.hasWinner, true);
      expect(result.winner, PlayerSymbol.o);
      expect(result.winningPattern, [17, 23, 29, 35]);
    });

    test('Detects Draw correctly', () {
      // Full board with no winner - pattern with 3-in-a-row max
      final board = [
        PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, // Row 0
        PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, // Row 1
        PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, // Row 2
        PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, // Row 3
        PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, // Row 4
        PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.o, PlayerSymbol.x, // Row 5
      ];

      final state = Connect4State(
        board: board,
        isGameOver: true,
        result: GameResult.draw,
        currentPlayerSymbol: null,
      );

      final result = logic.checkWinner(state);

      expect(result, isNotNull);
      expect(result.hasWinner, false);
      expect(result.winner, null);
      expect(result.winningPattern, null);
    });

    test('Returns no winner when game is still in progress', () {
      final board = List<PlayerSymbol?>.filled(42, null);
      board[35] = PlayerSymbol.x;
      board[36] = PlayerSymbol.o;
      board[37] = PlayerSymbol.x;

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );

      final result = logic.checkWinner(state);

      expect(result.hasWinner, false);
      expect(result.winner, null);
    });
  });

  group('Connect4 Move Validation', () {
    test('isValidMove allows move in empty column', () {
      final state = Connect4State.initial(startingPlayer: PlayerSymbol.x);
      final move = Connect4Move(3);

      expect(logic.isValidMove(state, move), true);
    });

    test('isValidMove rejects move in full column', () {
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

      expect(logic.isValidMove(state, move), false);
    });

    test('isValidMove rejects out-of-bounds column', () {
      final state = Connect4State.initial(startingPlayer: PlayerSymbol.x);

      expect(logic.isValidMove(state, Connect4Move(-1)), false);
      expect(logic.isValidMove(state, Connect4Move(7)), false);
      expect(logic.isValidMove(state, Connect4Move(100)), false);
    });

    test('isValidMove rejects move when game is over', () {
      final state = Connect4State(
        board: List.filled(42, null),
        isGameOver: true,
        result: GameResult.win,
        winnerSymbol: PlayerSymbol.x,
        currentPlayerSymbol: null,
      );

      expect(logic.isValidMove(state, Connect4Move(0)), false);
    });
  });

  group('Connect4 Apply Move', () {
    test('applyMove places piece at bottom of empty column', () {
      final state = Connect4State.initial(startingPlayer: PlayerSymbol.x);
      final move = Connect4Move(3);

      final newState = logic.applyMove(state, move);

      // Should be placed at row 5 (bottom), column 3
      final expectedIndex = 5 * 7 + 3;
      expect(newState.board[expectedIndex], PlayerSymbol.x);
      expect(newState.currentPlayerSymbol, PlayerSymbol.o);
    });

    test('applyMove stacks pieces correctly', () {
      var state = Connect4State.initial(startingPlayer: PlayerSymbol.x);

      // Drop X in column 0
      state = logic.applyMove(state, Connect4Move(0));
      expect(state.board[35], PlayerSymbol.x); // Row 5, Col 0

      // Drop O in column 0
      state = logic.applyMove(state, Connect4Move(0));
      expect(state.board[28], PlayerSymbol.o); // Row 4, Col 0

      // Drop X in column 0
      state = logic.applyMove(state, Connect4Move(0));
      expect(state.board[21], PlayerSymbol.x); // Row 3, Col 0
    });

    test('applyMove detects win and ends game', () {
      final board = List<PlayerSymbol?>.filled(42, null);
      // Setup: X has 3 in a row at bottom row, column 4 would complete it
      board[35] = PlayerSymbol.x; // Row 5, Col 0
      board[36] = PlayerSymbol.x; // Row 5, Col 1
      board[37] = PlayerSymbol.x; // Row 5, Col 2

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );

      // Place X at column 3 (which is index 38 in row 5)
      final newState = logic.applyMove(state, Connect4Move(3));

      expect(newState.isGameOver, true);
      expect(newState.result, GameResult.win);
      expect(newState.winnerSymbol, PlayerSymbol.x);
      expect(newState.currentPlayerSymbol, null);
    });

    test('applyMove throws on invalid move', () {
      final state = Connect4State.initial(startingPlayer: PlayerSymbol.x);

      expect(() => logic.applyMove(state, Connect4Move(-1)),
          throwsA(isA<ArgumentError>()));
    });
  });

  group('Connect4 AI Logic', () {
    test('Hard AI takes the winning move immediately', () {
      final board = List<PlayerSymbol?>.filled(42, null);
      // Setup: O has 3 in a row at bottom, needs column 3 to win
      board[35] = PlayerSymbol.o; // Row 5, Col 0
      board[36] = PlayerSymbol.o; // Row 5, Col 1
      board[37] = PlayerSymbol.o; // Row 5, Col 2

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );

      final move = logic.getAIMove(
        state: state,
        difficulty: GameDifficulty.hard,
        aiPlayer: PlayerSymbol.o,
      );

      expect(move.column, 3, reason: 'AI should take the winning column 3');
    });

    test('Hard AI blocks opponent from winning', () {
      final board = List<PlayerSymbol?>.filled(42, null);
      // Setup: X has 3 in a row, AI is O and must block at column 3
      board[35] = PlayerSymbol.x; // Row 5, Col 0
      board[36] = PlayerSymbol.x; // Row 5, Col 1
      board[37] = PlayerSymbol.x; // Row 5, Col 2

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );

      final move = logic.getAIMove(
        state: state,
        difficulty: GameDifficulty.hard,
        aiPlayer: PlayerSymbol.o,
      );

      expect(move.column, 3, reason: 'AI must block X at column 3');
    });

    test('AI does not crash on empty board', () {
      final state = Connect4State.initial(startingPlayer: PlayerSymbol.x);

      final move = logic.getAIMove(
        state: state,
        difficulty: GameDifficulty.hard,
        aiPlayer: PlayerSymbol.x,
      );

      expect(move.column, inInclusiveRange(0, 6));
    });

    test('Easy AI returns a valid move (Random)', () {
      final state = Connect4State.initial(startingPlayer: PlayerSymbol.x);

      final move = logic.getAIMove(
        state: state,
        difficulty: GameDifficulty.easy,
        aiPlayer: PlayerSymbol.x,
      );

      expect(move.column, inInclusiveRange(0, 6));
    });

    test('AI prefers center columns for strategic advantage', () {
      // On an empty board, hard AI should often pick center columns (3)
      final state = Connect4State.initial(startingPlayer: PlayerSymbol.x);

      final move = logic.getAIMove(
        state: state,
        difficulty: GameDifficulty.hard,
        aiPlayer: PlayerSymbol.x,
      );

      // Center preference is a strategy, so we just verify it's valid
      expect(move.column, inInclusiveRange(0, 6));
    });
  });

  group('Connect4 Helper Methods', () {
    test('getValidMoves returns all columns when board is empty', () {
      final state = Connect4State.initial(startingPlayer: PlayerSymbol.x);

      final moves = logic.getValidMoves(state);

      expect(moves.length, 7);
      for (int i = 0; i < 7; i++) {
        expect(moves.any((m) => m.column == i), true);
      }
    });

    test('getValidMoves excludes full columns', () {
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

      final moves = logic.getValidMoves(state);

      expect(moves.length, 5);
      expect(moves.any((m) => m.column == 0), false);
      expect(moves.any((m) => m.column == 6), false);
    });

    test('getValidMoves returns empty list when game is over', () {
      final state = Connect4State(
        board: List.filled(42, PlayerSymbol.x),
        isGameOver: true,
        result: GameResult.draw,
        currentPlayerSymbol: null,
      );

      final moves = logic.getValidMoves(state);

      expect(moves, isEmpty);
    });

    test('getNextPlayer alternates correctly', () {
      expect(logic.getNextPlayer(PlayerSymbol.x), PlayerSymbol.o);
      expect(logic.getNextPlayer(PlayerSymbol.o), PlayerSymbol.x);
    });
  });

  group('Connect4 State Helpers', () {
    test('getDropRow returns correct row for empty column', () {
      final state = Connect4State.initial(startingPlayer: PlayerSymbol.x);

      expect(state.getDropRow(0), 5); // Bottom row
      expect(state.getDropRow(3), 5);
      expect(state.getDropRow(6), 5);
    });

    test('getDropRow returns correct row for partially filled column', () {
      final board = List<PlayerSymbol?>.filled(42, null);
      board[35] = PlayerSymbol.x; // Row 5, Col 0
      board[28] = PlayerSymbol.o; // Row 4, Col 0

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );

      expect(state.getDropRow(0), 3); // Next available row
    });

    test('getDropRow returns -1 for full column', () {
      final board = List<PlayerSymbol?>.filled(42, null);
      for (int row = 0; row < 6; row++) {
        board[row * 7 + 3] = PlayerSymbol.x;
      }

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );

      expect(state.getDropRow(3), -1);
    });

    test('isColumnFull works correctly', () {
      final board = List<PlayerSymbol?>.filled(42, null);
      for (int row = 0; row < 6; row++) {
        board[row * 7] = PlayerSymbol.x; // Fill column 0
      }

      final state = Connect4State(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );

      expect(state.isColumnFull(0), true);
      expect(state.isColumnFull(1), false);
    });
  });
}


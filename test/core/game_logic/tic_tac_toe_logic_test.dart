import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/game_logic/game_logic.dart';

/// Unit tests for TicTacToeLogic
/// Coverage Target: 100%
///
/// Why test this thoroughly?
/// 1. Core business logic - bugs here affect all game modes
/// 2. No external dependencies - fast, deterministic tests
/// 3. Complex state transitions need validation
/// 4. AI algorithm correctness is critical for UX
void main() {
  group('TicTacToeLogic', () {
    late TicTacToeLogic logic;

    setUp(() {
      logic = TicTacToeLogic();
    });

    group('createInitialState', () {
      test('should create empty board with starting player', () {
        // Arrange & Act
        final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

        // Assert
        expect(state.board, List.filled(9, null));
        expect(state.isGameOver, false);
        expect(state.currentPlayerSymbol, PlayerSymbol.x);
        expect(state.result, GameResult.ongoing);
      });

      test('should create board with O as starting player', () {
        final state = logic.createInitialState(startingPlayer: PlayerSymbol.o);
        expect(state.currentPlayerSymbol, PlayerSymbol.o);
      });
    });

    group('isValidMove', () {
      test('should return true for empty cell', () {
        final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        final move = TicTacToeMove(0);

        expect(logic.isValidMove(state, move), true);
      });

      test('should return false for occupied cell', () {
        // Arrange: Create state with cell 0 occupied
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        state = logic.applyMove(state, TicTacToeMove(0));

        // Act & Assert
        expect(logic.isValidMove(state, TicTacToeMove(0)), false);
      });

      test('should return false for invalid position', () {
        final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

        expect(logic.isValidMove(state, TicTacToeMove(-1)), false);
        expect(logic.isValidMove(state, TicTacToeMove(9)), false);
        expect(logic.isValidMove(state, TicTacToeMove(100)), false);
      });

      test('should return false when game is over', () {
        // Arrange: Create winning state
        // X | X | X
        // O | O |
        //   |   |
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        state = logic.applyMove(state, TicTacToeMove(0)); // X
        state = logic.applyMove(state, TicTacToeMove(3)); // O
        state = logic.applyMove(state, TicTacToeMove(1)); // X
        state = logic.applyMove(state, TicTacToeMove(4)); // O
        state = logic.applyMove(state, TicTacToeMove(2)); // X wins

        // Act & Assert
        expect(state.isGameOver, true);
        expect(logic.isValidMove(state, TicTacToeMove(5)), false);
      });
    });

    group('applyMove', () {
      test('should place symbol and switch player', () {
        // Arrange
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

        // Act
        state = logic.applyMove(state, TicTacToeMove(0));

        // Assert
        expect(state.board[0], PlayerSymbol.x);
        expect(state.currentPlayerSymbol, PlayerSymbol.o);
        expect(state.isGameOver, false);
      });

      test('should throw on invalid move', () {
        final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

        expect(
              () => logic.applyMove(state, TicTacToeMove(-1)),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should detect horizontal win (top row)', () {
        // X | X | X
        // O | O |
        //   |   |
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        state = logic.applyMove(state, TicTacToeMove(0)); // X
        state = logic.applyMove(state, TicTacToeMove(3)); // O
        state = logic.applyMove(state, TicTacToeMove(1)); // X
        state = logic.applyMove(state, TicTacToeMove(4)); // O
        state = logic.applyMove(state, TicTacToeMove(2)); // X wins

        expect(state.isGameOver, true);
        expect(state.result, GameResult.win);
        expect(state.winnerSymbol, PlayerSymbol.x);
        expect(state.winningPattern, [0, 1, 2]);
      });

      test('should detect vertical win (left column)', () {
        // X | O | O
        // X | O |
        // X |   |
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        state = logic.applyMove(state, TicTacToeMove(0)); // X
        state = logic.applyMove(state, TicTacToeMove(1)); // O
        state = logic.applyMove(state, TicTacToeMove(3)); // X
        state = logic.applyMove(state, TicTacToeMove(2)); // O
        state = logic.applyMove(state, TicTacToeMove(6)); // X wins

        expect(state.isGameOver, true);
        expect(state.winnerSymbol, PlayerSymbol.x);
        expect(state.winningPattern, [0, 3, 6]);
      });

      test('should detect diagonal win (top-left to bottom-right)', () {
        // X | O | O
        // O | X |
        //   |   | X
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        state = logic.applyMove(state, TicTacToeMove(0)); // X
        state = logic.applyMove(state, TicTacToeMove(1)); // O
        state = logic.applyMove(state, TicTacToeMove(4)); // X
        state = logic.applyMove(state, TicTacToeMove(3)); // O
        state = logic.applyMove(state, TicTacToeMove(8)); // X wins

        expect(state.isGameOver, true);
        expect(state.winningPattern, [0, 4, 8]);
      });

      test('should detect diagonal win (top-right to bottom-left)', () {
        // O | O | X
        //   | X | O
        // X |   |
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        state = logic.applyMove(state, TicTacToeMove(2)); // X
        state = logic.applyMove(state, TicTacToeMove(0)); // O
        state = logic.applyMove(state, TicTacToeMove(4)); // X
        state = logic.applyMove(state, TicTacToeMove(1)); // O
        state = logic.applyMove(state, TicTacToeMove(6)); // X wins

        expect(state.isGameOver, true);
        expect(state.winningPattern, [2, 4, 6]);
      });

      test('should detect draw when board is full', () {
        // X | O | X
        // X | X | O
        // O | X | O
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        state = logic.applyMove(state, TicTacToeMove(0)); // X
        state = logic.applyMove(state, TicTacToeMove(1)); // O
        state = logic.applyMove(state, TicTacToeMove(2)); // X
        state = logic.applyMove(state, TicTacToeMove(5)); // O
        state = logic.applyMove(state, TicTacToeMove(3)); // X
        state = logic.applyMove(state, TicTacToeMove(6)); // O
        state = logic.applyMove(state, TicTacToeMove(4)); // X
        state = logic.applyMove(state, TicTacToeMove(8)); // O
        state = logic.applyMove(state, TicTacToeMove(7)); // X

        expect(state.isGameOver, true);
        expect(state.result, GameResult.draw);
        expect(state.winnerSymbol, null);
      });
    });

    group('getValidMoves', () {
      test('should return all cells for empty board', () {
        final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        final moves = logic.getValidMoves(state);

        expect(moves.length, 9);
        for (int i = 0; i < 9; i++) {
          expect(moves.any((m) => m.position == i), true);
        }
      });

      test('should exclude occupied cells', () {
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        state = logic.applyMove(state, TicTacToeMove(0)); // X at 0
        state = logic.applyMove(state, TicTacToeMove(4)); // O at 4

        final moves = logic.getValidMoves(state);

        expect(moves.length, 7);
        expect(moves.any((m) => m.position == 0), false);
        expect(moves.any((m) => m.position == 4), false);
      });

      test('should return empty list when game is over', () {
        // Create winning state
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        state = logic.applyMove(state, TicTacToeMove(0));
        state = logic.applyMove(state, TicTacToeMove(3));
        state = logic.applyMove(state, TicTacToeMove(1));
        state = logic.applyMove(state, TicTacToeMove(4));
        state = logic.applyMove(state, TicTacToeMove(2)); // X wins

        expect(logic.getValidMoves(state), isEmpty);
      });
    });

    group('getAIMove - Easy Difficulty', () {
      test('should return a valid move', () {
        final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

        final move = logic.getAIMove(
          state: state,
          difficulty: GameDifficulty.easy,
          aiPlayer: PlayerSymbol.o,
        );

        expect(logic.isValidMove(state, move), true);
      });

      test('should make different moves (randomness check)', () {
        // Run multiple times to check randomness
        final moves = <int>{};
        final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

        for (int i = 0; i < 20; i++) {
          final move = logic.getAIMove(
            state: state,
            difficulty: GameDifficulty.easy,
            aiPlayer: PlayerSymbol.o,
          );
          moves.add(move.position);
        }

        // Easy mode should make various different moves
        expect(moves.length, greaterThan(1));
      });
    });

    group('getAIMove - Hard Difficulty', () {
      test('should block immediate win', () {
        // X | X |
        // O |   |
        //   |   |
        // O needs to block at position 2
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        state = logic.applyMove(state, TicTacToeMove(0)); // X
        state = logic.applyMove(state, TicTacToeMove(3)); // O
        state = logic.applyMove(state, TicTacToeMove(1)); // X

        final move = logic.getAIMove(
          state: state,
          difficulty: GameDifficulty.hard,
          aiPlayer: PlayerSymbol.o,
        );

        expect(move.position, 2); // Must block
      });

      test('should take winning move', () {
        // O | O |
        // X | X |
        //   |   |
        // O should win at position 2
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.o);
        state = logic.applyMove(state, TicTacToeMove(0)); // O
        state = logic.applyMove(state, TicTacToeMove(3)); // X
        state = logic.applyMove(state, TicTacToeMove(1)); // O
        state = logic.applyMove(state, TicTacToeMove(4)); // X

        final move = logic.getAIMove(
          state: state,
          difficulty: GameDifficulty.hard,
          aiPlayer: PlayerSymbol.o,
        );

        expect(move.position, 2); // Winning move
      });

      test('should prefer center on empty board', () {
        final state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

        // Hard AI often prefers center as optimal opening
        final move = logic.getAIMove(
          state: state,
          difficulty: GameDifficulty.hard,
          aiPlayer: PlayerSymbol.x,
        );

        // Center (4) or corner should be preferred
        expect([0, 2, 4, 6, 8].contains(move.position), true);
      });
    });

    group('getNextPlayer', () {
      test('should alternate between X and O', () {
        expect(logic.getNextPlayer(PlayerSymbol.x), PlayerSymbol.o);
        expect(logic.getNextPlayer(PlayerSymbol.o), PlayerSymbol.x);
      });
    });

    group('Edge Cases', () {
      test('should handle rapid successive moves', () {
        var state = logic.createInitialState(startingPlayer: PlayerSymbol.x);

        // Make 5 moves rapidly
        for (int i = 0; i < 5; i++) {
          state = logic.applyMove(state, TicTacToeMove(i));
        }

        expect(state.board.where((cell) => cell != null).length, 5);
      });

      test('should maintain immutability of previous states', () {
        final state1 = logic.createInitialState(startingPlayer: PlayerSymbol.x);
        final state2 = logic.applyMove(state1, TicTacToeMove(0));

        // Original state should be unchanged
        expect(state1.board[0], null);
        expect(state2.board[0], PlayerSymbol.x);
      });
    });
  });
}
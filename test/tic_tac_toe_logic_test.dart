import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/game_logic/tic_tac_toe/tic_tac_toe_logic.dart';
import 'package:games_app/core/game_logic/tic_tac_toe/tic_tac_toe_state.dart';
import 'package:games_app/core/game_logic/game_types.dart';

void main() {
  late TicTacToeLogic logic;

  setUp(() {
    logic = TicTacToeLogic();
  });

  group('TicTacToe Winner Checks', () {
    test('Detects Horizontal Win (Row 1)', () {
      final board = [
        PlayerSymbol.x, PlayerSymbol.x, PlayerSymbol.x, // Win
        null, PlayerSymbol.o, null,
        PlayerSymbol.o, null, null
      ];
      final state = TicTacToeState(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );
      final result = logic.checkWinner(state);

      expect(result, isNotNull);
      expect(result.hasWinner, true);
      expect(result.winner, PlayerSymbol.x);
      expect(result.winningPattern, [0, 1, 2]);
    });

    test('Detects Vertical Win (Column 1)', () {
      final board = [
        PlayerSymbol.o, PlayerSymbol.x, null,
        PlayerSymbol.o, null, PlayerSymbol.x,
        PlayerSymbol.o, null, null  // Win
      ];
      final state = TicTacToeState(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );
      final result = logic.checkWinner(state);

      expect(result, isNotNull);
      expect(result.hasWinner, true);
      expect(result.winner, PlayerSymbol.o);
      expect(result.winningPattern, [0, 3, 6]);
    });

    test('Detects Diagonal Win', () {
      final board = [
        PlayerSymbol.x, PlayerSymbol.o, null,
        null, PlayerSymbol.x, null,
        PlayerSymbol.o, null, PlayerSymbol.x // Win
      ];
      final state = TicTacToeState(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.o,
      );
      final result = logic.checkWinner(state);

      expect(result, isNotNull);
      expect(result.hasWinner, true);
      expect(result.winner, PlayerSymbol.x);
      expect(result.winningPattern, [0, 4, 8]);
    });

    test('Detects Draw correctly', () {
      // A full board with no winner
      final board = [
        PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.x,
        PlayerSymbol.x, PlayerSymbol.o, PlayerSymbol.x,
        PlayerSymbol.o, PlayerSymbol.x, PlayerSymbol.o
      ];
      final state = TicTacToeState(
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
      final board = [
        PlayerSymbol.x, PlayerSymbol.o, null,
        null, null, null,
        null, null, null
      ];
      final state = TicTacToeState(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );
      final result = logic.checkWinner(state);

      expect(result.hasWinner, false);
      expect(result.winner, null);
    });
  });

  group('TicTacToe AI Logic (Minimax)', () {
    test('Hard AI takes the winning move immediately', () {
      // Setup: 'O' has two in a row. It is 'O's turn.
      final board = [
        PlayerSymbol.o, PlayerSymbol.o, null, // Index 2 is the winning spot
        PlayerSymbol.x, PlayerSymbol.x, null,
        null, null, null
      ];
      final state = TicTacToeState(
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

      expect(move.position, 2, reason: 'AI should take the winning spot index 2');
    });

    test('Hard AI blocks the opponent from winning', () {
      // Setup: 'X' is about to win. AI is 'O'. AI must block.
      final board = [
        PlayerSymbol.x, PlayerSymbol.x, null, // Index 2 is the danger zone
        null, PlayerSymbol.o, null,
        null, null, null
      ];
      final state = TicTacToeState(
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

      expect(move.position, 2, reason: 'AI must block X at index 2');
    });

    test('AI does not crash on empty board', () {
      final board = List<PlayerSymbol?>.filled(9, null);
      final state = TicTacToeState(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );

      final move = logic.getAIMove(
        state: state,
        difficulty: GameDifficulty.hard,
        aiPlayer: PlayerSymbol.x,
      );

      expect(move.position, inInclusiveRange(0, 8));
    });

    test('Easy AI returns a valid move (Random)', () {
      final board = List<PlayerSymbol?>.filled(9, null);
      final state = TicTacToeState(
        board: board,
        isGameOver: false,
        result: GameResult.ongoing,
        currentPlayerSymbol: PlayerSymbol.x,
      );

      final move = logic.getAIMove(
        state: state,
        difficulty: GameDifficulty.easy,
        aiPlayer: PlayerSymbol.x,
      );

      expect(move.position, inInclusiveRange(0, 8));
    });
  });
}

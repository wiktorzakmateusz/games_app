import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/game/domain/entities/game_entity.dart';
import 'package:games_app/features/game/domain/entities/game_player_entity.dart';
import 'package:games_app/features/game/domain/entities/game_state_entity.dart';
import 'package:games_app/features/game/domain/usecases/abandon_game_usecase.dart';
import 'package:games_app/features/game/domain/usecases/make_move_usecase.dart';
import 'package:games_app/features/game/domain/usecases/watch_game_usecase.dart';
import 'package:games_app/features/game/presentation/cubit/game_cubit.dart';
import 'package:games_app/features/game/presentation/cubit/game_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'game_cubit_test.mocks.dart';

/// Integration tests for GameCubit
///
/// These tests verify that the Cubit correctly orchestrates
/// multiple use cases and handles state transitions
@GenerateMocks([
  WatchGameUseCase,
  MakeMoveUseCase,
  AbandonGameUseCase,
])
void main() {
  late GameCubit cubit;
  late MockWatchGameUseCase mockWatchGameUseCase;
  late MockMakeMoveUseCase mockMakeMoveUseCase;
  late MockAbandonGameUseCase mockAbandonGameUseCase;

  final testPlayer1 = const GamePlayerEntity(
    userId: 'user1',
    username: 'player1',
    displayName: 'Player One',
    symbol: 'X',
  );

  final testPlayer2 = const GamePlayerEntity(
    userId: 'user2',
    username: 'player2',
    displayName: 'Player Two',
    symbol: 'O',
  );

  final testGameState = const TicTacToeGameStateEntity(
    board: [null, null, null, null, null, null, null, null, null],
    gameOver: false,
    isDraw: false,
  );

  final testGame = GameEntity(
    id: 'game1',
    lobbyId: 'lobby1',
    gameType: GameType.ticTacToe,
    status: GameStatus.inProgress,
    currentPlayerId: 'user1',
    players: [testPlayer1, testPlayer2],
    state: testGameState,
    startedAt: DateTime(2024),
  );

  setUp(() {
    mockWatchGameUseCase = MockWatchGameUseCase();
    mockMakeMoveUseCase = MockMakeMoveUseCase();
    mockAbandonGameUseCase = MockAbandonGameUseCase();

    cubit = GameCubit(
      watchGameUseCase: mockWatchGameUseCase,
      makeMoveUseCase: mockMakeMoveUseCase,
      abandonGameUseCase: mockAbandonGameUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('Watch Game Flow', () {
    blocTest<GameCubit, GameState>(
      'emits [GameLoading, GameLoaded] when watch succeeds',
      build: () {
        when(mockWatchGameUseCase(any)).thenAnswer(
          (_) => Stream.value(testGame),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchGame('game1'),
      expect: () => [
        const GameLoading(),
        GameLoaded(testGame),
      ],
      verify: (_) {
        verify(mockWatchGameUseCase('game1')).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'emits [GameLoading, GameError] when watch fails',
      build: () {
        when(mockWatchGameUseCase(any)).thenAnswer(
          (_) => Stream.error('Failed to load game'),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchGame('game1'),
      expect: () => [
        const GameLoading(),
        const GameError('Failed to load game: Failed to load game'),
      ],
    );

    blocTest<GameCubit, GameState>(
      'updates state when game stream emits new data',
      build: () {
        final gameWithMove = testGame.copyWith(currentPlayerId: 'user2');
        when(mockWatchGameUseCase(any)).thenAnswer(
          (_) => Stream.fromIterable([testGame, gameWithMove]),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchGame('game1'),
      expect: () => [
        const GameLoading(),
        GameLoaded(testGame),
        GameLoaded(testGame.copyWith(currentPlayerId: 'user2')),
      ],
    );

    test('does not watch game again if already watching same game', () async {
      when(mockWatchGameUseCase(any)).thenAnswer(
        (_) => Stream.value(testGame),
      );
      
      // First watch
      cubit.watchGame('game1');
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(cubit.state, isA<GameLoaded>());
      
      // Try to watch again - should do nothing
      cubit.watchGame('game1');
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Verify called only once
      verify(mockWatchGameUseCase('game1')).called(1);
    });
  });

  group('Make Move Flow', () {
    blocTest<GameCubit, GameState>(
      'performs optimistic update and calls use case',
      build: () {
        cubit.setCurrentUserId('user1');
        when(mockMakeMoveUseCase(
          gameId: anyNamed('gameId'),
          position: anyNamed('position'),
        )).thenAnswer((_) async => const Right(null));
        return cubit;
      },
      seed: () => GameLoaded(testGame),
      act: (cubit) => cubit.makeMove(0),
      expect: () => [
        predicate<GameLoaded>((state) {
          return state.isPerformingAction == true &&
              state.game.currentPlayerId == 'user2';
        }),
        predicate<GameLoaded>((state) {
          return state.isPerformingAction == false;
        }),
      ],
      verify: (_) {
        verify(mockMakeMoveUseCase(gameId: 'game1', position: 0)).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'rollsback on failure',
      build: () {
        cubit.setCurrentUserId('user1');
        when(mockMakeMoveUseCase(
          gameId: anyNamed('gameId'),
          position: anyNamed('position'),
        )).thenAnswer(
          (_) async => const Left(ServerFailure('Invalid move')),
        );
        return cubit;
      },
      seed: () => GameLoaded(testGame),
      act: (cubit) => cubit.makeMove(0),
      expect: () => [
        predicate<GameLoaded>((state) => state.isPerformingAction == true),
        predicate<GameLoaded>((state) => state.isPerformingAction == false),
        predicate<GameError>((state) => state.message == 'Invalid move'),
      ],
    );

    blocTest<GameCubit, GameState>(
      'does not make move when game is over',
      build: () {
        cubit.setCurrentUserId('user1');
        return cubit;
      },
      seed: () => GameLoaded(testGame.copyWith(
        state: const TicTacToeGameStateEntity(
          board: ['X', 'X', 'X', null, null, null, null, null, null],
          gameOver: true,
          winner: 'X',
          isDraw: false,
        ),
      )),
      act: (cubit) => cubit.makeMove(3),
      expect: () => [],
      verify: (_) {
        verifyNever(mockMakeMoveUseCase(
          gameId: anyNamed('gameId'),
          position: anyNamed('position'),
        ));
      },
    );

    blocTest<GameCubit, GameState>(
      'does not make move when not player turn',
      build: () {
        cubit.setCurrentUserId('user2'); // Not current player
        return cubit;
      },
      seed: () => GameLoaded(testGame), // user1's turn
      act: (cubit) => cubit.makeMove(0),
      expect: () => [],
      verify: (_) {
        verifyNever(mockMakeMoveUseCase(
          gameId: anyNamed('gameId'),
          position: anyNamed('position'),
        ));
      },
    );

    blocTest<GameCubit, GameState>(
      'does not make move when not in GameLoaded state',
      build: () {
        cubit.setCurrentUserId('user1');
        return cubit;
      },
      act: (cubit) => cubit.makeMove(0),
      expect: () => [],
      verify: (_) {
        verifyNever(mockMakeMoveUseCase(
          gameId: anyNamed('gameId'),
          position: anyNamed('position'),
        ));
      },
    );
  });

  group('Abandon Game Flow', () {
    blocTest<GameCubit, GameState>(
      'emits [GameLoaded with action, GameAbandoned] when abandon succeeds',
      build: () {
        when(mockAbandonGameUseCase(any)).thenAnswer(
          (_) async => const Right(null),
        );
        return cubit;
      },
      seed: () => GameLoaded(testGame),
      act: (cubit) => cubit.abandonGame(),
      expect: () => [
        predicate<GameLoaded>((state) => state.isPerformingAction == true),
        const GameAbandoned(),
      ],
      verify: (_) {
        verify(mockAbandonGameUseCase('game1')).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'emits error when abandon fails',
      build: () {
        when(mockAbandonGameUseCase(any)).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to abandon game')),
        );
        return cubit;
      },
      seed: () => GameLoaded(testGame),
      act: (cubit) => cubit.abandonGame(),
      expect: () => [
        predicate<GameLoaded>((state) => state.isPerformingAction == true),
        predicate<GameError>((state) =>
            state.message == 'Failed to abandon game' &&
            state.previousGame == testGame),
      ],
    );

    blocTest<GameCubit, GameState>(
      'does not abandon when not in GameLoaded state',
      build: () => cubit,
      act: (cubit) => cubit.abandonGame(),
      expect: () => [],
      verify: (_) {
        verifyNever(mockAbandonGameUseCase(any));
      },
    );
  });

  group('Connect4 Game Support', () {
    final connect4GameState = Connect4GameStateEntity(
      board: List.filled(42, null),
      gameOver: false,
      isDraw: false,
    );

    final connect4Game = GameEntity(
      id: 'game2',
      lobbyId: 'lobby2',
      gameType: GameType.connect4,
      status: GameStatus.inProgress,
      currentPlayerId: 'user1',
      players: [testPlayer1, testPlayer2],
      state: connect4GameState,
      startedAt: DateTime(2024),
    );

    blocTest<GameCubit, GameState>(
      'handles Connect4 moves correctly',
      build: () {
        cubit.setCurrentUserId('user1');
        when(mockMakeMoveUseCase(
          gameId: anyNamed('gameId'),
          position: anyNamed('position'),
        )).thenAnswer((_) async => const Right(null));
        return cubit;
      },
      seed: () => GameLoaded(connect4Game),
      act: (cubit) => cubit.makeMove(3), // Drop in column 3
      expect: () => [
        predicate<GameLoaded>((state) {
          return state.isPerformingAction == true &&
              state.game.gameType == GameType.connect4;
        }),
        predicate<GameLoaded>((state) => state.isPerformingAction == false),
      ],
      verify: (_) {
        verify(mockMakeMoveUseCase(gameId: 'game2', position: 3)).called(1);
      },
    );

    blocTest<GameCubit, GameState>(
      'does not make Connect4 move in full column',
      build: () {
        cubit.setCurrentUserId('user1');
        // Create a full column (column 0)
        final fullColumnBoard = List<String?>.filled(42, null);
        for (int row = 0; row < 6; row++) {
          fullColumnBoard[row * 7 + 0] = row % 2 == 0 ? 'X' : 'O';
        }
        final fullColumnState = Connect4GameStateEntity(
          board: fullColumnBoard,
          gameOver: false,
          isDraw: false,
        );
        final gameWithFullColumn = connect4Game.copyWith(state: fullColumnState);
        return cubit;
      },
      seed: () {
        final fullColumnBoard = List<String?>.filled(42, null);
        for (int row = 0; row < 6; row++) {
          fullColumnBoard[row * 7 + 0] = row % 2 == 0 ? 'X' : 'O';
        }
        return GameLoaded(connect4Game.copyWith(
          state: Connect4GameStateEntity(
            board: fullColumnBoard,
            gameOver: false,
            isDraw: false,
          ),
        ));
      },
      act: (cubit) => cubit.makeMove(0), // Try to drop in full column
      expect: () => [],
      verify: (_) {
        verifyNever(mockMakeMoveUseCase(
          gameId: anyNamed('gameId'),
          position: anyNamed('position'),
        ));
      },
    );
  });

  group('Complete Game Journey', () {
    test('watch game -> make moves -> game over flow', () async {
      // Setup: Stream emits game updates
      final gameController = StreamController<GameEntity>();

      when(mockWatchGameUseCase(any)).thenAnswer((_) => gameController.stream);

      cubit.setCurrentUserId('user1');
      cubit.watchGame('game1');

      // Wait for loading state
      await Future.delayed(const Duration(milliseconds: 10));

      // Game starts
      gameController.add(testGame);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(cubit.state, isA<GameLoaded>());
      expect((cubit.state as GameLoaded).game.currentPlayerId, 'user1');

      // Player makes move
      when(mockMakeMoveUseCase(gameId: anyNamed('gameId'), position: anyNamed('position')))
          .thenAnswer((_) async => const Right(null));

      await cubit.makeMove(0);
      await Future.delayed(const Duration(milliseconds: 10));

      // Verify move was made
      verify(mockMakeMoveUseCase(gameId: 'game1', position: 0)).called(1);

      // Game updates via stream (player 2's turn)
      final gameAfterMove = testGame.copyWith(
        currentPlayerId: 'user2',
        state: const TicTacToeGameStateEntity(
          board: ['X', null, null, null, null, null, null, null, null],
          gameOver: false,
          isDraw: false,
        ),
      );
      gameController.add(gameAfterMove);
      await Future.delayed(const Duration(milliseconds: 10));

      expect((cubit.state as GameLoaded).game.currentPlayerId, 'user2');

      // Game ends
      final gameOver = gameAfterMove.copyWith(
        state: const TicTacToeGameStateEntity(
          board: ['X', 'X', 'X', 'O', 'O', null, null, null, null],
          gameOver: true,
          winner: 'X',
          isDraw: false,
        ),
        winnerId: 'user1',
        status: GameStatus.completed,
      );
      gameController.add(gameOver);
      await Future.delayed(const Duration(milliseconds: 10));

      expect((cubit.state as GameLoaded).game.isOver, true);

      gameController.close();
    });
  });
}


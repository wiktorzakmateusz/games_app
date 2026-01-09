import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/game/domain/entities/game_entity.dart';
import 'package:games_app/features/game/domain/entities/game_player_entity.dart';
import 'package:games_app/features/game/domain/entities/game_state_entity.dart';
import 'package:games_app/features/game/domain/usecases/start_game_usecase.dart';
import 'package:games_app/features/lobby/domain/entities/lobby_entity.dart';
import 'package:games_app/features/lobby/domain/entities/lobby_player_entity.dart';
import 'package:games_app/features/lobby/domain/usecases/leave_lobby_usecase.dart';
import 'package:games_app/features/lobby/domain/usecases/toggle_ready_usecase.dart';
import 'package:games_app/features/lobby/domain/usecases/update_game_type_usecase.dart';
import 'package:games_app/features/lobby/domain/usecases/watch_lobby_usecase.dart';
import 'package:games_app/features/lobby/presentation/cubit/lobby_waiting_cubit.dart';
import 'package:games_app/features/lobby/presentation/cubit/lobby_waiting_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'lobby_waiting_cubit_test.mocks.dart';

/// Integration tests for LobbyWaitingCubit
///
/// These tests verify that the Cubit correctly orchestrates
/// multiple use cases and handles state transitions
@GenerateMocks([
  WatchLobbyUseCase,
  LeaveLobbyUseCase,
  ToggleReadyUseCase,
  UpdateGameTypeUseCase,
  StartGameUseCase,
])
void main() {
  late LobbyWaitingCubit cubit;
  late MockWatchLobbyUseCase mockWatchLobbyUseCase;
  late MockLeaveLobbyUseCase mockLeaveLobbyUseCase;
  late MockToggleReadyUseCase mockToggleReadyUseCase;
  late MockUpdateGameTypeUseCase mockUpdateGameTypeUseCase;
  late MockStartGameUseCase mockStartGameUseCase;

  final testPlayer1 = LobbyPlayerEntity(
    userId: 'user1',
    username: 'player1',
    displayName: 'Player One',
    isReady: false,
    joinedAt: DateTime(2024),
  );

  final testPlayer2 = LobbyPlayerEntity(
    userId: 'user2',
    username: 'player2',
    displayName: 'Player Two',
    isReady: false,
    joinedAt: DateTime(2024),
  );

  final testLobby = LobbyEntity(
    id: 'lobby1',
    name: 'Test Lobby',
    ownerId: 'user1',
    maxPlayers: 2,
    status: LobbyStatus.waiting,
    gameType: GameType.ticTacToe,
    players: [testPlayer1, testPlayer2],
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    mockWatchLobbyUseCase = MockWatchLobbyUseCase();
    mockLeaveLobbyUseCase = MockLeaveLobbyUseCase();
    mockToggleReadyUseCase = MockToggleReadyUseCase();
    mockUpdateGameTypeUseCase = MockUpdateGameTypeUseCase();
    mockStartGameUseCase = MockStartGameUseCase();

    cubit = LobbyWaitingCubit(
      watchLobbyUseCase: mockWatchLobbyUseCase,
      leaveLobbyUseCase: mockLeaveLobbyUseCase,
      toggleReadyUseCase: mockToggleReadyUseCase,
      updateGameTypeUseCase: mockUpdateGameTypeUseCase,
      startGameUseCase: mockStartGameUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('Watch Lobby Flow', () {
    blocTest<LobbyWaitingCubit, LobbyWaitingState>(
      'emits [LobbyWaitingLoading, LobbyWaitingLoaded] when watch succeeds',
      build: () {
        when(mockWatchLobbyUseCase(any)).thenAnswer(
          (_) => Stream.value(testLobby),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchLobby('lobby1'),
      expect: () => [
        const LobbyWaitingLoading(),
        LobbyWaitingLoaded(testLobby),
      ],
      verify: (_) {
        verify(mockWatchLobbyUseCase('lobby1')).called(1);
      },
    );

    blocTest<LobbyWaitingCubit, LobbyWaitingState>(
      'emits [LobbyWaitingLoading, LobbyWaitingError] when watch fails',
      build: () {
        when(mockWatchLobbyUseCase(any)).thenAnswer(
          (_) => Stream.error('Failed to load lobby'),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchLobby('lobby1'),
      expect: () => [
        const LobbyWaitingLoading(),
        const LobbyWaitingError(
          'Failed to load lobby: Failed to load lobby',
        ),
      ],
    );

    blocTest<LobbyWaitingCubit, LobbyWaitingState>(
      'updates state when lobby stream emits new data',
      build: () {
        final lobbyWithReadyPlayer = testLobby.togglePlayerReady('user1');
        when(mockWatchLobbyUseCase(any)).thenAnswer(
          (_) => Stream.fromIterable([testLobby, lobbyWithReadyPlayer]),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchLobby('lobby1'),
      expect: () => [
        const LobbyWaitingLoading(),
        LobbyWaitingLoaded(testLobby),
        LobbyWaitingLoaded(testLobby.togglePlayerReady('user1')),
      ],
    );

    blocTest<LobbyWaitingCubit, LobbyWaitingState>(
      'does not watch lobby again if already watching same lobby',
      build: () {
        when(mockWatchLobbyUseCase(any)).thenAnswer(
          (_) => Stream.value(testLobby),
        );
        cubit.watchLobby('lobby1');
        return cubit;
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 50));
        cubit.watchLobby('lobby1'); // Try to watch again
      },
      skip: 2, // Skip initial loading and loaded from first watchLobby
      expect: () => [],
      verify: (_) {
        verify(mockWatchLobbyUseCase('lobby1')).called(1); // Only called once
      },
    );

    blocTest<LobbyWaitingCubit, LobbyWaitingState>(
      'emits GameStarting when lobby status changes to inGame without gameId',
      build: () {
        final lobbyInGame = testLobby.copyWith(
          status: LobbyStatus.inGame,
        );
        when(mockWatchLobbyUseCase(any)).thenAnswer(
          (_) => Stream.fromIterable([testLobby, lobbyInGame]),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchLobby('lobby1'),
      expect: () => [
        const LobbyWaitingLoading(),
        LobbyWaitingLoaded(testLobby),
        const GameStarting(),
      ],
    );

    blocTest<LobbyWaitingCubit, LobbyWaitingState>(
      'emits GameStarted when lobby status changes to inGame with gameId',
      build: () {
        final lobbyInGame = testLobby.copyWith(
          status: LobbyStatus.inGame,
          gameId: 'game123',
        );
        when(mockWatchLobbyUseCase(any)).thenAnswer(
          (_) => Stream.fromIterable([testLobby, lobbyInGame]),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchLobby('lobby1'),
      expect: () => [
        const LobbyWaitingLoading(),
        LobbyWaitingLoaded(testLobby),
        const GameStarted('game123'),
      ],
    );
  });

  group('Toggle Ready Flow', () {
    test('performs optimistic update and calls use case', () async {
      cubit.setCurrentUserId('user1');
      when(mockToggleReadyUseCase(any)).thenAnswer(
        (_) async => const Right(null),
      );
      when(mockWatchLobbyUseCase(any)).thenAnswer(
        (_) => Stream.value(testLobby),
      );
      
      cubit.watchLobby('lobby1');
      await Future.delayed(const Duration(milliseconds: 50));
      
      await cubit.toggleReady();
      await Future.delayed(const Duration(milliseconds: 50));
      
      verify(mockToggleReadyUseCase('lobby1')).called(1);
    });

    test('rollsback on failure', () async {
      cubit.setCurrentUserId('user1');
      when(mockToggleReadyUseCase(any)).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to toggle ready')),
      );
      when(mockWatchLobbyUseCase(any)).thenAnswer(
        (_) => Stream.value(testLobby),
      );
      
      cubit.watchLobby('lobby1');
      await Future.delayed(const Duration(milliseconds: 50));
      
      await cubit.toggleReady();
      await Future.delayed(const Duration(milliseconds: 150));
      
      // Should have emitted error and returned to loaded
      expect(cubit.state, isA<LobbyWaitingLoaded>());
      verify(mockToggleReadyUseCase('lobby1')).called(1);
    });

    blocTest<LobbyWaitingCubit, LobbyWaitingState>(
      'does not toggle when not in LobbyWaitingLoaded state',
      build: () {
        cubit.setCurrentUserId('user1');
        return cubit;
      },
      act: (cubit) => cubit.toggleReady(),
      expect: () => [],
      verify: (_) {
        verifyNever(mockToggleReadyUseCase(any));
      },
    );
  });

  group('Leave Lobby Flow', () {
    test('emits LobbyLeft when leave succeeds', () async {
      when(mockLeaveLobbyUseCase(any)).thenAnswer(
        (_) async => const Right(null),
      );
      when(mockWatchLobbyUseCase(any)).thenAnswer(
        (_) => Stream.value(testLobby),
      );
      
      cubit.watchLobby('lobby1');
      await Future.delayed(const Duration(milliseconds: 50));
      
      await cubit.leaveLobby();
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(cubit.state, const LobbyLeft());
      verify(mockLeaveLobbyUseCase('lobby1')).called(1);
    });

    test('emits error when leave fails', () async {
      when(mockLeaveLobbyUseCase(any)).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to leave lobby')),
      );
      when(mockWatchLobbyUseCase(any)).thenAnswer(
        (_) => Stream.value(testLobby),
      );
      
      cubit.watchLobby('lobby1');
      await Future.delayed(const Duration(milliseconds: 50));
      
      await cubit.leaveLobby();
      await Future.delayed(const Duration(milliseconds: 150));
      
      // Should have emitted error and returned to loaded
      expect(cubit.state, isA<LobbyWaitingLoaded>());
      verify(mockLeaveLobbyUseCase('lobby1')).called(1);
    });

    blocTest<LobbyWaitingCubit, LobbyWaitingState>(
      'does not leave when not in LobbyWaitingLoaded state',
      build: () => cubit,
      act: (cubit) => cubit.leaveLobby(),
      expect: () => [],
      verify: (_) {
        verifyNever(mockLeaveLobbyUseCase(any));
      },
    );
  });

  group('Start Game Flow', () {
    final testGame = GameEntity(
      id: 'game123',
      lobbyId: 'lobby1',
      gameType: GameType.ticTacToe,
      status: GameStatus.inProgress,
      currentPlayerId: 'user1',
      players: const [
        GamePlayerEntity(
          userId: 'user1',
          username: 'player1',
          displayName: 'Player One',
          symbol: 'X',
        ),
        GamePlayerEntity(
          userId: 'user2',
          username: 'player2',
          displayName: 'Player Two',
          symbol: 'O',
        ),
      ],
      state: const TicTacToeGameStateEntity(
        board: [null, null, null, null, null, null, null, null, null],
        gameOver: false,
        isDraw: false,
      ),
      startedAt: DateTime(2024),
    );

    test('emits GameStarted when start succeeds', () async {
      when(mockStartGameUseCase(any)).thenAnswer(
        (_) async => Right(testGame),
      );
      when(mockWatchLobbyUseCase(any)).thenAnswer(
        (_) => Stream.value(testLobby),
      );
      
      cubit.watchLobby('lobby1');
      await Future.delayed(const Duration(milliseconds: 50));
      
      await cubit.startGame();
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(cubit.state, const GameStarted('game123'));
      verify(mockStartGameUseCase('lobby1')).called(1);
    });

    test('emits error when start game fails', () async {
      when(mockStartGameUseCase(any)).thenAnswer(
        (_) async => const Left(ServerFailure('Not all players ready')),
      );
      when(mockWatchLobbyUseCase(any)).thenAnswer(
        (_) => Stream.value(testLobby),
      );
      
      cubit.watchLobby('lobby1');
      await Future.delayed(const Duration(milliseconds: 50));
      
      await cubit.startGame();
      await Future.delayed(const Duration(milliseconds: 150));
      
      // Should have emitted error and returned to loaded
      expect(cubit.state, isA<LobbyWaitingLoaded>());
      verify(mockStartGameUseCase('lobby1')).called(1);
    });

    blocTest<LobbyWaitingCubit, LobbyWaitingState>(
      'does not start game when not in LobbyWaitingLoaded state',
      build: () => cubit,
      act: (cubit) => cubit.startGame(),
      expect: () => [],
      verify: (_) {
        verifyNever(mockStartGameUseCase(any));
      },
    );
  });

  group('Update Game Type Flow', () {
    test('updates game type successfully', () async {
      when(mockUpdateGameTypeUseCase(any, any)).thenAnswer(
        (_) async => const Right(null),
      );
      when(mockWatchLobbyUseCase(any)).thenAnswer(
        (_) => Stream.value(testLobby),
      );
      
      cubit.watchLobby('lobby1');
      await Future.delayed(const Duration(milliseconds: 50));
      
      await cubit.updateGameType(GameType.connect4);
      await Future.delayed(const Duration(milliseconds: 50));
      
      verify(mockUpdateGameTypeUseCase('lobby1', GameType.connect4)).called(1);
    });

    test('emits error when update game type fails', () async {
      when(mockUpdateGameTypeUseCase(any, any)).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to update game type')),
      );
      when(mockWatchLobbyUseCase(any)).thenAnswer(
        (_) => Stream.value(testLobby),
      );
      
      cubit.watchLobby('lobby1');
      await Future.delayed(const Duration(milliseconds: 50));
      
      await cubit.updateGameType(GameType.connect4);
      await Future.delayed(const Duration(milliseconds: 150));
      
      // Should have emitted error and returned to loaded
      expect(cubit.state, isA<LobbyWaitingLoaded>());
      verify(mockUpdateGameTypeUseCase('lobby1', GameType.connect4)).called(1);
    });

    test('handles game type update from stream correctly', () async {
      final lobbyWithConnect4 = testLobby.copyWith(gameType: GameType.connect4);
      when(mockWatchLobbyUseCase('lobby1')).thenAnswer(
        (_) => Stream.value(testLobby),
      );
      when(mockWatchLobbyUseCase('lobby2')).thenAnswer(
        (_) => Stream.value(lobbyWithConnect4),
      );
      when(mockUpdateGameTypeUseCase(any, any)).thenAnswer(
        (_) async => const Right(null),
      );
      
      cubit.watchLobby('lobby1');
      await Future.delayed(const Duration(milliseconds: 50));
      
      await cubit.updateGameType(GameType.connect4);
      await Future.delayed(const Duration(milliseconds: 50));
      
      cubit.watchLobby('lobby2');
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect((cubit.state as LobbyWaitingLoaded).lobby.gameType, GameType.connect4);
    });
  });

  group('Complete Lobby Journey', () {
    test('watch lobby -> players ready -> start game flow', () async {
      // Setup: Stream emits lobby updates
      final lobbyController = StreamController<LobbyEntity>();

      when(mockWatchLobbyUseCase(any)).thenAnswer((_) => lobbyController.stream);

      cubit.setCurrentUserId('user1');
      cubit.watchLobby('lobby1');

      // Wait for loading state
      await Future.delayed(const Duration(milliseconds: 10));

      // Lobby starts
      lobbyController.add(testLobby);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(cubit.state, isA<LobbyWaitingLoaded>());

      // Player 1 toggles ready
      when(mockToggleReadyUseCase(any))
          .thenAnswer((_) async => const Right(null));

      await cubit.toggleReady();
      await Future.delayed(const Duration(milliseconds: 10));

      // Verify toggle was called
      verify(mockToggleReadyUseCase('lobby1')).called(1);

      // Lobby updates via stream (player 1 ready)
      final lobbyWithPlayer1Ready = testLobby.togglePlayerReady('user1');
      lobbyController.add(lobbyWithPlayer1Ready);
      await Future.delayed(const Duration(milliseconds: 10));

      // Player 2 gets ready
      final lobbyWithBothReady = lobbyWithPlayer1Ready.togglePlayerReady('user2');
      lobbyController.add(lobbyWithBothReady);
      await Future.delayed(const Duration(milliseconds: 10));

      expect((cubit.state as LobbyWaitingLoaded).lobby.allPlayersReady, true);

      // Start game
      final testGame = GameEntity(
        id: 'game123',
        lobbyId: 'lobby1',
        gameType: GameType.ticTacToe,
        status: GameStatus.inProgress,
        currentPlayerId: 'user1',
        players: const [
          GamePlayerEntity(
            userId: 'user1',
            username: 'player1',
            displayName: 'Player One',
            symbol: 'X',
          ),
        ],
        state: const TicTacToeGameStateEntity(
          board: [null, null, null, null, null, null, null, null, null],
          gameOver: false,
          isDraw: false,
        ),
        startedAt: DateTime(2024),
      );

      when(mockStartGameUseCase(any)).thenAnswer((_) async => Right(testGame));

      await cubit.startGame();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, isA<GameStarted>());
      expect((cubit.state as GameStarted).gameId, 'game123');

      lobbyController.close();
    });
  });
}


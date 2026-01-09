import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/lobby/domain/entities/lobby_entity.dart';
import 'package:games_app/features/lobby/domain/entities/lobby_player_entity.dart';
import 'package:games_app/features/lobby/domain/usecases/create_lobby_usecase.dart';
import 'package:games_app/features/lobby/domain/usecases/join_lobby_usecase.dart';
import 'package:games_app/features/lobby/domain/usecases/watch_available_lobbies_usecase.dart';
import 'package:games_app/features/lobby/presentation/cubit/lobby_list_cubit.dart';
import 'package:games_app/features/lobby/presentation/cubit/lobby_list_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'lobby_list_cubit_test.mocks.dart';

/// Integration tests for LobbyListCubit
///
/// These tests verify that the Cubit correctly orchestrates
/// multiple use cases and handles state transitions
@GenerateMocks([
  WatchAvailableLobbiesUseCase,
  CreateLobbyUseCase,
  JoinLobbyUseCase,
])
void main() {
  late LobbyListCubit cubit;
  late MockWatchAvailableLobbiesUseCase mockWatchAvailableLobbiesUseCase;
  late MockCreateLobbyUseCase mockCreateLobbyUseCase;
  late MockJoinLobbyUseCase mockJoinLobbyUseCase;

  final testPlayer = LobbyPlayerEntity(
    userId: 'user1',
    username: 'player1',
    displayName: 'Player One',
    isReady: false,
    joinedAt: DateTime(2024),
  );

  final testLobby1 = LobbyEntity(
    id: 'lobby1',
    name: 'Test Lobby 1',
    ownerId: 'user1',
    maxPlayers: 2,
    status: LobbyStatus.waiting,
    gameType: GameType.ticTacToe,
    players: [testPlayer],
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  final testLobby2 = LobbyEntity(
    id: 'lobby2',
    name: 'Test Lobby 2',
    ownerId: 'user2',
    maxPlayers: 4,
    status: LobbyStatus.waiting,
    gameType: GameType.connect4,
    players: [
      LobbyPlayerEntity(
        userId: 'user2',
        username: 'player2',
        displayName: 'Player Two',
        isReady: false,
        joinedAt: DateTime(2024),
      ),
    ],
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    mockWatchAvailableLobbiesUseCase = MockWatchAvailableLobbiesUseCase();
    mockCreateLobbyUseCase = MockCreateLobbyUseCase();
    mockJoinLobbyUseCase = MockJoinLobbyUseCase();

    cubit = LobbyListCubit(
      watchAvailableLobbiesUseCase: mockWatchAvailableLobbiesUseCase,
      createLobbyUseCase: mockCreateLobbyUseCase,
      joinLobbyUseCase: mockJoinLobbyUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('Watch Available Lobbies Flow', () {
    blocTest<LobbyListCubit, LobbyListState>(
      'emits [LobbyListLoading, LobbyListLoaded] when watch succeeds',
      build: () {
        when(mockWatchAvailableLobbiesUseCase()).thenAnswer(
          (_) => Stream.value([testLobby1, testLobby2]),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchLobbies(),
      expect: () => [
        const LobbyListLoading(),
        LobbyListLoaded([testLobby1, testLobby2]),
      ],
      verify: (_) {
        verify(mockWatchAvailableLobbiesUseCase()).called(1);
      },
    );

    blocTest<LobbyListCubit, LobbyListState>(
      'emits [LobbyListLoading, LobbyListError] when watch fails',
      build: () {
        when(mockWatchAvailableLobbiesUseCase()).thenAnswer(
          (_) => Stream.error('Failed to load lobbies'),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchLobbies(),
      expect: () => [
        const LobbyListLoading(),
        const LobbyListError('Failed to load lobbies: Failed to load lobbies'),
      ],
    );

    blocTest<LobbyListCubit, LobbyListState>(
      'emits empty list when no lobbies available',
      build: () {
        when(mockWatchAvailableLobbiesUseCase()).thenAnswer(
          (_) => Stream.value([]),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchLobbies(),
      expect: () => [
        const LobbyListLoading(),
        const LobbyListLoaded([]),
      ],
    );

    blocTest<LobbyListCubit, LobbyListState>(
      'updates state when lobbies stream emits new data',
      build: () {
        when(mockWatchAvailableLobbiesUseCase()).thenAnswer(
          (_) => Stream.fromIterable([
            [testLobby1],
            [testLobby1, testLobby2],
            [testLobby2], // Lobby 1 removed
          ]),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchLobbies(),
      expect: () => [
        const LobbyListLoading(),
        LobbyListLoaded([testLobby1]),
        LobbyListLoaded([testLobby1, testLobby2]),
        LobbyListLoaded([testLobby2]),
      ],
    );
  });

  group('Create Lobby Flow', () {
    blocTest<LobbyListCubit, LobbyListState>(
      'emits [LobbyListLoaded with action, LobbyCreated] when create succeeds',
      build: () {
        when(mockCreateLobbyUseCase(
          name: anyNamed('name'),
          gameType: anyNamed('gameType'),
          maxPlayers: anyNamed('maxPlayers'),
        )).thenAnswer((_) async => Right(testLobby1));
        return cubit;
      },
      seed: () => LobbyListLoaded([testLobby2]),
      act: (cubit) => cubit.createLobby(
        name: 'Test Lobby 1',
        gameType: GameType.ticTacToe,
        maxPlayers: 2,
      ),
      expect: () => [
        LobbyListLoaded([testLobby2], isPerformingAction: true),
        LobbyCreated(testLobby1),
      ],
      verify: (_) {
        verify(mockCreateLobbyUseCase(
          name: 'Test Lobby 1',
          gameType: GameType.ticTacToe,
          maxPlayers: 2,
        )).called(1);
      },
    );

    blocTest<LobbyListCubit, LobbyListState>(
      'emits error when create fails',
      build: () {
        when(mockCreateLobbyUseCase(
          name: anyNamed('name'),
          gameType: anyNamed('gameType'),
          maxPlayers: anyNamed('maxPlayers'),
        )).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to create lobby')),
        );
        return cubit;
      },
      seed: () => const LobbyListLoaded([]),
      act: (cubit) => cubit.createLobby(
        name: 'Test Lobby',
        gameType: GameType.ticTacToe,
        maxPlayers: 2,
      ),
      expect: () => [
        const LobbyListLoaded([], isPerformingAction: true),
        const LobbyListLoaded([], isPerformingAction: false),
        const LobbyListError('Failed to create lobby'),
      ],
    );

    blocTest<LobbyListCubit, LobbyListState>(
      'does not create lobby when not in LobbyListLoaded state',
      build: () => cubit,
      act: (cubit) => cubit.createLobby(
        name: 'Test Lobby',
        gameType: GameType.ticTacToe,
        maxPlayers: 2,
      ),
      expect: () => [],
      verify: (_) {
        verifyNever(mockCreateLobbyUseCase(
          name: anyNamed('name'),
          gameType: anyNamed('gameType'),
          maxPlayers: anyNamed('maxPlayers'),
        ));
      },
    );

    blocTest<LobbyListCubit, LobbyListState>(
      'returns to loaded state after error timeout',
      build: () {
        when(mockCreateLobbyUseCase(
          name: anyNamed('name'),
          gameType: anyNamed('gameType'),
          maxPlayers: anyNamed('maxPlayers'),
        )).thenAnswer(
          (_) async => const Left(ServerFailure('Failed')),
        );
        return cubit;
      },
      seed: () => const LobbyListLoaded([]),
      act: (cubit) async {
        await cubit.createLobby(
          name: 'Test',
          gameType: GameType.ticTacToe,
          maxPlayers: 2,
        );
        // Wait for the timeout
        await Future.delayed(const Duration(milliseconds: 150));
      },
      expect: () => [
        const LobbyListLoaded([], isPerformingAction: true),
        const LobbyListLoaded([], isPerformingAction: false),
        const LobbyListError('Failed'),
        const LobbyListLoaded([]),
      ],
    );
  });

  group('Join Lobby Flow', () {
    blocTest<LobbyListCubit, LobbyListState>(
      'emits [LobbyListLoaded with action, LobbyJoined] when join succeeds',
      build: () {
        when(mockJoinLobbyUseCase(any)).thenAnswer(
          (_) async => const Right(null),
        );
        return cubit;
      },
      seed: () => LobbyListLoaded([testLobby1, testLobby2]),
      act: (cubit) => cubit.joinLobby('lobby1'),
      expect: () => [
        LobbyListLoaded([testLobby1, testLobby2], isPerformingAction: true),
        const LobbyJoined('lobby1'),
      ],
      verify: (_) {
        verify(mockJoinLobbyUseCase('lobby1')).called(1);
      },
    );

    blocTest<LobbyListCubit, LobbyListState>(
      'emits error when join fails',
      build: () {
        when(mockJoinLobbyUseCase(any)).thenAnswer(
          (_) async => const Left(ServerFailure('Lobby is full')),
        );
        return cubit;
      },
      seed: () => LobbyListLoaded([testLobby1]),
      act: (cubit) => cubit.joinLobby('lobby1'),
      expect: () => [
        LobbyListLoaded([testLobby1], isPerformingAction: true),
        LobbyListLoaded([testLobby1], isPerformingAction: false),
        const LobbyListError('Lobby is full'),
      ],
    );

    blocTest<LobbyListCubit, LobbyListState>(
      'does not join lobby when not in LobbyListLoaded state',
      build: () => cubit,
      act: (cubit) => cubit.joinLobby('lobby1'),
      expect: () => [],
      verify: (_) {
        verifyNever(mockJoinLobbyUseCase(any));
      },
    );

    blocTest<LobbyListCubit, LobbyListState>(
      'returns to loaded state after join error timeout',
      build: () {
        when(mockJoinLobbyUseCase(any)).thenAnswer(
          (_) async => const Left(ServerFailure('Failed')),
        );
        return cubit;
      },
      seed: () => LobbyListLoaded([testLobby1]),
      act: (cubit) async {
        await cubit.joinLobby('lobby1');
        // Wait for the timeout
        await Future.delayed(const Duration(milliseconds: 150));
      },
      expect: () => [
        LobbyListLoaded([testLobby1], isPerformingAction: true),
        LobbyListLoaded([testLobby1], isPerformingAction: false),
        const LobbyListError('Failed'),
        LobbyListLoaded([testLobby1]),
      ],
    );
  });

  group('Retry Flow', () {
    test('retries watching lobbies after error', () async {
      when(mockWatchAvailableLobbiesUseCase()).thenAnswer(
        (_) => Stream.value([testLobby1]),
      );
      
      cubit.watchLobbies();
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(cubit.state, isA<LobbyListLoaded>());
      
      cubit.retry();
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(cubit.state, isA<LobbyListLoaded>());
      verify(mockWatchAvailableLobbiesUseCase()).called(2); // Initial + retry
    });
  });

  group('Multiple Lobby Types', () {
    final ticTacToeLobby = testLobby1;
    final connect4Lobby = testLobby2;

    blocTest<LobbyListCubit, LobbyListState>(
      'loads lobbies with different game types',
      build: () {
        when(mockWatchAvailableLobbiesUseCase()).thenAnswer(
          (_) => Stream.value([ticTacToeLobby, connect4Lobby]),
        );
        return cubit;
      },
      act: (cubit) => cubit.watchLobbies(),
      expect: () => [
        const LobbyListLoading(),
        LobbyListLoaded([ticTacToeLobby, connect4Lobby]),
      ],
      verify: (_) {
        final state = cubit.state as LobbyListLoaded;
        expect(state.lobbies.length, 2);
        expect(state.lobbies[0].gameType, GameType.ticTacToe);
        expect(state.lobbies[1].gameType, GameType.connect4);
      },
    );

    blocTest<LobbyListCubit, LobbyListState>(
      'can create lobbies with different game types',
      build: () {
        when(mockCreateLobbyUseCase(
          name: anyNamed('name'),
          gameType: anyNamed('gameType'),
          maxPlayers: anyNamed('maxPlayers'),
        )).thenAnswer((_) async => Right(connect4Lobby));
        return cubit;
      },
      seed: () => const LobbyListLoaded([]),
      act: (cubit) => cubit.createLobby(
        name: 'Connect 4 Room',
        gameType: GameType.connect4,
        maxPlayers: 4,
      ),
      expect: () => [
        const LobbyListLoaded([], isPerformingAction: true),
        LobbyCreated(connect4Lobby),
      ],
      verify: (_) {
        verify(mockCreateLobbyUseCase(
          name: 'Connect 4 Room',
          gameType: GameType.connect4,
          maxPlayers: 4,
        )).called(1);
      },
    );
  });

  group('Complete Lobby List Journey', () {
    test('watch lobbies -> create lobby -> join lobby flow', () async {
      // Setup: Stream emits lobby updates
      final lobbiesController = StreamController<List<LobbyEntity>>();

      when(mockWatchAvailableLobbiesUseCase())
          .thenAnswer((_) => lobbiesController.stream);

      cubit.watchLobbies();

      // Wait for loading state
      await Future.delayed(const Duration(milliseconds: 10));

      // Initial empty list
      lobbiesController.add([]);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(cubit.state, isA<LobbyListLoaded>());
      expect((cubit.state as LobbyListLoaded).lobbies, isEmpty);

      // Create a lobby
      when(mockCreateLobbyUseCase(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenAnswer((_) async => Right(testLobby1));

      await cubit.createLobby(
        name: 'Test Lobby 1',
        gameType: GameType.ticTacToe,
        maxPlayers: 2,
      );
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, isA<LobbyCreated>());

      // Lobbies update via stream (new lobby appears)
      lobbiesController.add([testLobby1]);
      await Future.delayed(const Duration(milliseconds: 10));

      // Note: After LobbyCreated, stream updates cause state to be LobbyListLoaded
      // Another lobby appears
      lobbiesController.add([testLobby1, testLobby2]);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, isA<LobbyListLoaded>());
      expect((cubit.state as LobbyListLoaded).lobbies.length, 2);

      // Join second lobby
      when(mockJoinLobbyUseCase(any)).thenAnswer((_) async => const Right(null));

      await cubit.joinLobby('lobby2');
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, isA<LobbyJoined>());
      expect((cubit.state as LobbyJoined).lobbyId, 'lobby2');

      verify(mockCreateLobbyUseCase(
        name: 'Test Lobby 1',
        gameType: GameType.ticTacToe,
        maxPlayers: 2,
      )).called(1);
      verify(mockJoinLobbyUseCase('lobby2')).called(1);

      lobbiesController.close();
    });
  });
}


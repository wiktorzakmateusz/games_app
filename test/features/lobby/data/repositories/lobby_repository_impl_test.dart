import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/exceptions.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/lobby/data/datasources/lobby_firestore_datasource.dart';
import 'package:games_app/features/lobby/data/datasources/lobby_remote_datasource.dart';
import 'package:games_app/features/lobby/data/repositories/lobby_repository_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'lobby_repository_impl_test.mocks.dart';

@GenerateMocks([LobbyRemoteDataSource, LobbyFirestoreDataSource])
void main() {
  late LobbyRepositoryImpl repository;
  late MockLobbyRemoteDataSource mockRemoteDataSource;
  late MockLobbyFirestoreDataSource mockFirestoreDataSource;

  setUp(() {
    mockRemoteDataSource = MockLobbyRemoteDataSource();
    mockFirestoreDataSource = MockLobbyFirestoreDataSource();
    repository = LobbyRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      firestoreDataSource: mockFirestoreDataSource,
    );
  });

  final testLobbyJson = {
    'id': 'lobby1',
    'name': 'Test Lobby',
    'ownerId': 'user1',
    'maxPlayers': 2,
    'status': 'WAITING',
    'gameType': 'TIC_TAC_TOE',
    'players': [
      {
        'userId': 'user1',
        'username': 'player_one',
        'displayName': 'Player One',
        'photoURL': null,
        'isReady': false,
        'joinedAt': '2024-01-01T10:00:00Z',
      }
    ],
    'gameId': null,
    'createdAt': '2024-01-01T10:00:00Z',
    'updatedAt': '2024-01-01T10:00:00Z',
  };

  group('createLobby', () {
    const testName = 'Test Lobby';
    const testGameType = GameType.ticTacToe;
    const testMaxPlayers = 2;

    test('should return LobbyEntity when remote call succeeds', () async {
      // Arrange
      when(mockRemoteDataSource.createLobby(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenAnswer((_) async => testLobbyJson);

      // Act
      final result = await repository.createLobby(
        name: testName,
        gameType: testGameType,
        maxPlayers: testMaxPlayers,
      );

      // Assert
      expect(result.isRight(), true);
      final lobby = result.getOrElse(() => throw Exception());
      expect(lobby.id, 'lobby1');
      expect(lobby.name, testName);
      expect(lobby.gameType, testGameType);
      expect(lobby.maxPlayers, testMaxPlayers);
      verify(mockRemoteDataSource.createLobby(
        name: testName,
        gameType: testGameType,
        maxPlayers: testMaxPlayers,
      )).called(1);
    });

    test('should return ServerFailure when ServerException occurs', () async {
      // Arrange
      when(mockRemoteDataSource.createLobby(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenThrow(ServerException('Failed to create lobby', 500));

      // Act
      final result = await repository.createLobby(
        name: testName,
        gameType: testGameType,
        maxPlayers: testMaxPlayers,
      );

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'Failed to create lobby');
      expect(failure.statusCode, 500);
    });

    test('should return NetworkFailure when NetworkException occurs',
        () async {
      // Arrange
      when(mockRemoteDataSource.createLobby(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenThrow(NetworkException('No internet connection'));

      // Act
      final result = await repository.createLobby(
        name: testName,
        gameType: testGameType,
        maxPlayers: testMaxPlayers,
      );

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<NetworkFailure>());
    });

    test('should return UnexpectedFailure on generic exception', () async {
      // Arrange
      when(mockRemoteDataSource.createLobby(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenThrow(Exception('Unknown error'));

      // Act
      final result = await repository.createLobby(
        name: testName,
        gameType: testGameType,
        maxPlayers: testMaxPlayers,
      );

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<UnexpectedFailure>());
    });
  });

  group('joinLobby', () {
    const testLobbyId = 'lobby1';

    test('should complete successfully when remote call succeeds', () async {
      // Arrange
      when(mockRemoteDataSource.joinLobby(any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.joinLobby(testLobbyId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRemoteDataSource.joinLobby(testLobbyId)).called(1);
    });

    test('should return ServerFailure when lobby is full', () async {
      // Arrange
      when(mockRemoteDataSource.joinLobby(any))
          .thenThrow(ServerException('Lobby is full', 400));

      // Act
      final result = await repository.joinLobby(testLobbyId);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'Lobby is full');
    });

    test('should return NetworkFailure on NetworkException', () async {
      // Arrange
      when(mockRemoteDataSource.joinLobby(any))
          .thenThrow(NetworkException('Connection timeout'));

      // Act
      final result = await repository.joinLobby(testLobbyId);

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<NetworkFailure>());
    });
  });

  group('leaveLobby', () {
    const testLobbyId = 'lobby1';

    test('should complete successfully', () async {
      // Arrange
      when(mockRemoteDataSource.leaveLobby(any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.leaveLobby(testLobbyId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRemoteDataSource.leaveLobby(testLobbyId)).called(1);
    });

    test('should return ServerFailure on error', () async {
      // Arrange
      when(mockRemoteDataSource.leaveLobby(any))
          .thenThrow(ServerException('Failed to leave', 500));

      // Act
      final result = await repository.leaveLobby(testLobbyId);

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('toggleReady', () {
    const testLobbyId = 'lobby1';

    test('should complete successfully', () async {
      // Arrange
      when(mockRemoteDataSource.toggleReady(any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.toggleReady(testLobbyId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRemoteDataSource.toggleReady(testLobbyId)).called(1);
    });

    test('should return ServerFailure when not in lobby', () async {
      // Arrange
      when(mockRemoteDataSource.toggleReady(any))
          .thenThrow(ServerException('Not a member of this lobby', 403));

      // Act
      final result = await repository.toggleReady(testLobbyId);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 403);
    });

    test('should return NetworkFailure on NetworkException', () async {
      // Arrange
      when(mockRemoteDataSource.toggleReady(any))
          .thenThrow(NetworkException('Network error'));

      // Act
      final result = await repository.toggleReady(testLobbyId);

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<NetworkFailure>());
    });
  });

  group('updateGameType', () {
    const testLobbyId = 'lobby1';
    const testGameType = GameType.connect4;

    test('should complete successfully', () async {
      // Arrange
      when(mockRemoteDataSource.updateGameType(any, any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.updateGameType(testLobbyId, testGameType);

      // Assert
      expect(result.isRight(), true);
      verify(mockRemoteDataSource.updateGameType(testLobbyId, testGameType))
          .called(1);
    });

    test('should return ServerFailure when not owner', () async {
      // Arrange
      when(mockRemoteDataSource.updateGameType(any, any))
          .thenThrow(ServerException('Only owner can change game type', 403));

      // Act
      final result = await repository.updateGameType(testLobbyId, testGameType);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
    });

    test('should handle all game types', () async {
      // Arrange
      when(mockRemoteDataSource.updateGameType(any, any))
          .thenAnswer((_) async => Future.value());

      // Act & Assert
      for (final gameType in [
        GameType.ticTacToe,
        GameType.connect4,
      ]) {
        final result = await repository.updateGameType(testLobbyId, gameType);
        expect(result.isRight(), true);
      }
    });
  });

  group('getLobby', () {
    const testLobbyId = 'lobby1';

    test('should return LobbyEntity when successful', () async {
      // Arrange
      when(mockRemoteDataSource.getLobby(any))
          .thenAnswer((_) async => testLobbyJson);

      // Act
      final result = await repository.getLobby(testLobbyId);

      // Assert
      expect(result.isRight(), true);
      final lobby = result.getOrElse(() => throw Exception());
      expect(lobby.id, testLobbyId);
      verify(mockRemoteDataSource.getLobby(testLobbyId)).called(1);
    });

    test('should return ServerFailure when lobby not found', () async {
      // Arrange
      when(mockRemoteDataSource.getLobby(any))
          .thenThrow(ServerException('Lobby not found', 404));

      // Act
      final result = await repository.getLobby(testLobbyId);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 404);
    });
  });

  group('getCurrentUserLobby', () {
    test('should return LobbyEntity when user is in a lobby', () async {
      // Arrange
      when(mockRemoteDataSource.getCurrentUserLobby())
          .thenAnswer((_) async => testLobbyJson);

      // Act
      final result = await repository.getCurrentUserLobby();

      // Assert
      expect(result.isRight(), true);
      final lobby = result.getOrElse(() => throw Exception());
      expect(lobby, isNotNull);
      expect(lobby!.id, 'lobby1');
    });

    test('should return null when user is not in a lobby', () async {
      // Arrange
      when(mockRemoteDataSource.getCurrentUserLobby())
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getCurrentUserLobby();

      // Assert
      expect(result.isRight(), true);
      final lobby = result.getOrElse(() => throw Exception());
      expect(lobby, isNull);
    });

    test('should return ServerFailure on error', () async {
      // Arrange
      when(mockRemoteDataSource.getCurrentUserLobby())
          .thenThrow(ServerException('Server error', 500));

      // Act
      final result = await repository.getCurrentUserLobby();

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('watchLobby', () {
    const testLobbyId = 'lobby1';

    test('should emit LobbyEntity when Firestore stream emits data', () async {
      // Arrange
      when(mockFirestoreDataSource.watchLobby(any))
          .thenAnswer((_) => Stream.value(testLobbyJson));

      // Act
      final stream = repository.watchLobby(testLobbyId);

      // Assert
      await expectLater(
        stream,
        emits(predicate<dynamic>((lobby) => lobby.id == 'lobby1')),
      );
      verify(mockFirestoreDataSource.watchLobby(testLobbyId)).called(1);
    });

    test('should emit updated lobby when player joins', () async {
      // Arrange
      final lobby1 = testLobbyJson;
      final lobby2 = {
        ...testLobbyJson,
        'players': [
          ...testLobbyJson['players'] as List,
          {
            'userId': 'user2',
            'username': 'player_two',
            'displayName': 'Player Two',
            'photoURL': null,
            'isReady': false,
            'joinedAt': '2024-01-01T10:05:00Z',
          }
        ],
      };

      when(mockFirestoreDataSource.watchLobby(any))
          .thenAnswer((_) => Stream.fromIterable([lobby1, lobby2]));

      // Act
      final stream = repository.watchLobby(testLobbyId);

      // Assert
      await expectLater(
        stream,
        emitsInOrder([
          predicate<dynamic>((lobby) => lobby.players.length == 1),
          predicate<dynamic>((lobby) => lobby.players.length == 2),
        ]),
      );
    });

    test('should emit updated lobby when ready status changes', () async {
      // Arrange
      final lobby1 = testLobbyJson;
      final lobby2 = {
        ...testLobbyJson,
        'players': [
          {
            ...((testLobbyJson['players'] as List)[0] as Map<String, dynamic>),
            'isReady': true,
          }
        ],
      };

      when(mockFirestoreDataSource.watchLobby(any))
          .thenAnswer((_) => Stream.fromIterable([lobby1, lobby2]));

      // Act
      final stream = repository.watchLobby(testLobbyId);

      // Assert
      await expectLater(
        stream,
        emitsInOrder([
          predicate<dynamic>((lobby) => lobby.players[0].isReady == false),
          predicate<dynamic>((lobby) => lobby.players[0].isReady == true),
        ]),
      );
    });

    test('should handle Firestore stream errors', () async {
      // Arrange
      when(mockFirestoreDataSource.watchLobby(any))
          .thenAnswer((_) => Stream.error(Exception('Firestore error')));

      // Act
      final stream = repository.watchLobby(testLobbyId);

      // Assert
      await expectLater(stream, emitsError(isA<Exception>()));
    });
  });

  group('watchAvailableLobbies', () {
    test('should emit list of lobbies', () async {
      // Arrange
      final lobby2Json = {
        ...testLobbyJson,
        'id': 'lobby2',
        'name': 'Another Lobby',
      };

      when(mockFirestoreDataSource.watchAvailableLobbies())
          .thenAnswer((_) => Stream.value([testLobbyJson, lobby2Json]));

      // Act
      final stream = repository.watchAvailableLobbies();

      // Assert
      await expectLater(
        stream,
        emits(predicate<List<dynamic>>((lobbies) => lobbies.length == 2)),
      );
    });

    test('should emit empty list when no lobbies available', () async {
      // Arrange
      when(mockFirestoreDataSource.watchAvailableLobbies())
          .thenAnswer((_) => Stream.value([]));

      // Act
      final stream = repository.watchAvailableLobbies();

      // Assert
      await expectLater(
        stream,
        emits(predicate<List<dynamic>>((lobbies) => lobbies.isEmpty)),
      );
    });

    test('should emit updates when lobbies change', () async {
      // Arrange
      when(mockFirestoreDataSource.watchAvailableLobbies()).thenAnswer(
        (_) => Stream.fromIterable([
          [testLobbyJson],
          [],
          [testLobbyJson, {...testLobbyJson, 'id': 'lobby2'}],
        ]),
      );

      // Act
      final stream = repository.watchAvailableLobbies();

      // Assert
      await expectLater(
        stream,
        emitsInOrder([
          predicate<List<dynamic>>((lobbies) => lobbies.length == 1),
          predicate<List<dynamic>>((lobbies) => lobbies.isEmpty),
          predicate<List<dynamic>>((lobbies) => lobbies.length == 2),
        ]),
      );
    });

    test('should handle stream errors', () async {
      // Arrange
      when(mockFirestoreDataSource.watchAvailableLobbies())
          .thenAnswer((_) => Stream.error(Exception('Network error')));

      // Act
      final stream = repository.watchAvailableLobbies();

      // Assert
      await expectLater(stream, emitsError(isA<Exception>()));
    });
  });

  group('Integration scenarios', () {
    test('should handle complete lobby lifecycle', () async {
      // Arrange - Create lobby
      when(mockRemoteDataSource.createLobby(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenAnswer((_) async => testLobbyJson);

      // Arrange - Toggle ready
      when(mockRemoteDataSource.toggleReady(any))
          .thenAnswer((_) async => Future.value());

      // Arrange - Leave lobby
      when(mockRemoteDataSource.leaveLobby(any))
          .thenAnswer((_) async => Future.value());

      // Act & Assert - Create
      final createResult = await repository.createLobby(
        name: 'Test',
        gameType: GameType.ticTacToe,
        maxPlayers: 2,
      );
      expect(createResult.isRight(), true);

      // Act & Assert - Toggle ready
      final readyResult = await repository.toggleReady('lobby1');
      expect(readyResult.isRight(), true);

      // Act & Assert - Leave
      final leaveResult = await repository.leaveLobby('lobby1');
      expect(leaveResult.isRight(), true);

      verify(mockRemoteDataSource.createLobby(
        name: 'Test',
        gameType: GameType.ticTacToe,
        maxPlayers: 2,
      )).called(1);
      verify(mockRemoteDataSource.toggleReady('lobby1')).called(1);
      verify(mockRemoteDataSource.leaveLobby('lobby1')).called(1);
    });
  });
}


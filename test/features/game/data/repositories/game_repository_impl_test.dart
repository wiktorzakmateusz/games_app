import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/exceptions.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/game/data/datasources/game_firestore_datasource.dart';
import 'package:games_app/features/game/data/datasources/game_remote_datasource.dart';
import 'package:games_app/features/game/data/models/game_model.dart';
import 'package:games_app/features/game/data/repositories/game_repository_impl.dart';
import 'package:games_app/features/game/domain/entities/game_player_entity.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'game_repository_impl_test.mocks.dart';

@GenerateMocks([GameRemoteDataSource, GameFirestoreDataSource])
void main() {
  late GameRepositoryImpl repository;
  late MockGameRemoteDataSource mockRemoteDataSource;
  late MockGameFirestoreDataSource mockFirestoreDataSource;

  setUp(() {
    mockRemoteDataSource = MockGameRemoteDataSource();
    mockFirestoreDataSource = MockGameFirestoreDataSource();
    repository = GameRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      firestoreDataSource: mockFirestoreDataSource,
    );
  });

  final testGameJson = {
    'id': 'game1',
    'lobbyId': 'lobby1',
    'gameType': 'TIC_TAC_TOE',
    'status': 'IN_PROGRESS',
    'currentPlayerId': 'player1',
    'players': [
      {
        'userId': 'player1',
        'username': 'player_one',
        'displayName': 'Player One',
        'symbol': 'X',
      },
      {
        'userId': 'player2',
        'username': 'player_two',
        'displayName': 'Player Two',
        'symbol': 'O',
      }
    ],
    'state': {
      'board': [null, null, null, null, null, null, null, null, null],
      'gameOver': false,
      'isDraw': false,
    },
    'startedAt': '2024-01-01T10:00:00Z',
  };

  group('startGame', () {
    const testLobbyId = 'lobby1';

    test('should return GameEntity when remote call is successful', () async {
      // Arrange
      when(mockRemoteDataSource.startGame(any))
          .thenAnswer((_) async => testGameJson);

      // Act
      final result = await repository.startGame(testLobbyId);

      // Assert
      expect(result.isRight(), true);
      final game = result.getOrElse(() => throw Exception());
      expect(game.id, 'game1');
      expect(game.lobbyId, testLobbyId);
      verify(mockRemoteDataSource.startGame(testLobbyId)).called(1);
    });

    test('should return ServerFailure when remote throws ServerException',
            () async {
          // Arrange
          when(mockRemoteDataSource.startGame(any))
              .thenThrow(ServerException('Server error', 500));

          // Act
          final result = await repository.startGame(testLobbyId);

          // Assert
          expect(result.isLeft(), true);
          expect(
            result.fold((l) => l, (r) => null),
            isA<ServerFailure>(),
          );
        });

    test('should return NetworkFailure when remote throws NetworkException',
            () async {
          // Arrange
          when(mockRemoteDataSource.startGame(any))
              .thenThrow(NetworkException('No connection'));

          // Act
          final result = await repository.startGame(testLobbyId);

          // Assert
          expect(result.isLeft(), true);
          expect(
            result.fold((l) => l, (r) => null),
            isA<NetworkFailure>(),
          );
        });
  });

  group('makeMove', () {
    const testGameId = 'game1';
    const testPosition = 4;

    test('should complete successfully when remote call succeeds', () async {
      // Arrange
      when(mockRemoteDataSource.makeMove(
        gameId: anyNamed('gameId'),
        position: anyNamed('position'),
      )).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.makeMove(
        gameId: testGameId,
        position: testPosition,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRemoteDataSource.makeMove(
        gameId: testGameId,
        position: testPosition,
      )).called(1);
    });

    test('should return failure when move is invalid', () async {
      // Arrange
      when(mockRemoteDataSource.makeMove(
        gameId: anyNamed('gameId'),
        position: anyNamed('position'),
      )).thenThrow(ServerException('Invalid move', 400));

      // Act
      final result = await repository.makeMove(
        gameId: testGameId,
        position: testPosition,
      );

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 400);
    });
  });

  group('watchGame', () {
    const testGameId = 'game1';

    test('should emit GameEntity when Firestore stream emits data', () async {
      // Arrange
      when(mockFirestoreDataSource.watchGame(any))
          .thenAnswer((_) => Stream.value(testGameJson));

      // Act
      final stream = repository.watchGame(testGameId);

      // Assert
      await expectLater(
        stream,
        emits(predicate<dynamic>((game) => game.id == 'game1')),
      );
      verify(mockFirestoreDataSource.watchGame(testGameId)).called(1);
    });

    test('should handle Firestore stream errors', () async {
      // Arrange
      when(mockFirestoreDataSource.watchGame(any))
          .thenAnswer((_) => Stream.error(Exception('Firestore error')));

      // Act
      final stream = repository.watchGame(testGameId);

      // Assert
      await expectLater(
        stream,
        emitsError(isA<Exception>()),
      );
    });

    test('should emit updated game state when state changes', () async {
      // Arrange
      final game1 = {...testGameJson};
      final game2 = {
        ...testGameJson,
        'state': {
          'board': ['X', null, null, null, null, null, null, null, null],
          'gameOver': false,
          'isDraw': false,
        },
      };

      when(mockFirestoreDataSource.watchGame(any))
          .thenAnswer((_) => Stream.fromIterable([game1, game2]));

      // Act
      final stream = repository.watchGame(testGameId);

      // Assert
      await expectLater(
        stream,
        emitsInOrder([
          predicate<dynamic>((game) {
            final state = game.state;
            return state.board[0] == null;
          }),
          predicate<dynamic>((game) {
            final state = game.state;
            return state.board[0] == 'X';
          }),
        ]),
      );
    });
  });

  group('abandonGame', () {
    const testGameId = 'game1';

    test('should complete successfully', () async {
      // Arrange
      when(mockRemoteDataSource.abandonGame(any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.abandonGame(testGameId);

      // Assert
      expect(result.isRight(), true);
      verify(mockRemoteDataSource.abandonGame(testGameId)).called(1);
    });

    test('should return ServerFailure on error', () async {
      // Arrange
      when(mockRemoteDataSource.abandonGame(any))
          .thenThrow(ServerException('Failed to abandon', 500));

      // Act
      final result = await repository.abandonGame(testGameId);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('Integration scenarios', () {
    test('should handle rapid successive moves', () async {
      // Arrange
      when(mockRemoteDataSource.makeMove(
        gameId: anyNamed('gameId'),
        position: anyNamed('position'),
      )).thenAnswer((_) async => Future.value());

      // Act
      final results = await Future.wait([
        repository.makeMove(gameId: 'game1', position: 0),
        repository.makeMove(gameId: 'game1', position: 1),
        repository.makeMove(gameId: 'game1', position: 2),
      ]);

      // Assert
      expect(results.every((r) => r.isRight()), true);
      verify(mockRemoteDataSource.makeMove(
        gameId: 'game1',
        position: anyNamed('position'),
      )).called(3);
    });
  });
}
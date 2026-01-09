import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/lobby/domain/entities/lobby_entity.dart';
import 'package:games_app/features/lobby/domain/entities/lobby_player_entity.dart';
import 'package:games_app/features/lobby/domain/repositories/lobby_repository.dart';
import 'package:games_app/features/lobby/domain/usecases/create_lobby_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_lobby_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([LobbyRepository])
void main() {
  late CreateLobbyUseCase usecase;
  late MockLobbyRepository mockRepository;

  setUp(() {
    mockRepository = MockLobbyRepository();
    usecase = CreateLobbyUseCase(mockRepository);
  });

  const testLobbyName = 'Test Lobby';
  const testGameType = GameType.ticTacToe;
  const testMaxPlayers = 2;
  final testLobby = LobbyEntity(
    id: 'lobby123',
    name: testLobbyName,
    ownerId: 'user1',
    gameType: testGameType,
    maxPlayers: testMaxPlayers,
    players: [
      LobbyPlayerEntity(
        userId: 'user1',
        username: 'player1',
        displayName: 'Player One',
        isReady: false,
        joinedAt: DateTime(2024),
      ),
    ],
    status: LobbyStatus.waiting,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  group('CreateLobbyUseCase', () {
    test('should return LobbyEntity when lobby is created successfully', () async {
      // Arrange
      when(mockRepository.createLobby(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenAnswer((_) async => Right(testLobby));

      // Act
      final result = await usecase(
        name: testLobbyName,
        gameType: testGameType,
        maxPlayers: testMaxPlayers,
      );

      // Assert
      expect(result, Right(testLobby));
      verify(mockRepository.createLobby(
        name: testLobbyName,
        gameType: testGameType,
        maxPlayers: testMaxPlayers,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when lobby name is empty', () async {
      // Arrange
      const failure = ValidationFailure('Lobby name cannot be empty');
      when(mockRepository.createLobby(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        name: '',
        gameType: testGameType,
        maxPlayers: testMaxPlayers,
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ValidationFailure when max players is invalid', () async {
      // Arrange
      const failure = ValidationFailure('Invalid number of players');
      when(mockRepository.createLobby(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        name: testLobbyName,
        gameType: testGameType,
        maxPlayers: 0,
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Failed to create lobby');
      when(mockRepository.createLobby(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        name: testLobbyName,
        gameType: testGameType,
        maxPlayers: testMaxPlayers,
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.createLobby(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        name: testLobbyName,
        gameType: testGameType,
        maxPlayers: testMaxPlayers,
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      when(mockRepository.createLobby(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenAnswer((_) async => Right(testLobby));

      // Act
      await usecase(
        name: testLobbyName,
        gameType: testGameType,
        maxPlayers: testMaxPlayers,
      );

      // Assert
      final captured = verify(mockRepository.createLobby(
        name: captureAnyNamed('name'),
        gameType: captureAnyNamed('gameType'),
        maxPlayers: captureAnyNamed('maxPlayers'),
      )).captured;

      expect(captured[0], testLobbyName);
      expect(captured[1], testGameType);
      expect(captured[2], testMaxPlayers);
    });

    test('should create lobby for Connect4 game type', () async {
      // Arrange
      final connect4Lobby = testLobby.copyWith(gameType: GameType.connect4);
      when(mockRepository.createLobby(
        name: anyNamed('name'),
        gameType: anyNamed('gameType'),
        maxPlayers: anyNamed('maxPlayers'),
      )).thenAnswer((_) async => Right(connect4Lobby));

      // Act
      final result = await usecase(
        name: testLobbyName,
        gameType: GameType.connect4,
        maxPlayers: testMaxPlayers,
      );

      // Assert
      expect(result.isRight(), true);
    });
  });
}


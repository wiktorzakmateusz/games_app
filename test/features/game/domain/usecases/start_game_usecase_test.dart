import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/game/domain/entities/game_entity.dart';
import 'package:games_app/features/game/domain/entities/game_player_entity.dart';
import 'package:games_app/features/game/domain/entities/game_state_entity.dart';
import 'package:games_app/features/game/domain/repositories/game_repository.dart';
import 'package:games_app/features/game/domain/usecases/start_game_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'start_game_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([GameRepository])
void main() {
  late StartGameUseCase usecase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    usecase = StartGameUseCase(mockRepository);
  });

  const testLobbyId = 'lobby123';
  final testPlayers = [
    const GamePlayerEntity(
      userId: 'user1',
      username: 'player1',
      displayName: 'Player One',
      symbol: 'X',
    ),
    const GamePlayerEntity(
      userId: 'user2',
      username: 'player2',
      displayName: 'Player Two',
      symbol: 'O',
    ),
  ];
  final testGame = GameEntity(
    id: 'game123',
    lobbyId: testLobbyId,
    gameType: GameType.ticTacToe,
    status: GameStatus.inProgress,
    currentPlayerId: 'user1',
    players: testPlayers,
    state: const TicTacToeGameStateEntity(
      board: [null, null, null, null, null, null, null, null, null],
      gameOver: false,
      isDraw: false,
    ),
    startedAt: DateTime(2024),
  );

  group('StartGameUseCase', () {
    test('should return GameEntity when game starts successfully', () async {
      // Arrange
      when(mockRepository.startGame(any))
          .thenAnswer((_) async => Right(testGame));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, Right(testGame));
      verify(mockRepository.startGame(testLobbyId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Failed to start game');
      when(mockRepository.startGame(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.startGame(testLobbyId)).called(1);
    });

    test('should return ValidationFailure when lobby is invalid', () async {
      // Arrange
      const failure = ValidationFailure('Lobby not ready to start');
      when(mockRepository.startGame(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.startGame(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct lobby ID to repository', () async {
      // Arrange
      when(mockRepository.startGame(any))
          .thenAnswer((_) async => Right(testGame));

      // Act
      await usecase(testLobbyId);

      // Assert
      final captured = verify(mockRepository.startGame(captureAny)).captured;
      expect(captured[0], testLobbyId);
    });
  });
}


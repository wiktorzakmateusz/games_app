import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/game/domain/repositories/game_repository.dart';
import 'package:games_app/features/game/domain/usecases/make_move_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'make_move_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([GameRepository])
void main() {
  late MakeMoveUseCase usecase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    usecase = MakeMoveUseCase(mockRepository);
  });

  const testGameId = 'game123';
  const testPosition = 4;

  group('MakeMoveUseCase', () {
    test('should complete successfully when move is valid', () async {
      // Arrange
      when(mockRepository.makeMove(
        gameId: anyNamed('gameId'),
        position: anyNamed('position'),
      )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(gameId: testGameId, position: testPosition);

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.makeMove(
        gameId: testGameId,
        position: testPosition,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when move is invalid', () async {
      // Arrange
      const failure = ValidationFailure('Invalid move position');
      when(mockRepository.makeMove(
        gameId: anyNamed('gameId'),
        position: anyNamed('position'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(gameId: testGameId, position: testPosition);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ValidationFailure when not player turn', () async {
      // Arrange
      const failure = ValidationFailure('Not your turn');
      when(mockRepository.makeMove(
        gameId: anyNamed('gameId'),
        position: anyNamed('position'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(gameId: testGameId, position: testPosition);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ValidationFailure when game is over', () async {
      // Arrange
      const failure = ValidationFailure('Game is already over');
      when(mockRepository.makeMove(
        gameId: anyNamed('gameId'),
        position: anyNamed('position'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(gameId: testGameId, position: testPosition);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Failed to make move');
      when(mockRepository.makeMove(
        gameId: anyNamed('gameId'),
        position: anyNamed('position'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(gameId: testGameId, position: testPosition);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.makeMove(
        gameId: anyNamed('gameId'),
        position: anyNamed('position'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(gameId: testGameId, position: testPosition);

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      when(mockRepository.makeMove(
        gameId: anyNamed('gameId'),
        position: anyNamed('position'),
      )).thenAnswer((_) async => const Right(null));

      // Act
      await usecase(gameId: testGameId, position: testPosition);

      // Assert
      final captured = verify(mockRepository.makeMove(
        gameId: captureAnyNamed('gameId'),
        position: captureAnyNamed('position'),
      )).captured;

      expect(captured[0], testGameId);
      expect(captured[1], testPosition);
    });

    test('should handle different position values correctly', () async {
      // Arrange
      when(mockRepository.makeMove(
        gameId: anyNamed('gameId'),
        position: anyNamed('position'),
      )).thenAnswer((_) async => const Right(null));

      // Act & Assert - Test boundary values
      await usecase(gameId: testGameId, position: 0);
      await usecase(gameId: testGameId, position: 8);
      await usecase(gameId: testGameId, position: 41); // Connect4 max

      verify(mockRepository.makeMove(
        gameId: testGameId,
        position: anyNamed('position'),
      )).called(3);
    });
  });
}


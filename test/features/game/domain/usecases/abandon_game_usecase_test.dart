import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/game/domain/repositories/game_repository.dart';
import 'package:games_app/features/game/domain/usecases/abandon_game_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'abandon_game_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([GameRepository])
void main() {
  late AbandonGameUseCase usecase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    usecase = AbandonGameUseCase(mockRepository);
  });

  const testGameId = 'game123';

  group('AbandonGameUseCase', () {
    test('should complete successfully when game is abandoned', () async {
      // Arrange
      when(mockRepository.abandonGame(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(testGameId);

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.abandonGame(testGameId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Failed to abandon game');
      when(mockRepository.abandonGame(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testGameId);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.abandonGame(testGameId)).called(1);
    });

    test('should return ValidationFailure when game does not exist', () async {
      // Arrange
      const failure = ValidationFailure('Game not found');
      when(mockRepository.abandonGame(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testGameId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ValidationFailure when game is already finished', () async {
      // Arrange
      const failure = ValidationFailure('Game already finished');
      when(mockRepository.abandonGame(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testGameId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.abandonGame(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testGameId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct game ID to repository', () async {
      // Arrange
      when(mockRepository.abandonGame(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      await usecase(testGameId);

      // Assert
      final captured = verify(mockRepository.abandonGame(captureAny)).captured;
      expect(captured[0], testGameId);
    });
  });
}


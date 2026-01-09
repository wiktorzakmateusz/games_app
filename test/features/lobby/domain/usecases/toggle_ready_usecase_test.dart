import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/lobby/domain/repositories/lobby_repository.dart';
import 'package:games_app/features/lobby/domain/usecases/toggle_ready_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'toggle_ready_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([LobbyRepository])
void main() {
  late ToggleReadyUseCase usecase;
  late MockLobbyRepository mockRepository;

  setUp(() {
    mockRepository = MockLobbyRepository();
    usecase = ToggleReadyUseCase(mockRepository);
  });

  const testLobbyId = 'lobby123';

  group('ToggleReadyUseCase', () {
    test('should complete successfully when toggling ready succeeds', () async {
      // Arrange
      when(mockRepository.toggleReady(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.toggleReady(testLobbyId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when not in lobby', () async {
      // Arrange
      const failure = ValidationFailure('Not in this lobby');
      when(mockRepository.toggleReady(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ValidationFailure when lobby does not exist', () async {
      // Arrange
      const failure = ValidationFailure('Lobby not found');
      when(mockRepository.toggleReady(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ValidationFailure when game already started', () async {
      // Arrange
      const failure = ValidationFailure('Game already started');
      when(mockRepository.toggleReady(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Failed to toggle ready status');
      when(mockRepository.toggleReady(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.toggleReady(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct lobby ID to repository', () async {
      // Arrange
      when(mockRepository.toggleReady(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      await usecase(testLobbyId);

      // Assert
      final captured = verify(mockRepository.toggleReady(captureAny)).captured;
      expect(captured[0], testLobbyId);
    });
  });
}


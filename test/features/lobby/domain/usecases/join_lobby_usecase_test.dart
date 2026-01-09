import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/lobby/domain/repositories/lobby_repository.dart';
import 'package:games_app/features/lobby/domain/usecases/join_lobby_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'join_lobby_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([LobbyRepository])
void main() {
  late JoinLobbyUseCase usecase;
  late MockLobbyRepository mockRepository;

  setUp(() {
    mockRepository = MockLobbyRepository();
    usecase = JoinLobbyUseCase(mockRepository);
  });

  const testLobbyId = 'lobby123';

  group('JoinLobbyUseCase', () {
    test('should complete successfully when joining lobby succeeds', () async {
      // Arrange
      when(mockRepository.joinLobby(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.joinLobby(testLobbyId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when lobby is full', () async {
      // Arrange
      const failure = ValidationFailure('Lobby is full');
      when(mockRepository.joinLobby(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ValidationFailure when lobby does not exist', () async {
      // Arrange
      const failure = ValidationFailure('Lobby not found');
      when(mockRepository.joinLobby(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ValidationFailure when already in lobby', () async {
      // Arrange
      const failure = ValidationFailure('Already in this lobby');
      when(mockRepository.joinLobby(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Failed to join lobby');
      when(mockRepository.joinLobby(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.joinLobby(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct lobby ID to repository', () async {
      // Arrange
      when(mockRepository.joinLobby(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      await usecase(testLobbyId);

      // Assert
      final captured = verify(mockRepository.joinLobby(captureAny)).captured;
      expect(captured[0], testLobbyId);
    });
  });
}


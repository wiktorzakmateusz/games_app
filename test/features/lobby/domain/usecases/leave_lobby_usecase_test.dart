import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/lobby/domain/repositories/lobby_repository.dart';
import 'package:games_app/features/lobby/domain/usecases/leave_lobby_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'leave_lobby_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([LobbyRepository])
void main() {
  late LeaveLobbyUseCase usecase;
  late MockLobbyRepository mockRepository;

  setUp(() {
    mockRepository = MockLobbyRepository();
    usecase = LeaveLobbyUseCase(mockRepository);
  });

  const testLobbyId = 'lobby123';

  group('LeaveLobbyUseCase', () {
    test('should complete successfully when leaving lobby succeeds', () async {
      // Arrange
      when(mockRepository.leaveLobby(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.leaveLobby(testLobbyId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when not in lobby', () async {
      // Arrange
      const failure = ValidationFailure('Not in this lobby');
      when(mockRepository.leaveLobby(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ValidationFailure when lobby does not exist', () async {
      // Arrange
      const failure = ValidationFailure('Lobby not found');
      when(mockRepository.leaveLobby(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Failed to leave lobby');
      when(mockRepository.leaveLobby(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.leaveLobby(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testLobbyId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct lobby ID to repository', () async {
      // Arrange
      when(mockRepository.leaveLobby(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      await usecase(testLobbyId);

      // Assert
      final captured = verify(mockRepository.leaveLobby(captureAny)).captured;
      expect(captured[0], testLobbyId);
    });
  });
}


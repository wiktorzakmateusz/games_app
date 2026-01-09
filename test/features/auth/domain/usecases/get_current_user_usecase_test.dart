import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/auth/domain/entities/user_entity.dart';
import 'package:games_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:games_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_current_user_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([AuthRepository])
void main() {
  late GetCurrentUserUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = GetCurrentUserUseCase(mockRepository);
  });

  final testUser = UserEntity(
    id: '1',
    firebaseUid: 'firebase_1',
    email: 'test@example.com',
    username: 'testuser',
    displayName: 'Test User',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  group('GetCurrentUserUseCase', () {
    test('should return UserEntity when user is logged in', () async {
      // Arrange
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(testUser));
      verify(mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return null when no user is logged in', () async {
      // Arrange
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right<Failure, UserEntity?>(null));
      verify(mockRepository.getCurrentUser()).called(1);
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Failed to get current user');
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
    });

    test('should return AuthFailure when authentication error occurs', () async {
      // Arrange
      const failure = AuthFailure('Authentication token expired');
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
    });
  });
}


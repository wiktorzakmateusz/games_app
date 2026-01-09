import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/auth/domain/entities/user_entity.dart';
import 'package:games_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:games_app/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_user_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([AuthRepository])
void main() {
  late UpdateUserUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = UpdateUserUseCase(mockRepository);
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

  group('UpdateUserUseCase', () {
    test('should return updated UserEntity when username update succeeds', () async {
      // Arrange
      final updatedUser = testUser.copyWith(username: 'newusername');
      when(mockRepository.updateUser(
        id: anyNamed('id'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenAnswer((_) async => Right(updatedUser));

      // Act
      final result = await usecase(
        id: '1',
        username: 'newusername',
      );

      // Assert
      expect(result, Right(updatedUser));
      verify(mockRepository.updateUser(
        id: '1',
        username: 'newusername',
        displayName: null,
        photoURL: null,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return updated UserEntity when display name update succeeds', () async {
      // Arrange
      final updatedUser = testUser.copyWith(displayName: 'New Display Name');
      when(mockRepository.updateUser(
        id: anyNamed('id'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenAnswer((_) async => Right(updatedUser));

      // Act
      final result = await usecase(
        id: '1',
        displayName: 'New Display Name',
      );

      // Assert
      expect(result, Right(updatedUser));
      verify(mockRepository.updateUser(
        id: '1',
        username: null,
        displayName: 'New Display Name',
        photoURL: null,
      )).called(1);
    });

    test('should return updated UserEntity when photo URL update succeeds', () async {
      // Arrange
      final updatedUser = testUser.copyWith(photoURL: 'https://example.com/photo.jpg');
      when(mockRepository.updateUser(
        id: anyNamed('id'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenAnswer((_) async => Right(updatedUser));

      // Act
      final result = await usecase(
        id: '1',
        photoURL: 'https://example.com/photo.jpg',
      );

      // Assert
      expect(result, Right(updatedUser));
    });

    test('should return updated UserEntity when multiple fields are updated', () async {
      // Arrange
      final updatedUser = testUser.copyWith(
        username: 'newusername',
        displayName: 'New Name',
        photoURL: 'https://example.com/photo.jpg',
      );
      when(mockRepository.updateUser(
        id: anyNamed('id'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenAnswer((_) async => Right(updatedUser));

      // Act
      final result = await usecase(
        id: '1',
        username: 'newusername',
        displayName: 'New Name',
        photoURL: 'https://example.com/photo.jpg',
      );

      // Assert
      expect(result, Right(updatedUser));
    });

    test('should return AuthFailure when username is already taken', () async {
      // Arrange
      const failure = AuthFailure('Username already taken');
      when(mockRepository.updateUser(
        id: anyNamed('id'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        id: '1',
        username: 'takenusername',
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Failed to update user');
      when(mockRepository.updateUser(
        id: anyNamed('id'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        id: '1',
        username: 'newusername',
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.updateUser(
        id: anyNamed('id'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        id: '1',
        username: 'newusername',
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      final updatedUser = testUser.copyWith(username: 'newusername');
      when(mockRepository.updateUser(
        id: anyNamed('id'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenAnswer((_) async => Right(updatedUser));

      // Act
      await usecase(
        id: '1',
        username: 'newusername',
      );

      // Assert
      final captured = verify(mockRepository.updateUser(
        id: captureAnyNamed('id'),
        username: captureAnyNamed('username'),
        displayName: captureAnyNamed('displayName'),
        photoURL: captureAnyNamed('photoURL'),
      )).captured;

      expect(captured[0], '1');
      expect(captured[1], 'newusername');
      expect(captured[2], null);
      expect(captured[3], null);
    });
  });
}


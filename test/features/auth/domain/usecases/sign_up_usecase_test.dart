import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/auth/domain/entities/user_entity.dart';
import 'package:games_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:games_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sign_up_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([AuthRepository])
void main() {
  late SignUpUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignUpUseCase(mockRepository);
  });

  const testEmail = 'newuser@example.com';
  const testPassword = 'password123';
  const testUsername = 'newuser';
  final testUser = UserEntity(
    id: '1',
    firebaseUid: 'firebase_1',
    email: testEmail,
    username: testUsername,
    displayName: 'New User',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  group('SignUpUseCase', () {
    test('should return UserEntity when sign up is successful', () async {
      // Arrange
      when(mockRepository.signUpWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        username: anyNamed('username'),
      )).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await usecase(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      expect(result, Right(testUser));
      verify(mockRepository.signUpWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when email is already in use', () async {
      // Arrange
      const failure = AuthFailure('Email already in use');
      when(mockRepository.signUpWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        username: anyNamed('username'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.signUpWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      )).called(1);
    });

    test('should return AuthFailure when username is already taken', () async {
      // Arrange
      const failure = AuthFailure('Username already taken');
      when(mockRepository.signUpWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        username: anyNamed('username'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Server error occurred');
      when(mockRepository.signUpWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        username: anyNamed('username'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.signUpWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        username: anyNamed('username'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      when(mockRepository.signUpWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
        username: anyNamed('username'),
      )).thenAnswer((_) async => Right(testUser));

      // Act
      await usecase(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      final captured = verify(mockRepository.signUpWithEmailAndPassword(
        email: captureAnyNamed('email'),
        password: captureAnyNamed('password'),
        username: captureAnyNamed('username'),
      )).captured;

      expect(captured[0], testEmail);
      expect(captured[1], testPassword);
      expect(captured[2], testUsername);
    });
  });
}


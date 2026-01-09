import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/auth/domain/entities/user_entity.dart';
import 'package:games_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:games_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sign_in_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([AuthRepository])
void main() {
  late SignInUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignInUseCase(mockRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  final testUser = UserEntity(
    id: '1',
    firebaseUid: 'firebase_1',
    email: testEmail,
    username: 'testuser',
    displayName: 'Test User',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  group('SignInUseCase', () {
    test('should return UserEntity when sign in is successful', () async {
      // Arrange
      when(mockRepository.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await usecase(email: testEmail, password: testPassword);

      // Assert
      expect(result, Right(testUser));
      verify(mockRepository.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when sign in fails', () async {
      // Arrange
      const failure = ServerFailure('Invalid credentials');
      when(mockRepository.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(email: testEmail, password: testPassword);

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(email: testEmail, password: testPassword);

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      when(mockRepository.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(testUser));

      // Act
      await usecase(email: testEmail, password: testPassword);

      // Assert
      final captured = verify(mockRepository.signInWithEmailAndPassword(
        email: captureAnyNamed('email'),
        password: captureAnyNamed('password'),
      )).captured;

      expect(captured[0], testEmail);
      expect(captured[1], testPassword);
    });
  });
}
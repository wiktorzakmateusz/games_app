import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/auth/domain/entities/user_entity.dart';
import 'package:games_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:games_app/features/auth/domain/usecases/sign_in_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  final testUser = UserEntity(
    id: '1',
    firebaseUid: 'firebase123',
    email: 'test@example.com',
    username: 'testuser',
    displayName: 'Test User',
    photoURL: null,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  test('should call repository signInWithEmailAndPassword', () async {
    // Arrange
    when(() => mockRepository.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => Right(testUser));

    // Act
    final result = await useCase(
      email: 'test@example.com',
      password: 'password123',
    );

    // Assert
    expect(result, Right(testUser));
    verify(() => mockRepository.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    const failure = AuthFailure('Invalid credentials');
    when(() => mockRepository.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Left(failure));

    // Act
    final result = await useCase(
      email: 'test@example.com',
      password: 'wrongpassword',
    );

    // Assert
    expect(result, const Left(failure));
  });
}


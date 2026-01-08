import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/auth/domain/entities/user_entity.dart';
import 'package:games_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:games_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:games_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:games_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:games_app/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:games_app/features/auth/domain/usecases/watch_auth_state_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
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

  group('SignUpUseCase', () {
    late SignUpUseCase useCase;

    setUp(() {
      useCase = SignUpUseCase(mockRepository);
    });

    test('should call repository signUpWithEmailAndPassword', () async {
      // Arrange
      when(() => mockRepository.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            username: any(named: 'username'),
          )).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase(
        email: 'test@example.com',
        password: 'password123',
        username: 'testuser',
      );

      // Assert
      expect(result, Right(testUser));
      verify(() => mockRepository.signUpWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
            username: 'testuser',
          )).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = AuthFailure('Email already in use');
      when(() => mockRepository.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            username: any(named: 'username'),
          )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        email: 'test@example.com',
        password: 'password123',
        username: 'testuser',
      );

      // Assert
      expect(result, const Left(failure));
    });
  });

  group('SignOutUseCase', () {
    late SignOutUseCase useCase;

    setUp(() {
      useCase = SignOutUseCase(mockRepository);
    });

    test('should call repository signOut', () async {
      // Arrange
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.signOut()).called(1);
    });

    test('should return failure when sign out fails', () async {
      // Arrange
      const failure = ServerFailure('Sign out failed');
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(failure));
    });
  });

  group('GetCurrentUserUseCase', () {
    late GetCurrentUserUseCase useCase;

    setUp(() {
      useCase = GetCurrentUserUseCase(mockRepository);
    });

    test('should return user when user is logged in', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Right(testUser));
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('should return null when no user is logged in', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right<Failure, UserEntity?>(null));
    });
  });

  group('UpdateUserUseCase', () {
    late UpdateUserUseCase useCase;

    setUp(() {
      useCase = UpdateUserUseCase(mockRepository);
    });

    test('should call repository updateUser', () async {
      // Arrange
      final updatedUser = testUser.copyWith(username: 'newusername');
      when(() => mockRepository.updateUser(
            id: any(named: 'id'),
            username: any(named: 'username'),
            displayName: any(named: 'displayName'),
            photoURL: any(named: 'photoURL'),
          )).thenAnswer((_) async => Right(updatedUser));

      // Act
      final result = await useCase(
        id: '1',
        username: 'newusername',
      );

      // Assert
      expect(result, Right(updatedUser));
      verify(() => mockRepository.updateUser(
            id: '1',
            username: 'newusername',
            displayName: null,
            photoURL: null,
          )).called(1);
    });
  });

  group('WatchAuthStateUseCase', () {
    late WatchAuthStateUseCase useCase;

    setUp(() {
      useCase = WatchAuthStateUseCase(mockRepository);
    });

    test('should return stream from repository', () {
      // Arrange
      final stream = Stream<UserEntity?>.value(testUser);
      when(() => mockRepository.watchAuthState()).thenAnswer((_) => stream);

      // Act
      final result = useCase();

      // Assert
      expect(result, stream);
      verify(() => mockRepository.watchAuthState()).called(1);
    });

    test('should emit null when user logs out', () async {
      // Arrange
      final stream = Stream<UserEntity?>.value(null);
      when(() => mockRepository.watchAuthState()).thenAnswer((_) => stream);

      // Act
      final result = useCase();

      // Assert
      await expectLater(result, emits(null));
    });
  });
}


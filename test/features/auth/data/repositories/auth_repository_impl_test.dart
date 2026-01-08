import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:games_app/core/error/exceptions.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:games_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:games_app/features/auth/data/models/user_model.dart';
import 'package:games_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:games_app/features/auth/domain/entities/user_entity.dart';

// Mock classes
class MockAuthFirebaseDataSource extends Mock
    implements AuthFirebaseDataSource {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthFirebaseDataSource mockFirebaseDataSource;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  // Test data
  final mockFirebaseUser = MockFirebaseUser();
  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  const testUsername = 'testuser';
  const testFirebaseUid = 'firebase123';

  final testUserModel = UserModel(
    id: '1',
    firebaseUid: testFirebaseUid,
    email: testEmail,
    username: testUsername,
    displayName: 'Test User',
    photoURL: null,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockFirebaseDataSource = MockAuthFirebaseDataSource();
    mockRemoteDataSource = MockAuthRemoteDataSource();

    repository = AuthRepositoryImpl(
      firebaseDataSource: mockFirebaseDataSource,
      remoteDataSource: mockRemoteDataSource,
    );

    // Setup common mock firebase user properties
    when(() => mockFirebaseUser.uid).thenReturn(testFirebaseUid);
    when(() => mockFirebaseUser.email).thenReturn(testEmail);
    when(() => mockFirebaseUser.displayName).thenReturn('Test User');
    when(() => mockFirebaseUser.photoURL).thenReturn(null);
  });

  group('signInWithEmailAndPassword', () {
    test('returns UserEntity when sign in is successful and user exists in backend',
        () async {
      // Arrange
      when(() => mockFirebaseDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockFirebaseUser);

      when(() => mockRemoteDataSource.getUserByFirebaseUid(any()))
          .thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result, isA<Right<Failure, UserEntity>>());
      expect(result.fold((l) => null, (r) => r), isA<UserEntity>());
      expect(result.fold((l) => null, (r) => r.id), testUserModel.id);

      verify(() => mockFirebaseDataSource.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          )).called(1);
      verify(() => mockRemoteDataSource.getUserByFirebaseUid(testFirebaseUid))
          .called(1);
    });

    test(
        'creates user in backend when sign in succeeds but user does not exist',
        () async {
      // Arrange
      when(() => mockFirebaseDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockFirebaseUser);

      when(() => mockRemoteDataSource.getUserByFirebaseUid(any()))
          .thenThrow(CacheException('User not found'));

      when(() => mockRemoteDataSource.createUser(
            firebaseUid: any(named: 'firebaseUid'),
            email: any(named: 'email'),
            username: any(named: 'username'),
            displayName: any(named: 'displayName'),
            photoURL: any(named: 'photoURL'),
          )).thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result, isA<Right<Failure, UserEntity>>());

      verify(() => mockRemoteDataSource.createUser(
            firebaseUid: testFirebaseUid,
            email: testEmail,
            username: any(named: 'username'),
            displayName: any(named: 'displayName'),
            photoURL: null,
          )).called(1);
    });

    test('returns ServerFailure when Firebase sign in fails', () async {
      // Arrange
      when(() => mockFirebaseDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(ServerException('Invalid credentials'));

      // Act
      final result = await repository.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      expect(
        result.fold((l) => l, (r) => null),
        isA<ServerFailure>().having(
          (f) => f.message,
          'message',
          'Invalid credentials',
        ),
      );
    });
  });

  group('signUpWithEmailAndPassword', () {
    test('returns UserEntity when sign up is successful', () async {
      // Arrange
      when(() => mockFirebaseDataSource.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockFirebaseUser);

      when(() => mockRemoteDataSource.createUser(
            firebaseUid: any(named: 'firebaseUid'),
            email: any(named: 'email'),
            username: any(named: 'username'),
            displayName: any(named: 'displayName'),
            photoURL: any(named: 'photoURL'),
          )).thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.signUpWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      expect(result, isA<Right<Failure, UserEntity>>());
      expect(result.fold((l) => null, (r) => r), isA<UserEntity>());

      verify(() => mockFirebaseDataSource.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          )).called(1);

      verify(() => mockRemoteDataSource.createUser(
            firebaseUid: testFirebaseUid,
            email: testEmail,
            username: testUsername,
            displayName: testUsername,
            photoURL: null,
          )).called(1);
    });

    test('returns ServerFailure when Firebase user creation fails', () async {
      // Arrange
      when(() => mockFirebaseDataSource.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(ServerException('Email already in use'));

      // Act
      final result = await repository.signUpWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      expect(
        result.fold((l) => l, (r) => null),
        isA<ServerFailure>().having(
          (f) => f.message,
          'message',
          'Email already in use',
        ),
      );
    });

    test('returns ServerFailure when backend user creation fails', () async {
      // Arrange
      when(() => mockFirebaseDataSource.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockFirebaseUser);

      when(() => mockRemoteDataSource.createUser(
            firebaseUid: any(named: 'firebaseUid'),
            email: any(named: 'email'),
            username: any(named: 'username'),
            displayName: any(named: 'displayName'),
            photoURL: any(named: 'photoURL'),
          )).thenThrow(ServerException('Backend error'));

      // Act
      final result = await repository.signUpWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      expect(
        result.fold((l) => l, (r) => null),
        isA<ServerFailure>(),
      );
    });
  });

  group('signOut', () {
    test('returns Right(null) when sign out is successful', () async {
      // Arrange
      when(() => mockFirebaseDataSource.signOut())
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.signOut();

      // Assert
      expect(result, const Right(null));
      verify(() => mockFirebaseDataSource.signOut()).called(1);
    });

    test('returns ServerFailure when sign out fails', () async {
      // Arrange
      when(() => mockFirebaseDataSource.signOut())
          .thenThrow(ServerException('Sign out failed'));

      // Act
      final result = await repository.signOut();

      // Assert
      expect(result, isA<Left<Failure, void>>());
      expect(
        result.fold((l) => l, (r) => null),
        isA<ServerFailure>(),
      );
    });
  });

  group('getCurrentUser', () {
    test('returns UserEntity when user is logged in', () async {
      // Arrange
      when(() => mockFirebaseDataSource.getCurrentFirebaseUser())
          .thenReturn(mockFirebaseUser);

      when(() => mockRemoteDataSource.getUserByFirebaseUid(any()))
          .thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, isA<Right<Failure, UserEntity?>>());
      expect(result.fold((l) => null, (r) => r), isA<UserEntity>());

      verify(() => mockFirebaseDataSource.getCurrentFirebaseUser()).called(1);
      verify(() => mockRemoteDataSource.getUserByFirebaseUid(testFirebaseUid))
          .called(1);
    });

    test('returns Right(null) when no user is logged in', () async {
      // Arrange
      when(() => mockFirebaseDataSource.getCurrentFirebaseUser())
          .thenReturn(null);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, const Right<Failure, UserEntity?>(null));
      verify(() => mockFirebaseDataSource.getCurrentFirebaseUser()).called(1);
      verifyNever(() => mockRemoteDataSource.getUserByFirebaseUid(any()));
    });

    test('returns Right(null) when user not found in backend', () async {
      // Arrange
      when(() => mockFirebaseDataSource.getCurrentFirebaseUser())
          .thenReturn(mockFirebaseUser);

      when(() => mockRemoteDataSource.getUserByFirebaseUid(any()))
          .thenThrow(CacheException('User not found'));

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, const Right<Failure, UserEntity?>(null));
    });
  });

  group('updateUser', () {
    const updatedUsername = 'newusername';

    test('returns updated UserEntity when update is successful', () async {
      // Arrange
      final updatedUserModel = UserModel(
        id: testUserModel.id,
        firebaseUid: testUserModel.firebaseUid,
        email: testUserModel.email,
        username: updatedUsername,
        displayName: testUserModel.displayName,
        photoURL: testUserModel.photoURL,
        createdAt: testUserModel.createdAt,
        updatedAt: testUserModel.updatedAt,
      );

      when(() => mockRemoteDataSource.updateUser(
            id: any(named: 'id'),
            username: any(named: 'username'),
            displayName: any(named: 'displayName'),
            photoURL: any(named: 'photoURL'),
          )).thenAnswer((_) async => updatedUserModel);

      // Act
      final result = await repository.updateUser(
        id: '1',
        username: updatedUsername,
      );

      // Assert
      expect(result, isA<Right<Failure, UserEntity>>());
      expect(
        result.fold((l) => null, (r) => r.username),
        updatedUsername,
      );

      verify(() => mockRemoteDataSource.updateUser(
            id: '1',
            username: updatedUsername,
            displayName: null,
            photoURL: null,
          )).called(1);
    });

    test('returns ServerFailure when update fails', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateUser(
            id: any(named: 'id'),
            username: any(named: 'username'),
            displayName: any(named: 'displayName'),
            photoURL: any(named: 'photoURL'),
          )).thenThrow(ServerException('Update failed'));

      // Act
      final result = await repository.updateUser(
        id: '1',
        username: updatedUsername,
      );

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      expect(
        result.fold((l) => l, (r) => null),
        isA<ServerFailure>(),
      );
    });
  });

  group('getIdToken', () {
    const testToken = 'test_token_123';

    test('returns token when successful', () async {
      // Arrange
      when(() => mockFirebaseDataSource.getIdToken(
            forceRefresh: any(named: 'forceRefresh'),
          )).thenAnswer((_) async => testToken);

      // Act
      final result = await repository.getIdToken();

      // Assert
      expect(result, const Right<Failure, String>(testToken));
      verify(() => mockFirebaseDataSource.getIdToken(forceRefresh: false))
          .called(1);
    });

    test('returns ServerFailure when getting token fails', () async {
      // Arrange
      when(() => mockFirebaseDataSource.getIdToken(
            forceRefresh: any(named: 'forceRefresh'),
          )).thenThrow(ServerException('Failed to get token'));

      // Act
      final result = await repository.getIdToken();

      // Assert
      expect(result, isA<Left<Failure, String>>());
      expect(
        result.fold((l) => l, (r) => null),
        isA<ServerFailure>(),
      );
    });
  });

  group('watchAuthState', () {
    test('emits UserEntity when Firebase auth state emits user', () async {
      // Arrange
      when(() => mockFirebaseDataSource.watchAuthState())
          .thenAnswer((_) => Stream.value(mockFirebaseUser));

      when(() => mockRemoteDataSource.getUserByFirebaseUid(any()))
          .thenAnswer((_) async => testUserModel);

      // Act
      final stream = repository.watchAuthState();

      // Assert
      await expectLater(
        stream,
        emits(isA<UserEntity>()),
      );
    });

    test('emits null when Firebase auth state emits null', () async {
      // Arrange
      when(() => mockFirebaseDataSource.watchAuthState())
          .thenAnswer((_) => Stream.value(null));

      // Act
      final stream = repository.watchAuthState();

      // Assert
      await expectLater(stream, emits(null));
    });

    test('emits null when backend call fails', () async {
      // Arrange
      when(() => mockFirebaseDataSource.watchAuthState())
          .thenAnswer((_) => Stream.value(mockFirebaseUser));

      when(() => mockRemoteDataSource.getUserByFirebaseUid(any()))
          .thenThrow(ServerException('Backend error'));

      // Act
      final stream = repository.watchAuthState();

      // Assert
      await expectLater(stream, emits(null));
    });
  });
}


import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/exceptions.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:games_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:games_app/features/auth/data/models/user_model.dart';
import 'package:games_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([
  AuthFirebaseDataSource,
  AuthRemoteDataSource,
  firebase_auth.User,
])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthFirebaseDataSource mockFirebaseDataSource;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockUser mockFirebaseUser;

  setUp(() {
    mockFirebaseDataSource = MockAuthFirebaseDataSource();
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockFirebaseUser = MockUser();
    repository = AuthRepositoryImpl(
      firebaseDataSource: mockFirebaseDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final testUserJson = {
    'id': 'user1',
    'firebaseUid': 'firebase_uid_123',
    'email': 'test@example.com',
    'username': 'testuser',
    'displayName': 'Test User',
    'photoURL': 'https://example.com/photo.jpg',
    'createdAt': '2024-01-01T10:00:00Z',
    'updatedAt': '2024-01-01T10:00:00Z',
  };

  final testUserModel = UserModel.fromJson(testUserJson);

  group('signInWithEmailAndPassword', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    setUp(() {
      when(mockFirebaseUser.uid).thenReturn('firebase_uid_123');
      when(mockFirebaseUser.email).thenReturn(testEmail);
      when(mockFirebaseUser.displayName).thenReturn('Test User');
      when(mockFirebaseUser.photoURL).thenReturn(null);
    });

    test('should return UserEntity when user exists in backend', () async {
      // Arrange
      when(mockFirebaseDataSource.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockFirebaseUser);

      when(mockRemoteDataSource.getUserByFirebaseUid(any))
          .thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result.isRight(), true);
      final user = result.getOrElse(() => throw Exception());
      expect(user.email, testEmail);
      expect(user.firebaseUid, 'firebase_uid_123');
      verify(mockFirebaseDataSource.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);
      verify(mockRemoteDataSource.getUserByFirebaseUid('firebase_uid_123'))
          .called(1);
    });

    test('should create user in backend when CacheException occurs', () async {
      // Arrange
      when(mockFirebaseDataSource.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockFirebaseUser);

      when(mockRemoteDataSource.getUserByFirebaseUid(any))
          .thenThrow(CacheException('User not found'));

      when(mockRemoteDataSource.createUser(
        firebaseUid: anyNamed('firebaseUid'),
        email: anyNamed('email'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRemoteDataSource.createUser(
        firebaseUid: 'firebase_uid_123',
        email: testEmail,
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: null,
      )).called(1);
    });

    test('should return ServerFailure when ServerException occurs', () async {
      // Arrange
      when(mockFirebaseDataSource.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(ServerException('Invalid credentials', 401));

      // Act
      final result = await repository.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'Invalid credentials');
    });

    test('should return ServerFailure on generic exception', () async {
      // Arrange
      when(mockFirebaseDataSource.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(Exception('Unknown error'));

      // Act
      final result = await repository.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('signUpWithEmailAndPassword', () {
    const testEmail = 'newuser@example.com';
    const testPassword = 'password123';
    const testUsername = 'newuser';

    setUp(() {
      when(mockFirebaseUser.uid).thenReturn('firebase_uid_new');
      when(mockFirebaseUser.email).thenReturn(testEmail);
      when(mockFirebaseUser.photoURL).thenReturn(null);
    });

    test('should return UserEntity when signup succeeds', () async {
      // Arrange
      when(mockFirebaseDataSource.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockFirebaseUser);

      when(mockRemoteDataSource.createUser(
        firebaseUid: anyNamed('firebaseUid'),
        email: anyNamed('email'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.signUpWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockFirebaseDataSource.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);
      verify(mockRemoteDataSource.createUser(
        firebaseUid: 'firebase_uid_new',
        email: testEmail,
        username: testUsername,
        displayName: testUsername,
        photoURL: null,
      )).called(1);
    });

    test('should return ServerFailure when email already exists', () async {
      // Arrange
      when(mockFirebaseDataSource.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(ServerException('Email already in use', 400));

      // Act
      final result = await repository.signUpWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure when backend creation fails', () async {
      // Arrange
      when(mockFirebaseDataSource.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockFirebaseUser);

      when(mockRemoteDataSource.createUser(
        firebaseUid: anyNamed('firebaseUid'),
        email: anyNamed('email'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenThrow(ServerException('Username taken', 409));

      // Act
      final result = await repository.signUpWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'Username taken');
    });
  });

  group('signOut', () {
    test('should complete successfully', () async {
      // Arrange
      when(mockFirebaseDataSource.signOut())
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.signOut();

      // Assert
      expect(result.isRight(), true);
      verify(mockFirebaseDataSource.signOut()).called(1);
    });

    test('should return ServerFailure on error', () async {
      // Arrange
      when(mockFirebaseDataSource.signOut())
          .thenThrow(ServerException('Sign out failed', 500));

      // Act
      final result = await repository.signOut();

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getCurrentUser', () {
    setUp(() {
      when(mockFirebaseUser.uid).thenReturn('firebase_uid_123');
    });

    test('should return null when no user is signed in', () async {
      // Arrange
      when(mockFirebaseDataSource.getCurrentFirebaseUser()).thenReturn(null);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isRight(), true);
      final user = result.getOrElse(() => throw Exception());
      expect(user, isNull);
    });

    test('should return UserEntity when user is signed in', () async {
      // Arrange
      when(mockFirebaseDataSource.getCurrentFirebaseUser())
          .thenReturn(mockFirebaseUser);

      when(mockRemoteDataSource.getUserByFirebaseUid(any))
          .thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isRight(), true);
      final user = result.getOrElse(() => throw Exception());
      expect(user, isNotNull);
      expect(user!.firebaseUid, 'firebase_uid_123');
      verify(mockRemoteDataSource.getUserByFirebaseUid('firebase_uid_123'))
          .called(1);
    });

    test('should return null when CacheException occurs', () async {
      // Arrange
      when(mockFirebaseDataSource.getCurrentFirebaseUser())
          .thenReturn(mockFirebaseUser);

      when(mockRemoteDataSource.getUserByFirebaseUid(any))
          .thenThrow(CacheException('User not found'));

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isRight(), true);
      final user = result.getOrElse(() => throw Exception());
      expect(user, isNull);
    });

    test('should return ServerFailure on ServerException', () async {
      // Arrange
      when(mockFirebaseDataSource.getCurrentFirebaseUser())
          .thenReturn(mockFirebaseUser);

      when(mockRemoteDataSource.getUserByFirebaseUid(any))
          .thenThrow(ServerException('Server error', 500));

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('watchAuthState', () {
    setUp(() {
      when(mockFirebaseUser.uid).thenReturn('firebase_uid_123');
    });

    test('should emit null when user signs out', () async {
      // Arrange
      when(mockFirebaseDataSource.watchAuthState())
          .thenAnswer((_) => Stream.value(null));

      // Act
      final stream = repository.watchAuthState();

      // Assert
      await expectLater(stream, emits(null));
    });

    test('should emit UserEntity when user signs in', () async {
      // Arrange
      when(mockFirebaseDataSource.watchAuthState())
          .thenAnswer((_) => Stream.value(mockFirebaseUser));

      when(mockRemoteDataSource.getUserByFirebaseUid(any))
          .thenAnswer((_) async => testUserModel);

      // Act
      final stream = repository.watchAuthState();

      // Assert
      await expectLater(
        stream,
        emits(predicate<dynamic>((user) =>
            user != null && user.firebaseUid == 'firebase_uid_123')),
      );
    });

    test('should emit null when backend user fetch fails', () async {
      // Arrange
      when(mockFirebaseDataSource.watchAuthState())
          .thenAnswer((_) => Stream.value(mockFirebaseUser));

      when(mockRemoteDataSource.getUserByFirebaseUid(any))
          .thenThrow(ServerException('Server error', 500));

      // Act
      final stream = repository.watchAuthState();

      // Assert
      await expectLater(stream, emits(null));
    });

    test('should emit user state changes', () async {
      // Arrange
      when(mockFirebaseDataSource.watchAuthState()).thenAnswer(
        (_) => Stream.fromIterable([null, mockFirebaseUser, null]),
      );

      when(mockRemoteDataSource.getUserByFirebaseUid(any))
          .thenAnswer((_) async => testUserModel);

      // Act
      final stream = repository.watchAuthState();

      // Assert
      await expectLater(
        stream,
        emitsInOrder([
          null,
          predicate<dynamic>((user) => user != null),
          null,
        ]),
      );
    });
  });

  group('getIdToken', () {
    test('should return token when successful', () async {
      // Arrange
      const expectedToken = 'test_id_token_123';
      when(mockFirebaseDataSource.getIdToken(forceRefresh: anyNamed('forceRefresh')))
          .thenAnswer((_) async => expectedToken);

      // Act
      final result = await repository.getIdToken();

      // Assert
      expect(result.isRight(), true);
      final token = result.getOrElse(() => '');
      expect(token, expectedToken);
      verify(mockFirebaseDataSource.getIdToken(forceRefresh: false)).called(1);
    });

    test('should pass forceRefresh parameter', () async {
      // Arrange
      when(mockFirebaseDataSource.getIdToken(forceRefresh: anyNamed('forceRefresh')))
          .thenAnswer((_) async => 'token');

      // Act
      await repository.getIdToken(forceRefresh: true);

      // Assert
      verify(mockFirebaseDataSource.getIdToken(forceRefresh: true)).called(1);
    });

    test('should return ServerFailure on error', () async {
      // Arrange
      when(mockFirebaseDataSource.getIdToken(forceRefresh: anyNamed('forceRefresh')))
          .thenThrow(ServerException('Failed to get token', 500));

      // Act
      final result = await repository.getIdToken();

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('updateUser', () {
    const userId = 'user1';
    const newUsername = 'newusername';
    const newDisplayName = 'New Display Name';

    test('should return updated UserEntity when successful', () async {
      // Arrange
      final updatedUserJson = {...testUserJson, 'username': newUsername};
      final updatedUserModel = UserModel.fromJson(updatedUserJson);

      when(mockRemoteDataSource.updateUser(
        id: anyNamed('id'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenAnswer((_) async => updatedUserModel);

      // Act
      final result = await repository.updateUser(
        id: userId,
        username: newUsername,
        displayName: newDisplayName,
      );

      // Assert
      expect(result.isRight(), true);
      final user = result.getOrElse(() => throw Exception());
      expect(user.username, newUsername);
      verify(mockRemoteDataSource.updateUser(
        id: userId,
        username: newUsername,
        displayName: newDisplayName,
        photoURL: null,
      )).called(1);
    });

    test('should return ServerFailure when validation fails', () async {
      // Arrange
      when(mockRemoteDataSource.updateUser(
        id: anyNamed('id'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenThrow(ServerException('Username already taken', 409));

      // Act
      final result = await repository.updateUser(
        id: userId,
        username: newUsername,
      );

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'Username already taken');
    });

    test('should handle partial updates', () async {
      // Arrange
      when(mockRemoteDataSource.updateUser(
        id: anyNamed('id'),
        username: anyNamed('username'),
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
      )).thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.updateUser(
        id: userId,
        displayName: newDisplayName,
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRemoteDataSource.updateUser(
        id: userId,
        username: null,
        displayName: newDisplayName,
        photoURL: null,
      )).called(1);
    });
  });
}

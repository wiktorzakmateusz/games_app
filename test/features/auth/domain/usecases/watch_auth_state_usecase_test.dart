import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/features/auth/domain/entities/user_entity.dart';
import 'package:games_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:games_app/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'watch_auth_state_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([AuthRepository])
void main() {
  late WatchAuthStateUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = WatchAuthStateUseCase(mockRepository);
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

  group('WatchAuthStateUseCase', () {
    test('should return stream of UserEntity from repository', () {
      // Arrange
      final stream = Stream<UserEntity?>.value(testUser);
      when(mockRepository.watchAuthState()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      expect(result, stream);
      verify(mockRepository.watchAuthState()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should emit UserEntity when user signs in', () async {
      // Arrange
      final stream = Stream<UserEntity?>.value(testUser);
      when(mockRepository.watchAuthState()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      await expectLater(result, emits(testUser));
    });

    test('should emit null when user signs out', () async {
      // Arrange
      final stream = Stream<UserEntity?>.value(null);
      when(mockRepository.watchAuthState()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      await expectLater(result, emits(null));
    });

    test('should emit sequence when user signs in and out', () async {
      // Arrange
      final stream = Stream<UserEntity?>.fromIterable([
        null,      // Initially not signed in
        testUser,  // User signs in
        null,      // User signs out
      ]);
      when(mockRepository.watchAuthState()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      await expectLater(
        result,
        emitsInOrder([
          null,
          testUser,
          null,
        ]),
      );
    });

    test('should emit updated user when user data changes', () async {
      // Arrange
      final updatedUser = testUser.copyWith(username: 'newusername');
      final stream = Stream<UserEntity?>.fromIterable([
        testUser,
        updatedUser,
      ]);
      when(mockRepository.watchAuthState()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      await expectLater(
        result,
        emitsInOrder([
          testUser,
          updatedUser,
        ]),
      );
    });

    test('should handle empty stream', () async {
      // Arrange
      final stream = Stream<UserEntity?>.empty();
      when(mockRepository.watchAuthState()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      await expectLater(result, emitsDone);
    });

    test('should propagate errors from repository stream', () async {
      // Arrange
      final stream = Stream<UserEntity?>.error(Exception('Auth error'));
      when(mockRepository.watchAuthState()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      await expectLater(result, emitsError(isA<Exception>()));
    });
  });
}


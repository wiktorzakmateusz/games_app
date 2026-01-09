import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/auth/domain/entities/user_entity.dart';
import 'package:games_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:games_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:games_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:games_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:games_app/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:games_app/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:games_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:games_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_cubit_integration_test.mocks.dart';

/// Integration tests for AuthCubit
///
/// These tests verify that the Cubit correctly orchestrates
/// multiple use cases and handles state transitions
@GenerateMocks([
  SignInUseCase,
  SignUpUseCase,
  SignOutUseCase,
  GetCurrentUserUseCase,
  WatchAuthStateUseCase,
  UpdateUserUseCase,
])
void main() {
  late AuthCubit cubit;
  late MockSignInUseCase mockSignInUseCase;
  late MockSignUpUseCase mockSignUpUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockWatchAuthStateUseCase mockWatchAuthStateUseCase;
  late MockUpdateUserUseCase mockUpdateUserUseCase;

  final testUser = UserEntity(
    id: '1',
    firebaseUid: 'firebase_1',
    email: 'test@example.com',
    username: 'testuser',
    displayName: 'Test User',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignUpUseCase = MockSignUpUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockWatchAuthStateUseCase = MockWatchAuthStateUseCase();
    mockUpdateUserUseCase = MockUpdateUserUseCase();

    // Default: no initial auth state
    when(mockWatchAuthStateUseCase()).thenAnswer(
          (_) => Stream.value(null),
    );

    cubit = AuthCubit(
      signInUseCase: mockSignInUseCase,
      signUpUseCase: mockSignUpUseCase,
      signOutUseCase: mockSignOutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      watchAuthStateUseCase: mockWatchAuthStateUseCase,
      updateUserUseCase: mockUpdateUserUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('Sign In Flow', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] when sign in succeeds',
      build: () {
        when(mockSignInUseCase(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => Right(testUser));

        return cubit;
      },
      act: (cubit) => cubit.signIn(
        email: 'test@example.com',
        password: 'password123',
      ),
      expect: () => [
        const AuthLoading(),
        Authenticated(testUser),
      ],
      verify: (_) {
        verify(mockSignInUseCase(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when sign in fails',
      build: () {
        when(mockSignInUseCase(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer(
              (_) async => const Left(ServerFailure('Invalid credentials')),
        );

        return cubit;
      },
      act: (cubit) => cubit.signIn(
        email: 'wrong@example.com',
        password: 'wrongpass',
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Invalid credentials'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'handles network failure during sign in',
      build: () {
        when(mockSignInUseCase(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer(
              (_) async => const Left(NetworkFailure('No internet connection')),
        );

        return cubit;
      },
      act: (cubit) => cubit.signIn(
        email: 'test@example.com',
        password: 'password123',
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('No internet connection'),
      ],
    );
  });

  group('Sign Up Flow', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] when sign up succeeds',
      build: () {
        when(mockSignUpUseCase(
          email: anyNamed('email'),
          password: anyNamed('password'),
          username: anyNamed('username'),
        )).thenAnswer((_) async => Right(testUser));

        return cubit;
      },
      act: (cubit) => cubit.signUp(
        email: 'new@example.com',
        password: 'password123',
        username: 'newuser',
      ),
      expect: () => [
        const AuthLoading(),
        Authenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits error when username is already taken',
      build: () {
        when(mockSignUpUseCase(
          email: anyNamed('email'),
          password: anyNamed('password'),
          username: anyNamed('username'),
        )).thenAnswer(
              (_) async => const Left(ServerFailure('Username already exists')),
        );

        return cubit;
      },
      act: (cubit) => cubit.signUp(
        email: 'new@example.com',
        password: 'password123',
        username: 'taken',
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Username already exists'),
      ],
    );
  });

  group('Sign Out Flow', () {
    blocTest<AuthCubit, AuthState>(
      'emits [Unauthenticated] when sign out succeeds',
      build: () {
        when(mockSignOutUseCase()).thenAnswer(
              (_) async => const Right(null),
        );
        return cubit;
      },
      seed: () => Authenticated(testUser),
      act: (cubit) => cubit.signOut(),
      expect: () => [
        const Unauthenticated(),
      ],
    );
  });

  group('Watch Auth State', () {
    test('should listen to auth state changes', () async {
      // Arrange
      final authStream = Stream.fromIterable([
        null, // Unauthenticated
        testUser, // Signed in
        null, // Signed out
      ]);

      when(mockWatchAuthStateUseCase()).thenAnswer((_) => authStream);

      // Create new cubit that will listen to the stream
      final testCubit = AuthCubit(
        signInUseCase: mockSignInUseCase,
        signUpUseCase: mockSignUpUseCase,
        signOutUseCase: mockSignOutUseCase,
        getCurrentUserUseCase: mockGetCurrentUserUseCase,
        watchAuthStateUseCase: mockWatchAuthStateUseCase,
        updateUserUseCase: mockUpdateUserUseCase,
      );

      // Wait for stream to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Clean up
      await testCubit.close();
    });
  });

  group('Update User Flow', () {
    blocTest<AuthCubit, AuthState>(
      'updates user and emits new Authenticated state',
      build: () {
        final updatedUser = testUser.copyWith(username: 'newusername');
        when(mockUpdateUserUseCase(
          id: anyNamed('id'),
          username: anyNamed('username'),
        )).thenAnswer((_) async => Right(updatedUser));

        return cubit;
      },
      seed: () => Authenticated(testUser),
      act: (cubit) => cubit.updateUser(
        id: '1',
        username: 'newusername',
      ),
      expect: () => [
        predicate<Authenticated>((state) => state.user.username == 'newusername'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'preserves user state but adds error message on update failure',
      build: () {
        when(mockUpdateUserUseCase(
          id: anyNamed('id'),
          username: anyNamed('username'),
        )).thenAnswer(
              (_) async => const Left(ServerFailure('Username already taken')),
        );

        return cubit;
      },
      seed: () => Authenticated(testUser),
      act: (cubit) => cubit.updateUser(
        id: '1',
        username: 'taken',
      ),
      expect: () => [
        predicate<Authenticated>((state) {
          return state.user == testUser &&
              state.errorMessage == 'Username already taken';
        }),
      ],
    );
  });

  group('Check Auth Status', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] when user exists',
      build: () {
        when(mockGetCurrentUserUseCase()).thenAnswer(
              (_) async => Right(testUser),
        );
        return cubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(),
        Authenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Unauthenticated] when no user exists',
      build: () {
        when(mockGetCurrentUserUseCase()).thenAnswer(
              (_) async => const Right(null),
        );
        return cubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );
  });

  group('Complete User Journey', () {
    test('sign up -> update profile -> sign out flow', () async {
      // Setup mocks
      when(mockSignUpUseCase(
        email: anyNamed('email'),
        password: anyNamed('password'),
        username: anyNamed('username'),
      )).thenAnswer((_) async => Right(testUser));

      final updatedUser = testUser.copyWith(displayName: 'New Name');
      when(mockUpdateUserUseCase(
        id: anyNamed('id'),
        displayName: anyNamed('displayName'),
      )).thenAnswer((_) async => Right(updatedUser));

      when(mockSignOutUseCase()).thenAnswer((_) async => const Right(null));

      // Execute flow
      await cubit.signUp(
        email: 'test@example.com',
        password: 'password123',
        username: 'testuser',
      );

      expect(cubit.state, isA<Authenticated>());

      await cubit.updateUser(id: '1', displayName: 'New Name');

      expect(cubit.state, isA<Authenticated>());
      expect((cubit.state as Authenticated).user.displayName, 'New Name');

      await cubit.signOut();

      expect(cubit.state, const Unauthenticated());
    });
  });
}
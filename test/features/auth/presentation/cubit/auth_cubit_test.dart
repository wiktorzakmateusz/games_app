import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

// Mock classes
class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockWatchAuthStateUseCase extends Mock implements WatchAuthStateUseCase {}

class MockUpdateUserUseCase extends Mock implements UpdateUserUseCase {}

void main() {
  late AuthCubit authCubit;
  late MockSignInUseCase mockSignInUseCase;
  late MockSignUpUseCase mockSignUpUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockWatchAuthStateUseCase mockWatchAuthStateUseCase;
  late MockUpdateUserUseCase mockUpdateUserUseCase;

  // Test user
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

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignUpUseCase = MockSignUpUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockWatchAuthStateUseCase = MockWatchAuthStateUseCase();
    mockUpdateUserUseCase = MockUpdateUserUseCase();

    // Default: watch auth state returns empty stream
    when(() => mockWatchAuthStateUseCase()).thenAnswer(
      (_) => Stream<UserEntity?>.empty(),
    );

    authCubit = AuthCubit(
      signInUseCase: mockSignInUseCase,
      signUpUseCase: mockSignUpUseCase,
      signOutUseCase: mockSignOutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      watchAuthStateUseCase: mockWatchAuthStateUseCase,
      updateUserUseCase: mockUpdateUserUseCase,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  test('initial state is AuthInitial', () {
    expect(authCubit.state, const AuthInitial());
  });

  group('signIn', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] when sign in succeeds',
      setUp: () {
        when(() => mockSignInUseCase(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => Right(testUser));
      },
      build: () => authCubit,
      act: (cubit) => cubit.signIn(
        email: 'test@example.com',
        password: 'password123',
      ),
      expect: () => [
        const AuthLoading(),
        Authenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when sign in fails',
      setUp: () {
        when(() => mockSignInUseCase(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer(
          (_) async => const Left(AuthFailure('Invalid credentials')),
        );
      },
      build: () => authCubit,
      act: (cubit) => cubit.signIn(
        email: 'test@example.com',
        password: 'wrongpassword',
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Invalid credentials'),
      ],
    );
  });

  group('signUp', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] when sign up succeeds',
      setUp: () {
        when(() => mockSignUpUseCase(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
            )).thenAnswer((_) async => Right(testUser));
      },
      build: () => authCubit,
      act: (cubit) => cubit.signUp(
        email: 'test@example.com',
        password: 'password123',
        username: 'testuser',
      ),
      expect: () => [
        const AuthLoading(),
        Authenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when sign up fails',
      setUp: () {
        when(() => mockSignUpUseCase(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
            )).thenAnswer(
          (_) async => const Left(AuthFailure('Email already in use')),
        );
      },
      build: () => authCubit,
      act: (cubit) => cubit.signUp(
        email: 'test@example.com',
        password: 'password123',
        username: 'testuser',
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Email already in use'),
      ],
    );
  });

  group('signOut', () {
    blocTest<AuthCubit, AuthState>(
      'emits [Unauthenticated] when sign out succeeds',
      setUp: () {
        when(() => mockSignOutUseCase())
            .thenAnswer((_) async => const Right(null));
      },
      build: () => authCubit,
      act: (cubit) => cubit.signOut(),
      expect: () => [
        const Unauthenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthError] when sign out fails',
      setUp: () {
        when(() => mockSignOutUseCase()).thenAnswer(
          (_) async => const Left(ServerFailure('Sign out failed')),
        );
      },
      build: () => authCubit,
      act: (cubit) => cubit.signOut(),
      expect: () => [
        const AuthError('Sign out failed'),
      ],
    );
  });

  group('checkAuthStatus', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] when user is logged in',
      setUp: () {
        when(() => mockGetCurrentUserUseCase())
            .thenAnswer((_) async => Right(testUser));
      },
      build: () => authCubit,
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(),
        Authenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Unauthenticated] when user is not logged in',
      setUp: () {
        when(() => mockGetCurrentUserUseCase())
            .thenAnswer((_) async => const Right(null));
      },
      build: () => authCubit,
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Unauthenticated] when check fails',
      setUp: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to get user')),
        );
      },
      build: () => authCubit,
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );
  });

  group('updateUser', () {
    final updatedUser = testUser.copyWith(username: 'newusername');

    blocTest<AuthCubit, AuthState>(
      'emits [Authenticated] with updated user when update succeeds',
      setUp: () {
        when(() => mockUpdateUserUseCase(
              id: any(named: 'id'),
              username: any(named: 'username'),
              displayName: any(named: 'displayName'),
              photoURL: any(named: 'photoURL'),
            )).thenAnswer((_) async => Right(updatedUser));
      },
      build: () => authCubit,
      seed: () => Authenticated(testUser),
      act: (cubit) => cubit.updateUser(
        id: '1',
        username: 'newusername',
      ),
      expect: () => [
        Authenticated(updatedUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Authenticated] with error message when update fails',
      setUp: () {
        when(() => mockUpdateUserUseCase(
              id: any(named: 'id'),
              username: any(named: 'username'),
              displayName: any(named: 'displayName'),
              photoURL: any(named: 'photoURL'),
            )).thenAnswer(
          (_) async => const Left(ServerFailure('Update failed')),
        );
      },
      build: () => authCubit,
      seed: () => Authenticated(testUser),
      act: (cubit) => cubit.updateUser(
        id: '1',
        username: 'newusername',
      ),
      expect: () => [
        Authenticated(testUser, 'Update failed'),
      ],
    );
  });

  group('clearError', () {
    blocTest<AuthCubit, AuthState>(
      'clears error message from Authenticated state',
      build: () => authCubit,
      seed: () => Authenticated(testUser, 'Some error'),
      act: (cubit) => cubit.clearError(),
      expect: () => [
        Authenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'does nothing when already no error',
      build: () => authCubit,
      seed: () => Authenticated(testUser),
      act: (cubit) => cubit.clearError(),
      expect: () => [],
    );
  });

  group('watchAuthState', () {
    test('emits Authenticated when auth state stream emits user', () async {
      final streamController = Stream<UserEntity?>.value(testUser);

      when(() => mockWatchAuthStateUseCase()).thenAnswer(
        (_) => streamController,
      );

      final cubit = AuthCubit(
        signInUseCase: mockSignInUseCase,
        signUpUseCase: mockSignUpUseCase,
        signOutUseCase: mockSignOutUseCase,
        getCurrentUserUseCase: mockGetCurrentUserUseCase,
        watchAuthStateUseCase: mockWatchAuthStateUseCase,
        updateUserUseCase: mockUpdateUserUseCase,
      );

      // Wait for stream to be processed
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state, Authenticated(testUser));

      await cubit.close();
    });

    test('emits Unauthenticated when auth state stream emits null', () async {
      final streamController = Stream<UserEntity?>.value(null);

      when(() => mockWatchAuthStateUseCase()).thenAnswer(
        (_) => streamController,
      );

      final cubit = AuthCubit(
        signInUseCase: mockSignInUseCase,
        signUpUseCase: mockSignUpUseCase,
        signOutUseCase: mockSignOutUseCase,
        getCurrentUserUseCase: mockGetCurrentUserUseCase,
        watchAuthStateUseCase: mockWatchAuthStateUseCase,
        updateUserUseCase: mockUpdateUserUseCase,
      );

      // Wait for stream to be processed
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state, const Unauthenticated());

      await cubit.close();
    });
  });
}


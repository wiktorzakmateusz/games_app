import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/usecases/watch_auth_state_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final WatchAuthStateUseCase watchAuthStateUseCase;
  final UpdateUserUseCase updateUserUseCase;

  StreamSubscription? _authStateSubscription;

  AuthCubit({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.watchAuthStateUseCase,
    required this.updateUserUseCase,
  }) : super(const AuthInitial()) {
    _initializeAuthState();
  }

  void _initializeAuthState() {
    _authStateSubscription?.cancel();
    _authStateSubscription = watchAuthStateUseCase().listen(
      (user) {
        if (user != null) {
          final currentState = state;
          String? preservedError;
          if (currentState is Authenticated && currentState.errorMessage != null) {
            if (currentState.user.id == user.id) {
              preservedError = currentState.errorMessage;
            }
          }
          emit(Authenticated(user, preservedError));
        } else {
          emit(const Unauthenticated());
        }
      },
      onError: (error) {
        final currentState = state;
        if (currentState is Authenticated) {
          emit(Authenticated(currentState.user, 'Auth state error: $error'));
        } else {
          emit(AuthError('Auth state error: $error'));
        }
      },
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    final result = await signInUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    emit(const AuthLoading());

    final result = await signUpUseCase(
      email: email,
      password: password,
      username: username,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> signOut() async {
    final result = await signOutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> updateUser({
    required String id,
    String? username,
    String? displayName,
    String? photoURL,
  }) async {
    final currentState = state;
    UserEntity? currentUser;
    if (currentState is Authenticated) {
      currentUser = currentState.user;
    }

    final result = await updateUserUseCase(
      id: id,
      username: username,
      displayName: displayName,
      photoURL: photoURL,
    );

    result.fold(
      (failure) {
        // Keep user authenticated but include error message
        if (currentUser != null) {
          emit(Authenticated(currentUser, failure.message));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) {
        emit(Authenticated(user));
      },
    );
  }

  /// Clear any error message from the authenticated state
  void clearError() {
    final currentState = state;
    if (currentState is Authenticated && currentState.errorMessage != null) {
      emit(Authenticated(currentState.user));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}


import 'package:dartz/dartz.dart';
import 'package:games_app/core/error/exceptions.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource firebaseDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.firebaseDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in with Firebase
      final firebaseUser = await firebaseDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Try to get user from backend
      try {
        final user = await remoteDataSource.getUserByFirebaseUid(
          firebaseUser.uid,
        );
        return Right(user.toEntity());
      } on CacheException {
        // User doesn't exist in backend, create them
        final emailUsername = firebaseUser.email?.split('@').first ?? 'user';
        final username = firebaseUser.displayName ?? emailUsername;

        final user = await remoteDataSource.createUser(
          firebaseUid: firebaseUser.uid,
          email: firebaseUser.email ?? email,
          username: username,
          displayName: firebaseUser.displayName ?? username,
          photoURL: firebaseUser.photoURL,
        );

        return Right(user.toEntity());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to sign in: ${e.toString()}'));
    }
  }

  @override
  Future<Result<UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // 1. Create Firebase user
      final firebaseUser =
          await firebaseDataSource.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Create user in backend database
      final user = await remoteDataSource.createUser(
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        username: username,
        displayName: username,
        photoURL: firebaseUser.photoURL,
      );

      return Right(user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to sign up: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await firebaseDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to sign out: ${e.toString()}'));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final firebaseUser = firebaseDataSource.getCurrentFirebaseUser();
      if (firebaseUser == null) {
        return const Right(null);
      }

      final user = await remoteDataSource.getUserByFirebaseUid(
        firebaseUser.uid,
      );

      return Right(user.toEntity());
    } on CacheException {
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    return firebaseDataSource.watchAuthState().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      try {
        final user = await remoteDataSource.getUserByFirebaseUid(
          firebaseUser.uid,
        );
        return user.toEntity();
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<Result<String>> getIdToken({bool forceRefresh = false}) async {
    try {
      final token = await firebaseDataSource.getIdToken(
        forceRefresh: forceRefresh,
      );
      return Right(token);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get ID token: ${e.toString()}'));
    }
  }
}


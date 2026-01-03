import 'package:games_app/core/utils/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  });

  Future<Result<void>> signOut();

  Future<Result<UserEntity?>> getCurrentUser();

  Stream<UserEntity?> watchAuthState();

  Future<Result<String>> getIdToken({bool forceRefresh = false});
}


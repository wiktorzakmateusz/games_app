import 'package:games_app/core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
    required String username,
  }) async {
    return await repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
    );
  }
}


import 'package:games_app/core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateUserUseCase {
  final AuthRepository repository;

  UpdateUserUseCase(this.repository);

  Future<Result<UserEntity>> call({
    required String id,
    String? username,
    String? displayName,
    String? photoURL,
  }) async {
    return await repository.updateUser(
      id: id,
      username: username,
      displayName: displayName,
      photoURL: photoURL,
    );
  }
}


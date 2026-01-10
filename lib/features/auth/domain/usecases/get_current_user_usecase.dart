import 'package:games_app/core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Result<UserEntity?>> call() async {
    return await repository.getCurrentUser();
  }
}


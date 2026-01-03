import 'package:games_app/core/utils/result.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Result<void>> call() async {
    return await repository.signOut();
  }
}


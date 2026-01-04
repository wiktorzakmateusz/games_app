import '../../../../core/utils/result.dart';
import '../repositories/game_repository.dart';

class AbandonGameUseCase {
  final GameRepository repository;

  AbandonGameUseCase(this.repository);

  Future<Result<void>> call(String gameId) {
    return repository.abandonGame(gameId);
  }
}


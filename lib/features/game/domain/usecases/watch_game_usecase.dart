import '../entities/game_entity.dart';
import '../repositories/game_repository.dart';

class WatchGameUseCase {
  final GameRepository repository;

  WatchGameUseCase(this.repository);

  Stream<GameEntity> call(String gameId) {
    return repository.watchGame(gameId);
  }
}


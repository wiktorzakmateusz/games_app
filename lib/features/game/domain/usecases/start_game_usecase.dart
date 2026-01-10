import '../../../../core/utils/result.dart';
import '../entities/game_entity.dart';
import '../repositories/game_repository.dart';

class StartGameUseCase {
  final GameRepository repository;

  StartGameUseCase(this.repository);

  Future<Result<GameEntity>> call(String lobbyId) {
    return repository.startGame(lobbyId);
  }
}


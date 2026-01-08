import '../../../../core/utils/result.dart';
import '../../../../core/shared/enums.dart';
import '../repositories/lobby_repository.dart';

class UpdateGameTypeUseCase {
  final LobbyRepository repository;

  UpdateGameTypeUseCase(this.repository);

  Future<Result<void>> call(String lobbyId, GameType gameType) {
    return repository.updateGameType(lobbyId, gameType);
  }
}


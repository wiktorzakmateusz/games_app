import '../../../../core/utils/result.dart';
import '../repositories/lobby_repository.dart';

class ToggleReadyUseCase {
  final LobbyRepository repository;

  ToggleReadyUseCase(this.repository);

  Future<Result<void>> call(String lobbyId) {
    return repository.toggleReady(lobbyId);
  }
}

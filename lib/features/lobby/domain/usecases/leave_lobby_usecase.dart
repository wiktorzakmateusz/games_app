import '../../../../core/utils/result.dart';
import '../repositories/lobby_repository.dart';

class LeaveLobbyUseCase {
  final LobbyRepository repository;

  LeaveLobbyUseCase(this.repository);

  Future<Result<void>> call(String lobbyId) {
    return repository.leaveLobby(lobbyId);
  }
}


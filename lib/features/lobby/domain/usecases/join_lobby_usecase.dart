import '../../../../core/utils/result.dart';
import '../repositories/lobby_repository.dart';

class JoinLobbyUseCase {
  final LobbyRepository repository;

  JoinLobbyUseCase(this.repository);

  Future<Result<void>> call(String lobbyId) {
    return repository.joinLobby(lobbyId);
  }
}


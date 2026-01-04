import '../entities/lobby_entity.dart';
import '../repositories/lobby_repository.dart';

class WatchLobbyUseCase {
  final LobbyRepository repository;

  WatchLobbyUseCase(this.repository);

  Stream<LobbyEntity> call(String lobbyId) {
    return repository.watchLobby(lobbyId);
  }
}


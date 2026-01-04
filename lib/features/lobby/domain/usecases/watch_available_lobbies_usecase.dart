import '../entities/lobby_entity.dart';
import '../repositories/lobby_repository.dart';

class WatchAvailableLobbiesUseCase {
  final LobbyRepository repository;

  WatchAvailableLobbiesUseCase(this.repository);

  Stream<List<LobbyEntity>> call() {
    return repository.watchAvailableLobbies();
  }
}


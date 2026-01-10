import '../../../../core/utils/result.dart';
import '../../../../core/shared/enums.dart';
import '../entities/lobby_entity.dart';
import '../repositories/lobby_repository.dart';

class CreateLobbyUseCase {
  final LobbyRepository repository;

  CreateLobbyUseCase(this.repository);

  Future<Result<LobbyEntity>> call({
    required String name,
    required GameType gameType,
    required int maxPlayers,
  }) {
    return repository.createLobby(
      name: name,
      gameType: gameType,
      maxPlayers: maxPlayers,
    );
  }
}


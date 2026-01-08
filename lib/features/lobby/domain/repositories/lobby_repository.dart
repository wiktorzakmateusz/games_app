import '../../../../core/utils/result.dart';
import '../../../../core/shared/enums.dart';
import '../entities/lobby_entity.dart';

abstract class LobbyRepository {
  Stream<List<LobbyEntity>> watchAvailableLobbies();
  
  Stream<LobbyEntity> watchLobby(String lobbyId);

  Future<Result<LobbyEntity>> createLobby({
    required String name,
    required GameType gameType,
    required int maxPlayers,
  });

  Future<Result<void>> joinLobby(String lobbyId);

  Future<Result<void>> leaveLobby(String lobbyId);

  Future<Result<void>> toggleReady(String lobbyId);

  Future<Result<void>> updateGameType(String lobbyId, GameType gameType);

  Future<Result<LobbyEntity>> getLobby(String lobbyId);

  Future<Result<LobbyEntity?>> getCurrentUserLobby();
}


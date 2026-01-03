import '../../../../core/utils/result.dart';
import '../entities/game_entity.dart';


abstract class GameRepository {
  /// Watch a game in real-time (Firestore stream)
  Stream<GameEntity> watchGame(String gameId);

  /// Start a new game from a lobby
  Future<Result<GameEntity>> startGame(String lobbyId);

  /// Make a move in the game
  Future<Result<void>> makeMove({
    required String gameId,
    required int position,
  });

  /// Abandon/forfeit the current game
  Future<Result<void>> abandonGame(String gameId);

  /// Get game by ID (one-time fetch)
  Future<Result<GameEntity>> getGame(String gameId);
}


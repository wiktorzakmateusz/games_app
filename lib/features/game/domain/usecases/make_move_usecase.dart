import '../../../../core/utils/result.dart';
import '../repositories/game_repository.dart';

class MakeMoveUseCase {
  final GameRepository repository;

  MakeMoveUseCase(this.repository);

  Future<Result<void>> call({
    required String gameId,
    required int position,
  }) {
    return repository.makeMove(gameId: gameId, position: position);
  }
}


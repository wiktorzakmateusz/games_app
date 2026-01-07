import 'package:games_app/core/utils/result.dart';
import '../entities/stats_entity.dart';
import '../repositories/stats_repository.dart';
import '../../../../core/shared/enums.dart';

class GetStatsByGameTypeUseCase {
  final StatsRepository repository;

  GetStatsByGameTypeUseCase(this.repository);

  Future<Result<StatsEntity?>> call(String userId, GameType gameType) async {
    return await repository.getUserStatsByGameType(userId, gameType);
  }
}


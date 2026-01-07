import 'package:games_app/core/utils/result.dart';
import '../entities/stats_entity.dart';
import '../repositories/stats_repository.dart';

class GetUserStatsUseCase {
  final StatsRepository repository;

  GetUserStatsUseCase(this.repository);

  Future<Result<List<StatsEntity>>> call(String userId) async {
    return await repository.getUserStats(userId);
  }
}


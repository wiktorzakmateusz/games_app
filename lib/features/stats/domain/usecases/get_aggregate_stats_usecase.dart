import 'package:games_app/core/utils/result.dart';
import '../entities/stats_entity.dart';
import '../repositories/stats_repository.dart';

class GetAggregateStatsUseCase {
  final StatsRepository repository;

  GetAggregateStatsUseCase(this.repository);

  Future<Result<AggregateStatsEntity>> call(String userId) async {
    return await repository.getAggregateStats(userId);
  }
}


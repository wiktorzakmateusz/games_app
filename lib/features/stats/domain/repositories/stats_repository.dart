import 'package:games_app/core/utils/result.dart';
import '../entities/stats_entity.dart';
import '../../../../core/shared/enums.dart';

abstract class StatsRepository {
  Future<Result<List<StatsEntity>>> getUserStats(String userId);
  
  Future<Result<StatsEntity?>> getUserStatsByGameType(
    String userId,
    GameType gameType,
  );
  
  Future<Result<AggregateStatsEntity>> getAggregateStats(String userId);
}


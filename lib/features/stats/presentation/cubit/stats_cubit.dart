import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_stats_usecase.dart';
import '../../domain/usecases/get_aggregate_stats_usecase.dart';
import '../../domain/usecases/get_stats_by_game_type_usecase.dart';
import 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final GetUserStatsUseCase getUserStatsUseCase;
  final GetAggregateStatsUseCase getAggregateStatsUseCase;
  final GetStatsByGameTypeUseCase getStatsByGameTypeUseCase;

  StatsCubit({
    required this.getUserStatsUseCase,
    required this.getAggregateStatsUseCase,
    required this.getStatsByGameTypeUseCase,
  }) : super(StatsInitial());

  Future<void> loadUserStats(String userId, {bool includeAggregate = true}) async {
    emit(StatsLoading());
    
    final statsResult = await getUserStatsUseCase(userId);
    
    statsResult.fold(
      (failure) => emit(StatsError(failure.message)),
      (stats) async {
        if (includeAggregate) {
          final aggregateResult = await getAggregateStatsUseCase(userId);
          aggregateResult.fold(
            (failure) => emit(StatsLoaded(stats: stats)),
            (aggregate) => emit(StatsLoaded(stats: stats, aggregateStats: aggregate)),
          );
        } else {
          emit(StatsLoaded(stats: stats));
        }
      },
    );
  }

  Future<void> loadAggregateStats(String userId) async {
    emit(StatsLoading());
    
    final result = await getAggregateStatsUseCase(userId);
    
    result.fold(
      (failure) => emit(StatsError(failure.message)),
      (aggregate) => emit(StatsLoaded(stats: const [], aggregateStats: aggregate)),
    );
  }
}


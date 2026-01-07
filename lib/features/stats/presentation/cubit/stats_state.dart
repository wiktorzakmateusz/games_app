import 'package:equatable/equatable.dart';
import '../../domain/entities/stats_entity.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsLoaded extends StatsState {
  final List<StatsEntity> stats;
  final AggregateStatsEntity? aggregateStats;

  const StatsLoaded({
    required this.stats,
    this.aggregateStats,
  });

  @override
  List<Object?> get props => [stats, aggregateStats];
}

class StatsError extends StatsState {
  final String message;

  const StatsError(this.message);

  @override
  List<Object?> get props => [message];
}


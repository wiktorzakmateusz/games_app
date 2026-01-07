import '../../domain/entities/stats_entity.dart';
import '../../../../core/shared/enums.dart';

class StatsModel extends StatsEntity {
  const StatsModel({
    required super.userId,
    required super.gameType,
    required super.wins,
    required super.losses,
    required super.draws,
    required super.played,
    required super.totalGames,
    required super.winRate,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      userId: json['userId'] as String,
      gameType: GameType.fromString(json['gameType'] as String),
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      draws: json['draws'] as int,
      played: json['played'] as int,
      totalGames: json['totalGames'] as int,
      winRate: (json['winRate'] as num).toDouble(),
    );
  }

  StatsEntity toEntity() {
    return StatsEntity(
      userId: userId,
      gameType: gameType,
      wins: wins,
      losses: losses,
      draws: draws,
      played: played,
      totalGames: totalGames,
      winRate: winRate,
    );
  }
}

class AggregateStatsModel extends AggregateStatsEntity {
  const AggregateStatsModel({
    required super.userId,
    required super.totalWins,
    required super.totalLosses,
    required super.totalDraws,
    required super.totalPlayed,
    required super.overallWinRate,
  });

  factory AggregateStatsModel.fromJson(Map<String, dynamic> json) {
    return AggregateStatsModel(
      userId: json['userId'] as String,
      totalWins: json['totalWins'] as int,
      totalLosses: json['totalLosses'] as int,
      totalDraws: json['totalDraws'] as int,
      totalPlayed: json['totalPlayed'] as int,
      overallWinRate: (json['overallWinRate'] as num).toDouble(),
    );
  }

  AggregateStatsEntity toEntity() {
    return AggregateStatsEntity(
      userId: userId,
      totalWins: totalWins,
      totalLosses: totalLosses,
      totalDraws: totalDraws,
      totalPlayed: totalPlayed,
      overallWinRate: overallWinRate,
    );
  }
}


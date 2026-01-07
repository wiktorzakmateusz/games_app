import 'package:equatable/equatable.dart';
import '../../../../core/shared/enums.dart';

class StatsEntity extends Equatable {
  final String userId;
  final GameType gameType;
  final int wins;
  final int losses;
  final int draws;
  final int played;
  final int totalGames;
  final double winRate;

  const StatsEntity({
    required this.userId,
    required this.gameType,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.played,
    required this.totalGames,
    required this.winRate,
  });

  @override
  List<Object> get props => [
        userId,
        gameType,
        wins,
        losses,
        draws,
        played,
        totalGames,
        winRate,
      ];
}

class AggregateStatsEntity extends Equatable {
  final String userId;
  final int totalWins;
  final int totalLosses;
  final int totalDraws;
  final int totalPlayed;
  final double overallWinRate;

  const AggregateStatsEntity({
    required this.userId,
    required this.totalWins,
    required this.totalLosses,
    required this.totalDraws,
    required this.totalPlayed,
    required this.overallWinRate,
  });

  @override
  List<Object> get props => [
        userId,
        totalWins,
        totalLosses,
        totalDraws,
        totalPlayed,
        overallWinRate,
      ];
}


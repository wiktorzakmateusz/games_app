import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../domain/entities/stats_entity.dart';
import 'stat_element.dart';

class AggregateStatsCardProfile extends StatelessWidget {
  final AggregateStatsEntity aggregateStats;

  const AggregateStatsCardProfile({
    super.key,
    required this.aggregateStats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.h3('Summary'),
          const SizedBox(height: 20),
          Row(
            children: [
              StatElement(
                category: 'Played',
                amount: aggregateStats.totalPlayed.toString(),
              ),
              StatElement(
                category: 'Win Rate',
                amount: '${aggregateStats.overallWinRate.toStringAsFixed(1)}%',
                color: CupertinoColors.systemBlue,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              StatElement(
                category: 'Wins',
                amount: aggregateStats.totalWins.toString(),
                color: CupertinoColors.systemGreen,
              ),
              StatElement(
                category: 'Draws',
                amount: aggregateStats.totalDraws.toString(),
                color: CupertinoColors.systemGrey,
              ),
              StatElement(
                category: 'Losses',
                amount: aggregateStats.totalLosses.toString(),
                color: CupertinoColors.systemRed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}


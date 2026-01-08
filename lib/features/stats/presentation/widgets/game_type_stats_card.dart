import 'package:flutter/cupertino.dart';
import '../../../../core/shared/enums.dart';
import '../../domain/entities/stats_entity.dart';
import 'stat_element.dart';
import 'game_type_selector.dart';

class GameTypeStatsCard extends StatefulWidget {
  final List<StatsEntity> stats;
  final String userId;

  const GameTypeStatsCard({
    super.key,
    required this.stats,
    required this.userId,
  });

  @override
  State<GameTypeStatsCard> createState() => _GameTypeStatsCardState();
}

class _GameTypeStatsCardState extends State<GameTypeStatsCard> {
  GameType _selectedGameType = GameType.ticTacToe;

  StatsEntity get _selectedStats {
    try {
      return widget.stats.firstWhere(
        (stat) => stat.gameType == _selectedGameType,
      );
    } catch (e) {
      // Return empty stats if no stats found for this game type
      return StatsEntity(
        userId: widget.userId,
        gameType: _selectedGameType,
        wins: 0,
        losses: 0,
        draws: 0,
        played: 0,
        totalGames: 0,
        winRate: 0.0,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final stats = _selectedStats;

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
          GameTypeSelector(
            selectedGameType: _selectedGameType,
            onGameTypeSelected: (gameType) {
              setState(() {
                _selectedGameType = gameType;
              });
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              StatElement(
                category: 'Played',
                amount: stats.played.toString(),
              ),
              StatElement(
                category: 'Win Rate',
                amount: '${stats.winRate.toStringAsFixed(1)}%',
                color: CupertinoColors.systemBlue,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              StatElement(
                category: 'Wins',
                amount: stats.wins.toString(),
                color: CupertinoColors.systemGreen,
              ),
              StatElement(
                category: 'Draws',
                amount: stats.draws.toString(),
                color: CupertinoColors.systemGrey,
              ),
              StatElement(
                category: 'Losses',
                amount: stats.losses.toString(),
                color: CupertinoColors.systemRed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}


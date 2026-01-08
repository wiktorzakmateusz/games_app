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
            color: CupertinoColors.black.withValues(alpha: 0.1),
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

class GameTypeStatsCardSkeleton extends StatefulWidget {
  const GameTypeStatsCardSkeleton({super.key});

  @override
  State<GameTypeStatsCardSkeleton> createState() =>
      _GameTypeStatsCardSkeletonState();
}

class _GameTypeStatsCardSkeletonState extends State<GameTypeStatsCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GameTypeSelector skeleton
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey4
                            .withOpacity(_animation.value),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.chevron_down,
                      size: 18,
                      color: CupertinoColors.systemGrey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // First row skeleton (2 stat elements)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 16,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4
                                .withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 20,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4
                                .withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 16,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4
                                .withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 50,
                          height: 20,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4
                                .withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Second row skeleton (3 stat elements)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 16,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4
                                .withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 30,
                          height: 20,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4
                                .withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 16,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4
                                .withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 30,
                          height: 20,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4
                                .withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 55,
                          height: 16,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4
                                .withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 30,
                          height: 20,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4
                                .withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}


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
            color: CupertinoColors.black.withValues(alpha: 0.1),
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

class AggregateStatsCardProfileSkeleton extends StatefulWidget {
  const AggregateStatsCardProfileSkeleton({super.key});

  @override
  State<AggregateStatsCardProfileSkeleton> createState() =>
      _AggregateStatsCardProfileSkeletonState();
}

class _AggregateStatsCardProfileSkeletonState
    extends State<AggregateStatsCardProfileSkeleton>
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
              // Title skeleton
              Container(
                width: 100,
                height: 24,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4
                      .withOpacity(_animation.value),
                  borderRadius: BorderRadius.circular(4),
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


import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../domain/entities/game_player_entity.dart';

class PlayerInfoCard extends StatelessWidget {
  final GamePlayerEntity player;
  final bool isCurrentTurn;

  const PlayerInfoCard({
    super.key,
    required this.player,
    this.isCurrentTurn = false,
  });

  @override
  Widget build(BuildContext context) {
    final symbolColor = switch (player.symbol) {
      'X' => CupertinoColors.systemRed,
      'O' => CupertinoColors.systemBlue,
      _ => CupertinoColors.label,
    };

    return Column(
      children: [
        AppText(
          player.displayName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.w500,
            color: symbolColor,
          ),
        ),
        const SizedBox(height: 4),
        AppText(
          player.symbol ?? '',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: symbolColor,
          ),
        ),
        if (isCurrentTurn) ...[
          const SizedBox(height: 4),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: CupertinoColors.activeGreen,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}


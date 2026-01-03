import 'package:flutter/cupertino.dart';
import '../../domain/entities/lobby_player_entity.dart';

class LobbyPlayerItem extends StatelessWidget {
  final LobbyPlayerEntity player;
  final bool isCurrentPlayer;

  const LobbyPlayerItem({
    super.key,
    required this.player,
    this.isCurrentPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? CupertinoColors.activeBlue.withOpacity(0.1)
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentPlayer
              ? CupertinoColors.activeBlue
              : CupertinoColors.separator,
          width: isCurrentPlayer ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '@${player.username}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          if (player.isReady)
            const Icon(
              CupertinoIcons.check_mark_circled_solid,
              color: CupertinoColors.activeGreen,
            )
          else
            const Text(
              'Not ready',
              style: TextStyle(
                color: CupertinoColors.secondaryLabel,
              ),
            ),
        ],
      ),
    );
  }
}


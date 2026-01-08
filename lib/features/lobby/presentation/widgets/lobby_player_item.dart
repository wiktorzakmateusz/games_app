import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../domain/entities/lobby_player_entity.dart';

class LobbyPlayerItem extends StatelessWidget {
  final LobbyPlayerEntity player;
  final bool isCurrentPlayer;
  final bool isOwner;

  const LobbyPlayerItem({
    super.key,
    required this.player,
    this.isCurrentPlayer = false,
    this.isOwner = false,
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
            child: Row(
              children: [
                if (isOwner)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.star_fill,
                      color: CupertinoColors.systemYellow,
                      size: 24,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bodyLarge(player.displayName),
                      AppText.bodySmall('@${player.username}'),
                    ],
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
            AppText(
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


import 'package:flutter/cupertino.dart';
import '../../domain/entities/lobby_entity.dart';

class LobbyCard extends StatelessWidget {
  final LobbyEntity lobby;
  final bool isFull;
  final bool isJoined;
  final VoidCallback? onTap;

  const LobbyCard({
    super.key,
    required this.lobby,
    required this.isFull,
    required this.isJoined,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 1,
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: (isFull || isJoined) ? null : onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lobby.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lobby.currentPlayerCount}/${lobby.maxPlayers} players',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            if (isFull)
              const Text(
                'Full',
                style: TextStyle(
                  color: CupertinoColors.destructiveRed,
                  fontWeight: FontWeight.w500,
                ),
              )
            else if (isJoined)
              const Text(
                'Joined',
                style: TextStyle(
                  color: CupertinoColors.activeGreen,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              const Icon(
                CupertinoIcons.arrow_right,
                color: CupertinoColors.activeBlue,
              ),
          ],
        ),
      ),
    );
  }
}


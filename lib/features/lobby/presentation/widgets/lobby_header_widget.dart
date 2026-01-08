import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../../../core/utils/game_image_helper.dart';
import '../../domain/entities/lobby_entity.dart';

class LobbyHeaderWidget extends StatelessWidget {
  final LobbyEntity lobby;

  const LobbyHeaderWidget({
    super.key,
    required this.lobby,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h2(lobby.name),
                const SizedBox(height: 8),
                AppText.bodyLarge(
                  '${lobby.currentPlayerCount}/${lobby.maxPlayers} Players',
                ),
                const SizedBox(height: 4),
                AppText.bodyLarge(lobby.gameType.displayName),
              ],
            ),
          ),
          _buildPreviewImage(),
        ],
      ),
    );
  }

  Widget _buildPreviewImage() {
    final imagePath = GameImageHelper.getPreviewImagePath(lobby.gameType);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.photo,
                size: 48,
                color: CupertinoColors.systemGrey,
              ),
            );
          },
        ),
      ),
    );
  }
}


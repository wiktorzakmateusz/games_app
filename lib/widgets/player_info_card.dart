import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';
import 'package:games_app/core/utils/device_type.dart';
import 'package:games_app/core/utils/responsive_layout.dart';

class PlayerInfoCard extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final bool isBot;
  final bool isCurrentTurn;
  final Color? borderColor;

  const PlayerInfoCard({
    super.key,
    this.imageUrl,
    this.name,
    this.isBot = false,
    this.isCurrentTurn = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name ?? 'Bot';
    final isPhone = DeviceTypeHelper.isPhone(context);
    final avatarSize = isPhone ? 50.0 : 80.0;
    final appPadding = ResponsiveLayout.getPadding(context);
    final padding = appPadding.left / 2;
    final borderWidth = isPhone ? 2.0 : 3.0;
    final spacing = ResponsiveLayout.getSpacing(context) / 2;
    final defaultBorderColor = CupertinoColors.activeBlue;

    return Container(
      constraints: isPhone ? null : const BoxConstraints(maxWidth: 140),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentTurn
            ? Border.all(
                color: borderColor ?? defaultBorderColor,
                width: borderWidth,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: _buildAvatar(),
            ),
          ),
          SizedBox(height: spacing),
          AppText.bodyLarge(
            displayName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (isBot) {
      return Image.asset(
        'images/bot_icon.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'images/user_icon.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        },
      );
    } else {
      return Image.asset(
        'images/user_icon.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: CupertinoColors.systemGrey5,
      child: const Icon(
        CupertinoIcons.person_fill,
        size: 40,
        color: CupertinoColors.systemGrey,
      ),
    );
  }
}


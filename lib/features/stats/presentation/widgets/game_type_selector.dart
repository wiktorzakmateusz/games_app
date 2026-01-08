import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../../../core/shared/enums.dart';
import '../../../../core/theme/app_typography.dart';

class GameTypeSelector extends StatelessWidget {
  final GameType selectedGameType;
  final Function(GameType) onGameTypeSelected;

  const GameTypeSelector({
    super.key,
    required this.selectedGameType,
    required this.onGameTypeSelected,
  });

  void _showGameTypeSelector(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: AppText.h4('Select Game Type'),
        actions: GameType.values.map((gameType) {
          return CupertinoActionSheetAction(
            onPressed: () {
              onGameTypeSelected(gameType);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  gameType.displayName,
                  style: TextStyles.bodyLarge.copyWith(
                    fontWeight: selectedGameType == gameType
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: selectedGameType == gameType
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.label,
                  ),
                ),
                if (selectedGameType == gameType) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    CupertinoIcons.check_mark,
                    color: CupertinoColors.activeBlue,
                    size: 18,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () {
            Navigator.pop(context);
          },
          child: AppText.bodyLarge('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showGameTypeSelector(context),
      child: Container(
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
            AppText.h4(selectedGameType.displayName),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 18,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}


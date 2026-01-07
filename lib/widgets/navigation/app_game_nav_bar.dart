import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:games_app/widgets/app_text.dart';
import 'package:games_app/core/game_logic/game_logic.dart';

class AppGameNavBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final String gameName;
  final GameDifficulty? difficulty;
  final String? title;

  const AppGameNavBar({
    super.key,
    required this.gameName,
    this.difficulty,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    String displayText;
    if (difficulty != null) {
      displayText = '$gameName - ${difficulty!.displayName}';
    } else if (title != null) {
      displayText = '$gameName - $title';
    } else {
      displayText = gameName;
    }

    return CupertinoNavigationBar(
      middle: AppText.h3(displayText),
      leading: GestureDetector(
        child: const Icon(
          CupertinoIcons.xmark,
          color: CupertinoColors.activeBlue,
        ),
        onTap: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;
}


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
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        ),
        child: const Icon(
          CupertinoIcons.back,
          color: CupertinoColors.activeBlue,
          size: 26.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;
}


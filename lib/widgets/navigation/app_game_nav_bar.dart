import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:games_app/widgets/app_text.dart';
import 'package:games_app/core/game_logic/game_logic.dart';
import 'package:games_app/core/utils/game_rules.dart';
import 'package:games_app/widgets/game_rules_dialog.dart';
import 'package:games_app/core/services/audio_service.dart';

class AppGameNavBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final String gameName;
  final GameDifficulty? difficulty;
  final String? title;
  final GameType? gameType;

  const AppGameNavBar({
    super.key,
    required this.gameName,
    this.difficulty,
    this.title,
    this.gameType,
  });

  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();
    
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
        onPressed: () {
          audioService.playClickSound();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => route.settings.name == '/',
          );
        },
        child: const Icon(
          CupertinoIcons.back,
          color: CupertinoColors.activeBlue,
          size: 26.0,
        ),
      ),
      trailing: gameType != null
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                audioService.playClickSound();
                final rules = GameRules.getRules(gameType!);
                GameRulesDialog.show(context, rules);
              },
              child: const Icon(
                CupertinoIcons.info_circle,
                color: CupertinoColors.activeBlue,
                size: 26.0,
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;
}


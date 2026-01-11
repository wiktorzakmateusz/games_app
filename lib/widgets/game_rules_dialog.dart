import 'package:flutter/cupertino.dart';
import '../core/utils/game_rules.dart';
import 'app_text.dart';

class GameRulesDialog {
  static void show(BuildContext context, GameRuleInfo rules) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: AppText.h4(rules.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            AppText.bodyMediumSemiBold(rules.description),
            const SizedBox(height: 12),
            if (rules.rules.isNotEmpty) ...[
              AppText.bodySmallBold('You can win by:'),
              const SizedBox(height: 6),
              ...rules.rules.map((rule) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodySmall('• '),
                    Expanded(
                      child: AppText.bodySmall(rule),
                    ),
                  ],
                ),
              )),
            ],
            if (rules.additionalInfo != null) ...[
              const SizedBox(height: 12),
              AppText.small(rules.additionalInfo!),
            ],
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: AppText.button('Got it!'),
          ),
        ],
      ),
    );
  }
}


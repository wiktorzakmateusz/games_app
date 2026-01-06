import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';

class EmptySlotWidget extends StatelessWidget {
  const EmptySlotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoColors.separator,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.person_add,
            color: CupertinoColors.secondaryLabel,
          ),
          const SizedBox(width: 12),
          AppText.bodyMedium('Waiting for player...'),
        ],
      ),
    );
  }
}


import 'package:flutter/cupertino.dart';

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
      child: const Row(
        children: [
          Icon(
            CupertinoIcons.person_add,
            color: CupertinoColors.secondaryLabel,
          ),
          SizedBox(width: 12),
          Text(
            'Waiting for player...',
            style: TextStyle(
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}


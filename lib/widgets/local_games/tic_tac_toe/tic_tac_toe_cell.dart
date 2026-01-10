import 'package:flutter/cupertino.dart';

class TicTacToeCell extends StatelessWidget {
  final String value;
  final bool isWinningCell;
  final VoidCallback onTap;

  const TicTacToeCell({
    super.key,
    required this.value,
    required this.isWinningCell,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = switch (value) {
      'X' => CupertinoColors.systemRed,
      'O' => CupertinoColors.systemBlue,
      _ => CupertinoColors.black,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.separator, width: 0.8),
          color: isWinningCell
              ? CupertinoColors.activeGreen.withOpacity(0.25)
              : CupertinoColors.white,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}


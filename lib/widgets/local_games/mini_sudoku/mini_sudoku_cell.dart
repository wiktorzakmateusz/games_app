import 'package:flutter/cupertino.dart';

class MiniSudokuCell extends StatelessWidget {
  final int value;
  final bool isFixed;
  final bool isWrong;
  final bool hasRightBorder;
  final bool hasBottomBorder;
  final VoidCallback onTap;

  const MiniSudokuCell({
    super.key,
    required this.value,
    required this.isFixed,
    required this.isWrong,
    required this.hasRightBorder,
    required this.hasBottomBorder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    if (isWrong) {
      textColor = CupertinoColors.systemRed;
    } else if (isFixed) {
      textColor = CupertinoColors.black;
    } else {
      textColor = CupertinoColors.activeBlue;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          border: Border(
            top: const BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
            left: const BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
            right: BorderSide(
              color: hasRightBorder ? CupertinoColors.black : CupertinoColors.systemGrey4,
              width: hasRightBorder ? 2.0 : 0.5,
            ),
            bottom: BorderSide(
              color: hasBottomBorder ? CupertinoColors.black : CupertinoColors.systemGrey4,
              width: hasBottomBorder ? 2.0 : 0.5,
            ),
          ),
        ),
        child: Center(
          child: Text(
            value == 0 ? '' : '$value',
            style: TextStyle(
              fontSize: 32,
              fontWeight: isFixed ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/cupertino.dart';

class Connect4Cell extends StatelessWidget {
  final String value;
  final bool isWinningCell;
  final bool showGhostPiece;
  final String currentPlayer;
  final VoidCallback? onTap;
  final void Function()? onHoverEnter;
  final void Function()? onHoverExit;

  const Connect4Cell({
    super.key,
    required this.value,
    required this.isWinningCell,
    required this.showGhostPiece,
    required this.currentPlayer,
    this.onTap,
    this.onHoverEnter,
    this.onHoverExit,
  });

  @override
  Widget build(BuildContext context) {
    Color cellColor;
    if (value == 'X') {
      cellColor = CupertinoColors.systemRed;
    } else if (value == 'O') {
      cellColor = CupertinoColors.systemBlue;
    } else {
      cellColor = CupertinoColors.white;
    }

    Color ghostColor = currentPlayer == 'X'
        ? CupertinoColors.systemRed.withOpacity(0.3)
        : CupertinoColors.systemBlue.withOpacity(0.3);

    return MouseRegion(
      onEnter: (_) => onHoverEnter?.call(),
      onExit: (_) => onHoverExit?.call(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.separator, width: 0.8),
            color: isWinningCell
                ? CupertinoColors.activeGreen.withOpacity(0.25)
                : CupertinoColors.white,
            shape: BoxShape.circle,
          ),
          margin: const EdgeInsets.all(2),
          child: value != ''
              ? Container(
                  decoration: BoxDecoration(
                    color: cellColor,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.all(4),
                )
              : showGhostPiece
                  ? Container(
                      decoration: BoxDecoration(
                        color: ghostColor,
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.all(4),
                    )
                  : null,
        ),
      ),
    );
  }
}


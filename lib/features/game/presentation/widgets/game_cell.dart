import 'package:flutter/cupertino.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/game_state_entity.dart';

class GameCell extends StatelessWidget {
  final int index;
  final GameEntity game;
  final String? currentUserId;
  final bool isPerformingAction;
  final List<int>? winningPattern;
  final Function(int) onTap;

  const GameCell({
    super.key,
    required this.index,
    required this.game,
    required this.currentUserId,
    required this.isPerformingAction,
    required this.winningPattern,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = game.state as TicTacToeGameStateEntity;
    final cellValue = state.getCell(index);
    final isWinningCell = winningPattern?.contains(index) ?? false;
    final isMyTurn = currentUserId != null && game.isPlayerTurn(currentUserId!);
    final canMakeMove = !game.isOver &&
        isMyTurn &&
        state.isEmpty(index) &&
        !isPerformingAction;

    final textColor = switch (cellValue) {
      'X' => CupertinoColors.systemRed,
      'O' => CupertinoColors.systemBlue,
      _ => CupertinoColors.black,
    };

    return GestureDetector(
      onTap: canMakeMove ? () => onTap(index) : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.separator,
            width: 0.8,
          ),
          color: isWinningCell
              ? CupertinoColors.activeGreen.withOpacity(0.25)
              : CupertinoColors.white,
        ),
        child: Center(
          child: Text(
            cellValue ?? '',
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


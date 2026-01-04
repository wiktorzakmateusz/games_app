import 'package:flutter/cupertino.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/game_state_entity.dart';
import 'game_cell.dart';
import 'winning_line_painter.dart';

class GameBoard extends StatelessWidget {
  final GameEntity game;
  final String? currentUserId;
  final bool isPerformingAction;
  final Function(int) onCellTap;

  const GameBoard({
    super.key,
    required this.game,
    required this.currentUserId,
    required this.isPerformingAction,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = game.state as TicTacToeGameStateEntity;
    final winningPattern = state.getWinningPattern();

    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: CupertinoColors.systemGrey4,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Grid of cells
              GridView.builder(
                itemCount: 9,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) => GameCell(
                  index: index,
                  game: game,
                  currentUserId: currentUserId,
                  isPerformingAction: isPerformingAction,
                  winningPattern: winningPattern,
                  onTap: onCellTap,
                ),
              ),
              // Winning line overlay
              if (winningPattern != null)
                WinningLinePainter(
                  winningPattern: winningPattern,
                  boardSize: constraints.maxWidth,
                ),
            ],
          );
        },
      ),
    );
  }
}


import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../../../core/shared/enums.dart';
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
    if (game.gameType == GameType.connect4) {
      return _buildConnect4Board();
    } else {
      return _buildTicTacToeBoard();
    }
  }

  Widget _buildTicTacToeBoard() {
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

  Widget _buildConnect4Board() {
    final state = game.state as Connect4GameStateEntity;
    final winningPattern = state.getWinningPattern();
    final isMyTurn = currentUserId != null && game.isPlayerTurn(currentUserId!);
    final canMakeMove = !game.isOver && isMyTurn && !isPerformingAction;

    return Column(
      children: [
        // Column headers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (col) {
            final isFull = state.isColumnFull(col);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: canMakeMove && !isFull ? () => onCellTap(col) : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isFull
                        ? CupertinoColors.systemGrey4
                        : canMakeMove
                            ? CupertinoColors.systemBlue.withOpacity(0.3)
                            : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: AppText(
                      '${col + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isFull || !canMakeMove
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemBlue,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        // Game board
        Container(
          width: 350,
          height: 300,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBlue.withOpacity(0.2),
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
                    itemCount: 42,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                    ),
                    itemBuilder: (context, index) {
                      final row = index ~/ 7;
                      final col = index % 7;
                      final cellValue = state.getCell(row, col);
                      final isWinningCell =
                          winningPattern?.contains(index) ?? false;

                      Color cellColor;
                      if (cellValue == 'X') {
                        cellColor = CupertinoColors.systemRed;
                      } else if (cellValue == 'O') {
                        cellColor = CupertinoColors.systemBlue;
                      } else {
                        cellColor = CupertinoColors.white;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CupertinoColors.separator,
                            width: 0.8,
                          ),
                          color: isWinningCell
                              ? CupertinoColors.activeGreen.withOpacity(0.25)
                              : CupertinoColors.white,
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(2),
                        child: cellValue != null
                            ? Container(
                                decoration: BoxDecoration(
                                  color: cellColor,
                                  shape: BoxShape.circle,
                                ),
                                margin: const EdgeInsets.all(4),
                              )
                            : null,
                      );
                    },
                  ),
                  // Winning line overlay
                  if (winningPattern != null && winningPattern.length >= 2)
                    _buildConnect4WinningLine(
                      constraints,
                      winningPattern,
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConnect4WinningLine(
    BoxConstraints constraints,
    List<int> pattern,
  ) {
    final cellSize = constraints.maxWidth / 7;
    final rowHeight = constraints.maxHeight / 6;

    final startIdx = pattern.first;
    final endIdx = pattern.last;

    final startRow = startIdx ~/ 7;
    final startCol = startIdx % 7;
    final endRow = endIdx ~/ 7;
    final endCol = endIdx % 7;

    final start = Offset(
      (startCol + 0.5) * cellSize,
      (startRow + 0.5) * rowHeight,
    );
    final end = Offset(
      (endCol + 0.5) * cellSize,
      (endRow + 0.5) * rowHeight,
    );

    return CustomPaint(
      painter: _Connect4LinePainter(start, end),
      size: Size(constraints.maxWidth, constraints.maxHeight),
    );
  }
}

class _Connect4LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  _Connect4LinePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CupertinoColors.black
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant _Connect4LinePainter oldDelegate) =>
      oldDelegate.start != start || oldDelegate.end != end;
}


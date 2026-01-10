import 'package:flutter/cupertino.dart';
import 'tic_tac_toe_cell.dart';
import '../winning_line_painter.dart';

class TicTacToeBoard extends StatelessWidget {
  final List<String> board;
  final List<int>? winningPattern;
  final Animation<double> lineAnimation;
  final void Function(int index) onCellTap;
  final double size;

  const TicTacToeBoard({
    super.key,
    required this.board,
    required this.winningPattern,
    required this.lineAnimation,
    required this.onCellTap,
    this.size = 320,
  });

  Offset _cellCenter(int index, double cellSize) {
    final row = index ~/ 3;
    final col = index % 3;
    return Offset(
      (col + 0.5) * cellSize,
      (row + 0.5) * cellSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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
          final cellSize = constraints.maxWidth / 3;
          
          return Stack(
            children: [
              GridView.builder(
                itemCount: 9,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  final isWinningCell = winningPattern?.contains(index) ?? false;
                  return TicTacToeCell(
                    value: board[index],
                    isWinningCell: isWinningCell,
                    onTap: () => onCellTap(index),
                  );
                },
              ),
              AnimatedWinningLine(
                winningPattern: winningPattern,
                animation: lineAnimation,
                getCellCenter: (index) => _cellCenter(index, cellSize),
              ),
            ],
          );
        },
      ),
    );
  }
}


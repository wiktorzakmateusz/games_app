import 'package:flutter/cupertino.dart';
import 'connect4_cell.dart';
import '../winning_line_painter.dart';

class Connect4Board extends StatelessWidget {
  final List<String> board;
  final List<int>? winningPattern;
  final Animation<double> lineAnimation;
  final String currentPlayer;
  final int? hoverColumn;
  final void Function(int column) onColumnTap;
  final void Function(int column) onColumnHover;
  final VoidCallback onColumnHoverExit;
  final bool Function(int column) canDropInColumn;
  final bool isGameOver;
  final double width;
  final double height;
  final int rows;
  final int columns;

  const Connect4Board({
    super.key,
    required this.board,
    required this.winningPattern,
    required this.lineAnimation,
    required this.currentPlayer,
    required this.hoverColumn,
    required this.onColumnTap,
    required this.onColumnHover,
    required this.onColumnHoverExit,
    required this.canDropInColumn,
    required this.isGameOver,
    this.width = 350,
    this.height = 300,
    this.rows = 6,
    this.columns = 7,
  });

  Offset _cellCenter(int index, double cellSize, double rowHeight) {
    final row = index ~/ columns;
    final col = index % columns;
    return Offset(
      (col + 0.5) * cellSize,
      (row + 0.5) * rowHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
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
          final cellSize = constraints.maxWidth / columns;
          final rowHeight = constraints.maxHeight / rows;
          final totalCells = rows * columns;

          return Stack(
            children: [
              GridView.builder(
                itemCount: totalCells,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                ),
                itemBuilder: (context, index) {
                  final row = index ~/ columns;
                  final col = index % columns;
                  final value = board[index];
                  final isWinningCell = winningPattern?.contains(index) ?? false;
                  
                  final showGhostPiece = hoverColumn == col &&
                      row == 0 &&
                      !isGameOver &&
                      value == '' &&
                      canDropInColumn(col);

                  return Connect4Cell(
                    value: value,
                    isWinningCell: isWinningCell,
                    showGhostPiece: showGhostPiece,
                    currentPlayer: currentPlayer,
                    onTap: !isGameOver ? () => onColumnTap(col) : null,
                    onHoverEnter: () => onColumnHover(col),
                    onHoverExit: onColumnHoverExit,
                  );
                },
              ),
              AnimatedWinningLine(
                winningPattern: winningPattern,
                animation: lineAnimation,
                getCellCenter: (index) => _cellCenter(index, cellSize, rowHeight),
              ),
            ],
          );
        },
      ),
    );
  }
}


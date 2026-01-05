import 'package:flutter/cupertino.dart';
import 'mini_sudoku_cell.dart';

class MiniSudokuBoard extends StatelessWidget {
  final List<int> board;
  final List<bool> isFixed;
  final Set<int> wrongIndices;
  final void Function(int index) onCellTap;
  final double size;

  const MiniSudokuBoard({
    super.key,
    required this.board,
    required this.isFixed,
    required this.wrongIndices,
    required this.onCellTap,
    this.size = 320,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.black, width: 2),
        color: CupertinoColors.white,
        boxShadow: const [
          BoxShadow(
            color: CupertinoColors.systemGrey4,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        itemCount: 16,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemBuilder: (context, index) {
          final row = index ~/ 4;
          final col = index % 4;
          final hasRightBorder = (col == 1);
          final hasBottomBorder = (row == 1);

          return MiniSudokuCell(
            value: board[index],
            isFixed: isFixed[index],
            isWrong: wrongIndices.contains(index),
            hasRightBorder: hasRightBorder,
            hasBottomBorder: hasBottomBorder,
            onTap: () => onCellTap(index),
          );
        },
      ),
    );
  }
}


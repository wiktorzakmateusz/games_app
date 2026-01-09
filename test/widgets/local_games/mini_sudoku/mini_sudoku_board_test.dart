import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/local_games/mini_sudoku/mini_sudoku_board.dart';
import 'package:games_app/widgets/local_games/mini_sudoku/mini_sudoku_cell.dart';

void main() {
  group('MiniSudokuBoard Widget Tests', () {
    testWidgets('displays 16 cells (4x4 grid)', (WidgetTester tester) async {
      final board = List.filled(16, 0);
      final isFixed = List.filled(16, false);

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: MiniSudokuBoard(
                board: board,
                isFixed: isFixed,
                wrongIndices: {},
                onCellTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MiniSudokuCell), findsNWidgets(16));
    });

    testWidgets('displays numbers correctly', (WidgetTester tester) async {
      final board = [1, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final isFixed = List.filled(16, false);

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: MiniSudokuBoard(
                board: board,
                isFixed: isFixed,
                wrongIndices: {},
                onCellTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('calls onCellTap when cell is tapped',
        (WidgetTester tester) async {
      int? tappedIndex;
      final board = List.filled(16, 0);
      final isFixed = List.filled(16, false);

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: MiniSudokuBoard(
                board: board,
                isFixed: isFixed,
                wrongIndices: {},
                onCellTap: (index) => tappedIndex = index,
              ),
            ),
          ),
        ),
      );

      final cells = tester.widgetList<MiniSudokuCell>(find.byType(MiniSudokuCell));
      final firstCell = cells.first;
      await tester.tap(find.byWidget(firstCell));

      expect(tappedIndex, 0);
    });

    testWidgets('highlights wrong cells', (WidgetTester tester) async {
      final board = [1, 2, 1, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final isFixed = List.filled(16, false);

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: MiniSudokuBoard(
                board: board,
                isFixed: isFixed,
                wrongIndices: {0, 2}, // Duplicate 1s in same row
                onCellTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MiniSudokuCell), findsNWidgets(16));
    });

    testWidgets('marks fixed cells', (WidgetTester tester) async {
      final board = [1, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final isFixed = List.generate(16, (i) => i < 4);

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: MiniSudokuBoard(
                board: board,
                isFixed: isFixed,
                wrongIndices: {},
                onCellTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MiniSudokuCell), findsNWidgets(16));
    });

    testWidgets('respects custom size', (WidgetTester tester) async {
      final board = List.filled(16, 0);
      final isFixed = List.filled(16, false);

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: MiniSudokuBoard(
                board: board,
                isFixed: isFixed,
                wrongIndices: {},
                onCellTap: (_) {},
                size: 400,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(GridView),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.constraints?.maxWidth, 400);
      expect(container.constraints?.maxHeight, 400);
    });
  });
}


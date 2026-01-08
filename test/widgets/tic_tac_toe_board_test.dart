import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/local_games/tic_tac_toe/tic_tac_toe_board.dart';
import 'package:games_app/widgets/local_games/tic_tac_toe/tic_tac_toe_cell.dart';

void main() {
  group('TicTacToeBoard Widget Tests', () {
    testWidgets('displays empty board with 9 cells',
        (WidgetTester tester) async {
      final board = List.filled(9, '');

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: TicTacToeBoard(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0.0),
                onCellTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TicTacToeCell), findsNWidgets(9));
    });

    testWidgets('displays X and O symbols correctly',
        (WidgetTester tester) async {
      final board = [
        'X', 'O', 'X',
        '', '', '',
        'O', 'X', ''
      ];

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: TicTacToeBoard(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0.0),
                onCellTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('X'), findsNWidgets(3));
      expect(find.text('O'), findsNWidgets(2));
    });

    testWidgets('calls onCellTap with correct index when cell is tapped',
        (WidgetTester tester) async {
      final board = List.filled(9, '');
      int? tappedIndex;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: TicTacToeBoard(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0.0),
                onCellTap: (index) {
                  tappedIndex = index;
                },
              ),
            ),
          ),
        ),
      );

      // Tap the first cell (index 0)
      await tester.tap(find.byType(TicTacToeCell).at(0));
      await tester.pump();

      expect(tappedIndex, 0);

      // Tap the middle cell (index 4)
      await tester.tap(find.byType(TicTacToeCell).at(4));
      await tester.pump();

      expect(tappedIndex, 4);

      // Tap the last cell (index 8)
      await tester.tap(find.byType(TicTacToeCell).at(8));
      await tester.pump();

      expect(tappedIndex, 8);
    });

    testWidgets('highlights winning cells when winningPattern is provided',
        (WidgetTester tester) async {
      final board = [
        'X', 'X', 'X',
        'O', 'O', '',
        '', '', ''
      ];
      final winningPattern = [0, 1, 2]; // Top row

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: TicTacToeBoard(
                board: board,
                winningPattern: winningPattern,
                lineAnimation: const AlwaysStoppedAnimation(1.0),
                onCellTap: (_) {},
              ),
            ),
          ),
        ),
      );

      // Find all cells
      final cells = tester.widgetList<TicTacToeCell>(
        find.byType(TicTacToeCell),
      );

      // First three cells should be winning cells
      expect(cells.elementAt(0).isWinningCell, true);
      expect(cells.elementAt(1).isWinningCell, true);
      expect(cells.elementAt(2).isWinningCell, true);

      // Other cells should not be winning cells
      expect(cells.elementAt(3).isWinningCell, false);
      expect(cells.elementAt(4).isWinningCell, false);
    });

    testWidgets('has correct size', (WidgetTester tester) async {
      final board = List.filled(9, '');
      const expectedSize = 320.0;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: TicTacToeBoard(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0.0),
                onCellTap: (_) {},
                size: expectedSize,
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

      expect(container.constraints?.maxWidth, expectedSize);
      expect(container.constraints?.maxHeight, expectedSize);
    });

    testWidgets('renders with custom size', (WidgetTester tester) async {
      final board = List.filled(9, '');
      const customSize = 400.0;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: TicTacToeBoard(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0.0),
                onCellTap: (_) {},
                size: customSize,
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

      expect(container.constraints?.maxWidth, customSize);
      expect(container.constraints?.maxHeight, customSize);
    });

    testWidgets('board uses 3x3 grid layout', (WidgetTester tester) async {
      final board = List.filled(9, '');

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: TicTacToeBoard(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0.0),
                onCellTap: (_) {},
              ),
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate
          as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, 3);
    });
  });
}


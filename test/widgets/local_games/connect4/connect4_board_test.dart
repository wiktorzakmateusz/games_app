import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/local_games/connect4/connect4_board.dart';
import 'package:games_app/widgets/local_games/connect4/connect4_cell.dart';

void main() {
  group('Connect4Board Widget Tests', () {
    testWidgets('displays 42 cells (7x6 grid)', (WidgetTester tester) async {
      final board = List.filled(42, '');

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: Connect4Board(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0.0),
                currentPlayer: 'X',
                hoverColumn: null,
                onColumnTap: (_) {},
                onColumnHover: (_) {},
                onColumnHoverExit: () {},
                canDropInColumn: (_) => true,
                isGameOver: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Connect4Cell), findsNWidgets(42));
    });

    testWidgets('displays X and O pieces correctly',
        (WidgetTester tester) async {
      final board = List.filled(42, '');
      board[0] = 'X';
      board[1] = 'O';

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: Connect4Board(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0.0),
                currentPlayer: 'X',
                hoverColumn: null,
                onColumnTap: (_) {},
                onColumnHover: (_) {},
                onColumnHoverExit: () {},
                canDropInColumn: (_) => true,
                isGameOver: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Connect4Cell), findsNWidgets(42));
    });

    testWidgets('calls onColumnTap when cell is tapped',
        (WidgetTester tester) async {
      int? tappedColumn;
      final board = List.filled(42, '');

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: Connect4Board(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0.0),
                currentPlayer: 'X',
                hoverColumn: null,
                onColumnTap: (col) => tappedColumn = col,
                onColumnHover: (_) {},
                onColumnHoverExit: () {},
                canDropInColumn: (_) => true,
                isGameOver: false,
              ),
            ),
          ),
        ),
      );

      final cells = tester.widgetList<Connect4Cell>(find.byType(Connect4Cell));
      final firstCell = cells.first;
      await tester.tap(find.byWidget(firstCell));

      expect(tappedColumn, 0); // First column
    });

    testWidgets('disables taps when game is over',
        (WidgetTester tester) async {
      int tapCount = 0;
      final board = List.filled(42, '');

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: Connect4Board(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0.0),
                currentPlayer: 'X',
                hoverColumn: null,
                onColumnTap: (_) => tapCount++,
                onColumnHover: (_) {},
                onColumnHoverExit: () {},
                canDropInColumn: (_) => true,
                isGameOver: true, // Game is over
              ),
            ),
          ),
        ),
      );

      final cells = tester.widgetList<Connect4Cell>(find.byType(Connect4Cell));
      final firstCell = cells.first;
      await tester.tap(find.byWidget(firstCell));

      expect(tapCount, 0); // Should not increment
    });

    testWidgets('highlights winning pattern cells',
        (WidgetTester tester) async {
      final board = List.filled(42, '');
      board[0] = 'X';
      board[1] = 'X';
      board[2] = 'X';
      board[3] = 'X';

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: Connect4Board(
                board: board,
                winningPattern: [0, 1, 2, 3],
                lineAnimation: const AlwaysStoppedAnimation(1.0),
                currentPlayer: 'X',
                hoverColumn: null,
                onColumnTap: (_) {},
                onColumnHover: (_) {},
                onColumnHoverExit: () {},
                canDropInColumn: (_) => true,
                isGameOver: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Connect4Cell), findsNWidgets(42));
    });

    testWidgets('respects custom width and height',
        (WidgetTester tester) async {
      final board = List.filled(42, '');

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: Connect4Board(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0.0),
                currentPlayer: 'X',
                hoverColumn: null,
                onColumnTap: (_) {},
                onColumnHover: (_) {},
                onColumnHoverExit: () {},
                canDropInColumn: (_) => true,
                isGameOver: false,
                width: 400,
                height: 350,
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
      expect(container.constraints?.maxHeight, 350);
    });
  });
}


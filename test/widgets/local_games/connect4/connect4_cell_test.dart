import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/local_games/connect4/connect4_cell.dart';

void main() {
  group('Connect4Cell Widget Tests', () {
    testWidgets('displays empty cell', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Connect4Cell(
              value: '',
              isWinningCell: false,
              showGhostPiece: false,
              currentPlayer: 'X',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Connect4Cell), findsOneWidget);
    });

    testWidgets('displays X piece with red color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Connect4Cell(
              value: 'X',
              isWinningCell: false,
              showGhostPiece: false,
              currentPlayer: 'X',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Connect4Cell), findsOneWidget);
    });

    testWidgets('displays O piece with blue color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Connect4Cell(
              value: 'O',
              isWinningCell: false,
              showGhostPiece: false,
              currentPlayer: 'O',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Connect4Cell), findsOneWidget);
    });

    testWidgets('calls onTap when cell is tapped',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Connect4Cell(
              value: '',
              isWinningCell: false,
              showGhostPiece: false,
              currentPlayer: 'X',
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Connect4Cell));
      await tester.pump();

      expect(wasTapped, true);
    });

    testWidgets('shows ghost piece when hovering',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Connect4Cell(
              value: '',
              isWinningCell: false,
              showGhostPiece: true,
              currentPlayer: 'X',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Connect4Cell), findsOneWidget);
    });

    testWidgets('has green background when isWinningCell is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Connect4Cell(
              value: 'X',
              isWinningCell: true,
              showGhostPiece: false,
              currentPlayer: 'X',
              onTap: () {},
            ),
          ),
        ),
      );

      final outerContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ).first,
      );

      expect(
        outerContainer.decoration,
        isA<BoxDecoration>().having(
          (d) => d.color,
          'color',
          CupertinoColors.activeGreen.withOpacity(0.25),
        ),
      );
    });

    testWidgets('has white background when not a winning cell',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Connect4Cell(
              value: '',
              isWinningCell: false,
              showGhostPiece: false,
              currentPlayer: 'X',
              onTap: () {},
            ),
          ),
        ),
      );

      final outerContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ).first,
      );

      expect(
        outerContainer.decoration,
        isA<BoxDecoration>().having(
          (d) => d.color,
          'color',
          CupertinoColors.white,
        ),
      );
    });

    testWidgets('does not call onTap when onTap is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Connect4Cell(
              value: '',
              isWinningCell: false,
              showGhostPiece: false,
              currentPlayer: 'X',
              onTap: null,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Connect4Cell));
      await tester.pump();

      // Should not throw
      expect(find.byType(Connect4Cell), findsOneWidget);
    });
  });
}


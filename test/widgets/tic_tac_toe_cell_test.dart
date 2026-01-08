import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/local_games/tic_tac_toe/tic_tac_toe_cell.dart';

void main() {
  group('TicTacToeCell Widget Tests', () {
    testWidgets('displays empty cell', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: TicTacToeCell(
              value: '',
              isWinningCell: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('displays X symbol', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: TicTacToeCell(
              value: 'X',
              isWinningCell: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('X'), findsOneWidget);
    });

    testWidgets('displays O symbol', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: TicTacToeCell(
              value: 'O',
              isWinningCell: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('O'), findsOneWidget);
    });

    testWidgets('calls onTap when cell is tapped',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: TicTacToeCell(
              value: '',
              isWinningCell: false,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TicTacToeCell));
      await tester.pump();

      expect(wasTapped, true);
    });

    testWidgets('has different background color when isWinningCell is true',
        (WidgetTester tester) async {
      // Build widget with isWinningCell = true
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: TicTacToeCell(
              value: 'X',
              isWinningCell: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final winningContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );

      // Winning cell should have green tinted background
      expect(
        winningContainer.decoration,
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
            child: TicTacToeCell(
              value: 'O',
              isWinningCell: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final normalContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );

      expect(
        normalContainer.decoration,
        isA<BoxDecoration>().having(
          (d) => d.color,
          'color',
          CupertinoColors.white,
        ),
      );
    });

    testWidgets('X symbol has red color', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: TicTacToeCell(
              value: 'X',
              isWinningCell: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('X'));

      expect(textWidget.style?.color, CupertinoColors.systemRed);
    });

    testWidgets('O symbol has blue color', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: TicTacToeCell(
              value: 'O',
              isWinningCell: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('O'));

      expect(textWidget.style?.color, CupertinoColors.systemBlue);
    });

    testWidgets('text has correct font size and weight',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: TicTacToeCell(
              value: 'X',
              isWinningCell: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('X'));

      expect(textWidget.style?.fontSize, 44);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });
  });
}


import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/local_games/mini_sudoku/mini_sudoku_cell.dart';

void main() {
  group('MiniSudokuCell Widget Tests', () {
    testWidgets('displays empty cell when value is 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: MiniSudokuCell(
              value: 0,
              isFixed: false,
              isWrong: false,
              hasRightBorder: false,
              hasBottomBorder: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('displays number when value is set',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: MiniSudokuCell(
              value: 3,
              isFixed: false,
              isWrong: false,
              hasRightBorder: false,
              hasBottomBorder: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('calls onTap when cell is tapped',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: MiniSudokuCell(
              value: 0,
              isFixed: false,
              isWrong: false,
              hasRightBorder: false,
              hasBottomBorder: false,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MiniSudokuCell));
      await tester.pump();

      expect(wasTapped, true);
    });

    testWidgets('shows red text when cell is wrong',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: MiniSudokuCell(
              value: 1,
              isFixed: false,
              isWrong: true,
              hasRightBorder: false,
              hasBottomBorder: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('1'));
      expect(textWidget.style?.color, CupertinoColors.systemRed);
    });

    testWidgets('shows bold black text when cell is fixed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: MiniSudokuCell(
              value: 2,
              isFixed: true,
              isWrong: false,
              hasRightBorder: false,
              hasBottomBorder: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('2'));
      expect(textWidget.style?.color, CupertinoColors.black);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('shows blue text when cell is user input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: MiniSudokuCell(
              value: 3,
              isFixed: false,
              isWrong: false,
              hasRightBorder: false,
              hasBottomBorder: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('3'));
      expect(textWidget.style?.color, CupertinoColors.activeBlue);
      expect(textWidget.style?.fontWeight, FontWeight.normal);
    });

    testWidgets('has thick right border when hasRightBorder is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: MiniSudokuCell(
              value: 0,
              isFixed: false,
              isWrong: false,
              hasRightBorder: true,
              hasBottomBorder: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );

      final border = (container.decoration as BoxDecoration).border as Border;
      expect(border.right.width, 2.0);
      expect(border.right.color, CupertinoColors.black);
    });

    testWidgets('has thick bottom border when hasBottomBorder is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: MiniSudokuCell(
              value: 0,
              isFixed: false,
              isWrong: false,
              hasRightBorder: false,
              hasBottomBorder: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );

      final border = (container.decoration as BoxDecoration).border as Border;
      expect(border.bottom.width, 2.0);
      expect(border.bottom.color, CupertinoColors.black);
    });
  });
}


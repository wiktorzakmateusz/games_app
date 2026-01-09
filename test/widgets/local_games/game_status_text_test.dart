import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/local_games/game_status_text.dart';

void main() {
  group('GameStatusText Widget Tests', () {
    testWidgets('displays text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameStatusText(text: 'Player X Wins!'),
            ),
          ),
        ),
      );

      expect(find.text('Player X Wins!'), findsOneWidget);
    });

    testWidgets('uses default black color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameStatusText(text: 'Game in progress'),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Game in progress'));
      expect(textWidget.style?.color, CupertinoColors.black);
    });

    testWidgets('uses custom color when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameStatusText(
                text: 'Player O Wins!',
                color: CupertinoColors.systemBlue,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Player O Wins!'));
      expect(textWidget.style?.color, CupertinoColors.systemBlue);
    });

    testWidgets('uses default font size of 22', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameStatusText(text: 'Draw!'),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Draw!'));
      expect(textWidget.style?.fontSize, 22);
    });

    testWidgets('uses custom font size when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameStatusText(
                text: 'Your Turn',
                fontSize: 28,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Your Turn'));
      expect(textWidget.style?.fontSize, 28);
    });

    testWidgets('has medium font weight', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameStatusText(text: 'Status'),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Status'));
      expect(textWidget.style?.fontWeight, FontWeight.w500);
    });

    testWidgets('has center text alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameStatusText(text: 'Centered Text'),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Centered Text'));
      expect(textWidget.textAlign, TextAlign.center);
    });
  });
}


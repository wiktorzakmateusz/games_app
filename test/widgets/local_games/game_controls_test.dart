import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/local_games/game_controls.dart';

void main() {
  group('GameControls Widget Tests', () {
    testWidgets('shows reset button when game is ongoing',
        (WidgetTester tester) async {
      bool resetCalled = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameControls(
                isGameOver: false,
                onReset: () => resetCalled = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Reset'), findsOneWidget);
      expect(find.byType(CupertinoButton), findsOneWidget);

      await tester.tap(find.byType(CupertinoButton));
      await tester.pump();

      expect(resetCalled, true);
    });

    testWidgets('shows play again button when game is over',
        (WidgetTester tester) async {
      bool resetCalled = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameControls(
                isGameOver: true,
                onReset: () => resetCalled = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Play Again'), findsOneWidget);

      await tester.tap(find.byType(CupertinoButton));
      await tester.pump();

      expect(resetCalled, true);
    });

    testWidgets('shows new game button when onNewGame is provided',
        (WidgetTester tester) async {
      bool newGameCalled = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameControls(
                isGameOver: true,
                onReset: () {},
                onNewGame: () => newGameCalled = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('New Game'), findsOneWidget);

      await tester.tap(find.byType(CupertinoButton));
      await tester.pump();

      expect(newGameCalled, true);
    });

    testWidgets('uses custom reset label', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameControls(
                isGameOver: false,
                onReset: () {},
                resetLabel: 'Restart',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Restart'), findsOneWidget);
      expect(find.text('Reset'), findsNothing);
    });

    testWidgets('uses custom new game label', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameControls(
                isGameOver: true,
                onReset: () {},
                onNewGame: () {},
                newGameLabel: 'Start Over',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Start Over'), findsOneWidget);
      expect(find.text('New Game'), findsNothing);
    });

    testWidgets('button has correct height', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameControls(
                isGameOver: false,
                onReset: () {},
              ),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CupertinoButton),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.height, 50);
    });
  });
}


import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/game_button.dart';

void main() {
  group('GameButton Widget Tests', () {
    testWidgets('displays the correct label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameButton(label: 'Play Game'),
            ),
          ),
        ),
      );

      expect(find.text('Play Game'), findsOneWidget);
    });

    testWidgets('calls onTap when button is pressed',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameButton(
                label: 'Tap Me',
                onTap: () {
                  wasTapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CupertinoButton));
      await tester.pump();

      expect(wasTapped, true);
    });

    testWidgets('button is disabled when onTap is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameButton(
                label: 'Disabled',
                onTap: null,
              ),
            ),
          ),
        ),
      );

      final button = tester.widget<CupertinoButton>(
        find.byType(CupertinoButton),
      );

      expect(button.enabled, false);
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('has correct width', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameButton(
                label: 'Test',
                onTap: () {},
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

      expect(sizedBox.width, 200);
    });

    testWidgets('renders with correct border radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameButton(
                label: 'Test',
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      final button = tester.widget<CupertinoButton>(
        find.byType(CupertinoButton),
      );

      expect(button.borderRadius, BorderRadius.circular(12));
    });
  });
}


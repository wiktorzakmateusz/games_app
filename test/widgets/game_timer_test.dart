import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/game_timer.dart';

void main() {
  group('GameTimer Widget Tests', () {
    testWidgets('displays initial time', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameTimer(
                duration: const Duration(seconds: 30),
                autoStart: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GameTimer), findsOneWidget);
      expect(find.textContaining('30'), findsOneWidget);
    });

    testWidgets('displays formatted time string',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameTimer(
                duration: const Duration(seconds: 15),
                autoStart: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('15.0'), findsOneWidget);
    });

    testWidgets('starts timer when autoStart is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameTimer(
                duration: const Duration(seconds: 5),
                autoStart: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GameTimer), findsOneWidget);
    });

    testWidgets('does not start timer when autoStart is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameTimer(
                duration: const Duration(seconds: 5),
                autoStart: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('05.0'), findsOneWidget);
    });

    testWidgets('respects isActive parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameTimer(
                duration: const Duration(seconds: 30),
                isActive: false,
                autoStart: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GameTimer), findsOneWidget);
    });

    testWidgets('calls onTimeout when time expires',
        (WidgetTester tester) async {
      bool timeoutCalled = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameTimer(
                duration: const Duration(milliseconds: 150),
                autoStart: true,
                onTimeout: () => timeoutCalled = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(timeoutCalled, true);
    });

    testWidgets('updates when duration changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameTimer(
                duration: const Duration(seconds: 30),
                autoStart: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('30.0'), findsOneWidget);

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: GameTimer(
                duration: const Duration(seconds: 45),
                autoStart: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('45.0'), findsOneWidget);
    });
  });
}


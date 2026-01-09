import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/navigation/app_game_nav_bar.dart';
import 'package:games_app/core/game_logic/game_logic.dart';

void main() {
  group('AppGameNavBar Widget Tests', () {
    testWidgets('displays game name', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            navigationBar: const AppGameNavBar(gameName: 'Tic Tac Toe'),
            child: Container(),
          ),
        ),
      );

      expect(find.text('Tic Tac Toe'), findsOneWidget);
    });

    testWidgets('displays game name with difficulty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            navigationBar: const AppGameNavBar(
              gameName: 'Mini Sudoku',
              difficulty: GameDifficulty.easy,
            ),
            child: Container(),
          ),
        ),
      );

      expect(find.text('Mini Sudoku - Easy'), findsOneWidget);
    });

    testWidgets('displays game name with custom title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            navigationBar: const AppGameNavBar(
              gameName: 'Connect 4',
              title: 'Multiplayer',
            ),
            child: Container(),
          ),
        ),
      );

      expect(find.text('Connect 4 - Multiplayer'), findsOneWidget);
    });

    testWidgets('shows back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            navigationBar: const AppGameNavBar(gameName: 'Tic Tac Toe'),
            child: Container(),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
    });

    testWidgets('back button navigates to /home',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          routes: {
            '/': (context) => CupertinoPageScaffold(
                  navigationBar: const AppGameNavBar(gameName: 'Tic Tac Toe'),
                  child: Container(),
                ),
            '/home': (context) => CupertinoPageScaffold(
                  child: Container(key: const Key('home_page')),
                ),
          },
        ),
      );

      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_page')), findsOneWidget);
    });

    testWidgets('has correct preferred size', (WidgetTester tester) async {
      const navBar = AppGameNavBar(gameName: 'Tic Tac Toe');
      expect(navBar.preferredSize.height, kMinInteractiveDimension);
    });

    testWidgets('should not fully obstruct', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              const navBar = AppGameNavBar(gameName: 'Tic Tac Toe');
              expect(navBar.shouldFullyObstruct(context), false);
              return Container();
            },
          ),
        ),
      );
    });
  });
}


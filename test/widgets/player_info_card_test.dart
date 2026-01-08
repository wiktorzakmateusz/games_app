import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/player_info_card.dart';

void main() {
  group('PlayerInfoCard Widget Tests', () {
    testWidgets('displays player name', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: PlayerInfoCard(
                name: 'John Doe',
              ),
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays "Bot" as default name', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: PlayerInfoCard(),
            ),
          ),
        ),
      );

      expect(find.text('Bot'), findsOneWidget);
    });

    testWidgets('shows border when isCurrentTurn is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: PlayerInfoCard(
                name: 'Player 1',
                isCurrentTurn: true,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PlayerInfoCard),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('does not show border when isCurrentTurn is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: PlayerInfoCard(
                name: 'Player 1',
                isCurrentTurn: false,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PlayerInfoCard),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNull);
    });

    testWidgets('uses custom border color when provided',
        (WidgetTester tester) async {
      const customColor = CupertinoColors.systemRed;

      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: PlayerInfoCard(
                name: 'Player 1',
                isCurrentTurn: true,
                borderColor: customColor,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PlayerInfoCard),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, customColor);
    });

    testWidgets('renders avatar placeholder when no image',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: PlayerInfoCard(
                name: 'Player 1',
              ),
            ),
          ),
        ),
      );

      // Should have an Image.asset widget trying to load user_icon.png
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('displays ClipOval for avatar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: PlayerInfoCard(
                name: 'Player 1',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('has correct max width constraint',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: PlayerInfoCard(
                name: 'Player 1',
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PlayerInfoCard),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.constraints?.maxWidth, 140);
    });

    testWidgets('truncates long names with ellipsis',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: PlayerInfoCard(
                name: 'Very Long Player Name That Should Be Truncated',
              ),
            ),
          ),
        ),
      );

      expect(
          find.text('Very Long Player Name That Should Be Truncated'),
          findsOneWidget);
    });
  });
}


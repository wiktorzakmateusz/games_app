import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/game_header.dart';
import 'package:games_app/widgets/player_info_card.dart';
import 'package:games_app/widgets/game_timer.dart';

void main() {
  group('GameHeader Widget Tests', () {
    testWidgets('displays both player cards and timer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: GameHeader(
              player1Name: 'Player 1',
              player2Name: 'Player 2',
              isPlayer1Turn: true,
              timerDuration: const Duration(seconds: 30),
            ),
          ),
        ),
      );

      expect(find.byType(PlayerInfoCard), findsNWidgets(2));
      expect(find.byType(GameTimer), findsOneWidget);
      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);
    });

    testWidgets('highlights player 1 when it is their turn',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: GameHeader(
              player1Name: 'Player 1',
              player2Name: 'Player 2',
              isPlayer1Turn: true,
              timerDuration: const Duration(seconds: 30),
            ),
          ),
        ),
      );

      final player1Card = tester.widgetList<PlayerInfoCard>(
        find.byType(PlayerInfoCard),
      ).first;

      final player2Card = tester.widgetList<PlayerInfoCard>(
        find.byType(PlayerInfoCard),
      ).last;

      expect(player1Card.isCurrentTurn, true);
      expect(player2Card.isCurrentTurn, false);
    });

    testWidgets('highlights player 2 when it is their turn',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: GameHeader(
              player1Name: 'Player 1',
              player2Name: 'Player 2',
              isPlayer1Turn: false,
              timerDuration: const Duration(seconds: 30),
            ),
          ),
        ),
      );

      final player1Card = tester.widgetList<PlayerInfoCard>(
        find.byType(PlayerInfoCard),
      ).first;

      final player2Card = tester.widgetList<PlayerInfoCard>(
        find.byType(PlayerInfoCard),
      ).last;

      expect(player1Card.isCurrentTurn, false);
      expect(player2Card.isCurrentTurn, true);
    });

    testWidgets('timer is inactive when game is over',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: GameHeader(
              player1Name: 'Player 1',
              player2Name: 'Player 2',
              isPlayer1Turn: true,
              isGameOver: true,
              timerDuration: const Duration(seconds: 30),
            ),
          ),
        ),
      );

      final timer = tester.widget<GameTimer>(find.byType(GameTimer));
      expect(timer.isActive, false);
    });

    testWidgets('timer is active when game is ongoing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: GameHeader(
              player1Name: 'Player 1',
              player2Name: 'Player 2',
              isPlayer1Turn: true,
              isGameOver: false,
              timerDuration: const Duration(seconds: 30),
            ),
          ),
        ),
      );

      final timer = tester.widget<GameTimer>(find.byType(GameTimer));
      expect(timer.isActive, true);
    });

    testWidgets('passes custom border colors to player cards',
        (WidgetTester tester) async {
      const customColor1 = CupertinoColors.systemRed;
      const customColor2 = CupertinoColors.systemBlue;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: GameHeader(
              player1Name: 'Player 1',
              player2Name: 'Player 2',
              player1BorderColor: customColor1,
              player2BorderColor: customColor2,
              isPlayer1Turn: true,
              timerDuration: const Duration(seconds: 30),
            ),
          ),
        ),
      );

      final player1Card = tester.widgetList<PlayerInfoCard>(
        find.byType(PlayerInfoCard),
      ).first;

      final player2Card = tester.widgetList<PlayerInfoCard>(
        find.byType(PlayerInfoCard),
      ).last;

      expect(player1Card.borderColor, customColor1);
      expect(player2Card.borderColor, customColor2);
    });

    testWidgets('handles bot players correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: GameHeader(
              player1Name: 'Human Player',
              player1IsBot: false,
              player2Name: 'Bot',
              player2IsBot: true,
              isPlayer1Turn: true,
              timerDuration: const Duration(seconds: 30),
            ),
          ),
        ),
      );

      final player1Card = tester.widgetList<PlayerInfoCard>(
        find.byType(PlayerInfoCard),
      ).first;

      final player2Card = tester.widgetList<PlayerInfoCard>(
        find.byType(PlayerInfoCard),
      ).last;

      expect(player1Card.isBot, false);
      expect(player2Card.isBot, true);
    });
  });
}


import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/player_info_card.dart';
import 'package:games_app/widgets/game_timer.dart';
import 'package:games_app/core/utils/responsive_layout.dart';

class GameHeader extends StatelessWidget {
  // Player 1 info
  final String? player1Name;
  final String? player1ImageUrl;
  final bool player1IsBot;
  final Color? player1BorderColor;

  // Player 2 info
  final String? player2Name;
  final String? player2ImageUrl;
  final bool player2IsBot;
  final Color? player2BorderColor;

  // Turn management
  final bool isPlayer1Turn;
  final bool isGameOver;
  final bool shouldRunTimer; // Whether timer should be active (e.g., only for human players)

  // Timer configuration
  final Duration timerDuration;
  final VoidCallback? onTimeout;

  const GameHeader({
    super.key,
    this.player1Name,
    this.player1ImageUrl,
    this.player1IsBot = false,
    this.player1BorderColor,
    this.player2Name,
    this.player2ImageUrl,
    this.player2IsBot = false,
    this.player2BorderColor,
    required this.isPlayer1Turn,
    this.isGameOver = false,
    this.shouldRunTimer = true,
    required this.timerDuration,
    this.onTimeout,
  });

  @override
  Widget build(BuildContext context) {
    // Timer should run whenever it's anyone's turn (not just the current player's view)
    // Both players should see the timer counting down
    final timerIsActive = !isGameOver && shouldRunTimer;
    final horizontalPadding = ResponsiveLayout.getHorizontalPadding(context);
    final verticalPadding = ResponsiveLayout.getVerticalPadding(context);
    final spacing = ResponsiveLayout.getSpacing(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPadding.left / 2,
          right: horizontalPadding.right / 2,
          top: verticalPadding.top / 2,
          bottom: verticalPadding.bottom / 2,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: PlayerInfoCard(
                  name: player1Name,
                  imageUrl: player1ImageUrl,
                  isBot: player1IsBot,
                  isCurrentTurn: isPlayer1Turn && !isGameOver,
                  borderColor: player1BorderColor,
                ),
              ),
              SizedBox(width: spacing / 2),
              GameTimer(
                key: ValueKey(isPlayer1Turn),
                duration: timerDuration,
                isActive: timerIsActive,
                onTimeout: onTimeout,
              ),
              SizedBox(width: spacing / 2),
              Expanded(
                child: PlayerInfoCard(
                  name: player2Name,
                  imageUrl: player2ImageUrl,
                  isBot: player2IsBot,
                  isCurrentTurn: !isPlayer1Turn && !isGameOver,
                  borderColor: player2BorderColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


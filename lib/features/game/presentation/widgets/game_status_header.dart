import 'package:flutter/cupertino.dart';
import '../../domain/entities/game_entity.dart';

class GameStatusHeader extends StatelessWidget {
  final GameEntity game;
  final String? currentUserId;

  const GameStatusHeader({
    super.key,
    required this.game,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isMyTurn = currentUserId != null && game.isPlayerTurn(currentUserId!);
    final myPlayer = game.players.firstWhere(
      (p) => p.userId == currentUserId,
      orElse: () => game.players.first,
    );
    final currentPlayer = game.currentPlayer;

    String statusText;
    Color statusColor = CupertinoColors.label;

    if (game.isOver) {
      if (game.state.isDraw) {
        statusText = "It's a draw!";
        statusColor = CupertinoColors.systemGrey;
      } else if (game.winner?.userId == currentUserId) {
        statusText = 'You won! 🎉';
        statusColor = CupertinoColors.activeGreen;
      } else {
        statusText = '${game.winner?.displayName ?? "Opponent"} won!';
        statusColor = CupertinoColors.destructiveRed;
      }
    } else {
      if (isMyTurn) {
        statusText = 'Your turn (${myPlayer.symbol ?? ""})';
        statusColor = CupertinoColors.activeBlue;
      } else {
        statusText =
            '${currentPlayer?.displayName ?? "Opponent"}\'s turn (${currentPlayer?.symbol ?? ""})';
        statusColor = CupertinoColors.secondaryLabel;
      }
    }

    return Text(
      statusText,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: statusColor,
      ),
      textAlign: TextAlign.center,
    );
  }
}


import 'package:flutter/cupertino.dart';
import '../../core/services/audio_service.dart';


class GameControls extends StatelessWidget {
  final bool isGameOver;
  final VoidCallback onReset;
  final VoidCallback? onNewGame;
  final String? resetLabel;
  final String? newGameLabel;

  const GameControls({
    super.key,
    required this.isGameOver,
    required this.onReset,
    this.onNewGame,
    this.resetLabel,
    this.newGameLabel,
  });

  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();
    
    if (!isGameOver && onNewGame == null) {
      return SizedBox(
        height: 50,
        child: CupertinoButton.filled(
          onPressed: () {
            audioService.playClickSound();
            onReset();
          },
          child: Text(resetLabel ?? 'Reset'),
        ),
      );
    }

    if (isGameOver) {
      return SizedBox(
        height: 50,
        child: CupertinoButton.filled(
          onPressed: () {
            audioService.playClickSound();
            if (onNewGame != null) {
              onNewGame!();
            } else {
              onReset();
            }
          },
          child: Text(newGameLabel ?? (onNewGame != null ? 'New Game' : 'Play Again')),
        ),
      );
    }

    return const SizedBox(height: 50);
  }
}


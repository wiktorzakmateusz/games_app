import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';

class PlayerNamesPage extends StatefulWidget {
  const PlayerNamesPage({super.key});

  @override
  State<PlayerNamesPage> createState() => _PlayerNamesPageState();
}

class _PlayerNamesPageState extends State<PlayerNamesPage> {
  final TextEditingController playerOneController = TextEditingController();
  final TextEditingController playerTwoController = TextEditingController();

  @override
  void dispose() {
    playerOneController.dispose();
    playerTwoController.dispose();
    super.dispose();
  }

  void _startGame() {
    final playerOneName = playerOneController.text.trim().isEmpty
        ? 'Player 1'
        : playerOneController.text.trim();
    final playerTwoName = playerTwoController.text.trim().isEmpty
        ? 'Player 2'
        : playerTwoController.text.trim();

    final String gameType = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'tic_tac_toe';
    
    String routeName;
    if (gameType == 'connect4') {
      routeName = '/connect4';
    } else {
      routeName = '/tic_tac_toe';
    }

    Navigator.pushNamed(
      context,
      routeName,
      arguments: {
        'isTwoPlayerMode': true,
        'isUserFirstPlayer': true,
        'playerOneName': playerOneName,
        'playerTwoName': playerTwoName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: AppText.h3('Enter Player Names'),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text('Player one name'),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: playerOneController,
                  placeholder: 'Enter name',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.separator),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Player two name'),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: playerTwoController,
                  placeholder: 'Enter name',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.separator),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 32),
                CupertinoButton.filled(
                  onPressed: _startGame,
                  child: const Text('PLAY'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

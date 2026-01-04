import 'package:flutter/cupertino.dart';
// import '../../widgets/game_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Username'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.info),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Rules of the Games'),
                content: const Text(
                    'Here you can explain Tic-Tac-Toe and Mini Sudoku rules.'),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.settings),
          onPressed: () {
            // TODO: Navigate to settings page
          },
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select a game',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context, 
                      '/game_player_settings',
                      arguments: 'tic_tac_toe'),
                    child: Column(
                      children: [
                        Image.asset('images/tic_tac_toe.png',
                            width: 100, height: 100),
                        const SizedBox(height: 8),
                        const Text('Tic-Tac-Toe'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context, 
                      '/game_difficulty_settings',
                      arguments: 'mini_sudoku'),
                    child: Column(
                      children: [
                        Image.asset('images/mini_sudoku.png',
                            width: 100, height: 100),
                        const SizedBox(height: 8),
                        const Text('Mini Sudoku'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

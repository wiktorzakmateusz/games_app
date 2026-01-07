import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: AppMenuNavBar(
        title: 'Local Games',
        onBackPressed: () {
          Navigator.pushReplacementNamed(context, '/');
        },
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.h2('Select a game'),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 40,
                    runSpacing: 30,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context, 
                          '/game_player_settings',
                          arguments: 'tic_tac_toe'),
                        child: Column(
                          children: [
                            Image.asset('images/tic_tac_toe.png',
                                width: 150, height: 150),
                            const SizedBox(height: 8),
                            AppText.h5('Tic-Tac-Toe'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context, 
                          '/game_difficulty_settings',
                          arguments: 'mini_sudoku'),
                        child: Column(
                          children: [
                            Image.asset('images/mini_sudoku.png',
                                width: 150, height: 150),
                            const SizedBox(height: 8),
                            AppText.h5('Mini Sudoku'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context, 
                          '/game_player_settings',
                          arguments: 'connect4'),
                        child: Column(
                          children: [
                            Image.asset('images/connect_4.jpeg',
                                width: 150, height: 150),
                            const SizedBox(height: 8),
                            AppText.h5('Connect 4'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

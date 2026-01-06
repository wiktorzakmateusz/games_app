import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../widgets/game_button.dart';

class GameSettingsPage extends StatelessWidget {
  const GameSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String gameType = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'tic_tac_toe';
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: AppText.h3('Choose settings'),
        // automatically shows back button if navigated from another page
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GameButton(
                label: 'Play solo',
                onTap: () => Navigator.pushNamed(
                  context, 
                  '/game_difficulty_settings',
                  arguments: gameType,
                ),
              ),
              const SizedBox(height: 20),
              GameButton(
                label: 'Play with a friend',
                onTap: () => Navigator.pushNamed(
                  context, 
                  '/player_names',
                  arguments: gameType,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

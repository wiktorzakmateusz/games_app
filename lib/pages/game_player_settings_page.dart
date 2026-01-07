import 'package:flutter/cupertino.dart';
import '../../widgets/game_button.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';

class GameSettingsPage extends StatelessWidget {
  const GameSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String gameType = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'tic_tac_toe';
    
    return CupertinoPageScaffold(
      navigationBar: const AppMenuNavBar(title: 'Choose settings'),
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

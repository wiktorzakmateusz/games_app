import 'package:flutter/cupertino.dart';
import '../../widgets/game_button.dart';

class GameSettingsPage extends StatelessWidget {
  const GameSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Choose settings'),
        // automatically shows back button if navigated from another page
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GameButton(
                label: 'Play solo',
                onTap: () => Navigator.pushNamed(context, '/difficulty'),
              ),
              const SizedBox(height: 20),
              GameButton(
                label: 'Play with a friend',
                onTap: ()  => Navigator.pushNamed(context, '/player_names'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import '../../widgets/game_button.dart';

class DifficultyPage extends StatefulWidget {
  const DifficultyPage({super.key});

  @override
  State<DifficultyPage> createState() => _DifficultyPageState();
}

class _DifficultyPageState extends State<DifficultyPage> {
  String selectedDifficulty = 'Easy';
  bool isUserFirstPlayer = true;

  @override
  Widget build(BuildContext context) {
    final String gameType = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'tic-tac-toe';
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Choose difficulty'),
        // automatically adds a back button if navigated from another page
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var level in ['Easy', 'Medium', 'Hard'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: 200,
                    child: CupertinoButton(
                      color: selectedDifficulty == level
                          ? CupertinoTheme.of(context)
                            .primaryColor
                            .withOpacity(0.2)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: () {
                        setState(() => selectedDifficulty = level);
                      },
                      child: Text(
                        level,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              if (gameType == 'tic-tac-toe') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('You start ', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 10),
                    CupertinoSwitch(
                      value: isUserFirstPlayer,
                      activeTrackColor: CupertinoTheme.of(context).primaryColor,
                      onChanged: (bool value) {
                        setState(() => isUserFirstPlayer = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              GameButton(
                label: 'PLAY',
                onTap: () {
                  String routeName = gameType == 'tic-tac-toe' ? '/tic_tac_toe' : '/mini_sudoku';
                  Navigator.pushNamed(
                    context,
                    routeName,
                    arguments: {
                      'difficulty': selectedDifficulty,
                      'isUserFirstPlayer': isUserFirstPlayer,
                      'gameType': gameType,
                    },
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}

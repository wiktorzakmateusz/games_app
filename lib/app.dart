import 'package:flutter/cupertino.dart';
import '../pages/home_page.dart';
import 'pages/game_player_settings_page.dart';
import 'pages/game_difficulty_settings_page.dart';
import '../pages/tic_tac_toe_game_page.dart';
import '../pages/mini_sudoku_game_page.dart';
import '../pages/players_names_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Games',
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
        brightness: Brightness.light,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/game_player_settings': (context) => const GameSettingsPage(),
        '/game_difficulty_settings': (context) => const DifficultyPage(),
        '/player_names': (context) => const PlayerNamesPage(),
        '/tic_tac_toe': (context) => const TicTacToePage(),
        '/mini_sudoku': (context) => const MiniSudokuPage(),
      },
    );
  }
}

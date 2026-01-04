import 'package:flutter/cupertino.dart';
import '../pages/home_page.dart';
import 'pages/game_player_settings_page.dart';
import 'pages/game_difficulty_settings_page.dart';
import '../pages/mini_sudoku_game_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pages/welcome_page.dart';
import 'pages/tic_tac_toe_game_page.dart';
import 'pages/players_names_page.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/game/presentation/cubit/game_cubit.dart';
import 'features/game/presentation/pages/online_game_page.dart';
import 'features/lobby/presentation/cubit/lobby_list_cubit.dart';
import 'features/lobby/presentation/cubit/lobby_waiting_cubit.dart';
import 'features/lobby/presentation/pages/lobby_list_page.dart';
import 'features/lobby/presentation/pages/lobby_waiting_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthCubit>(),
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'Mini Games',
        theme: const CupertinoThemeData(
          primaryColor: CupertinoColors.systemBlue,
          scaffoldBackgroundColor: CupertinoColors.systemBackground,
          brightness: Brightness.light,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return CupertinoPageRoute(
                builder: (_) => const WelcomePage(),
                settings: settings,
              );
            case '/home':
              return CupertinoPageRoute(
                builder: (_) => const HomePage(),
                settings: settings,
              );
            case '/auth':
              return CupertinoPageRoute(
                builder: (_) => const AuthPage(),
                settings: settings,
              );
            case '/lobby_list':
              return CupertinoPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<LobbyListCubit>(),
                  child: const LobbyListPage(),
                ),
                settings: settings,
              );
            case '/lobby_waiting':
              return CupertinoPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<LobbyWaitingCubit>(),
                  child: const LobbyWaitingPage(),
                ),
                settings: settings,
              );
            case '/online_game':
              return CupertinoPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<GameCubit>(),
                  child: const OnlineGamePage(),
                ),
                settings: settings,
              );
            case '/game_player_settings':
              return CupertinoPageRoute(
                builder: (_) => const GameSettingsPage(),
                settings: settings,
              );
            case '/game_difficulty_settings':
              return CupertinoPageRoute(
                builder: (_) => const DifficultyPage(),
                settings: settings,
              );
            case '/player_names':
              return CupertinoPageRoute(
                builder: (_) => const PlayerNamesPage(),
                settings: settings,
              );
            case '/tic_tac_toe':
              return CupertinoPageRoute(
                builder: (_) => const TicTacToePage(),
                settings: settings,
              );
            case '/mini_sudoku':
              return CupertinoPageRoute(
                builder: (_) => const MiniSudokuPage(),
                settings: settings,
              );
            default:
              return CupertinoPageRoute(
                builder: (_) => const WelcomePage(),
                settings: settings,
              );
          }
        },
      ),
    );
  }
}

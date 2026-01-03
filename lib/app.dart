import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pages/welcome_page.dart';
import 'pages/home_page.dart';
import 'pages/auth_page.dart';
import 'pages/game_settings_page.dart';
import 'pages/difficulty_page.dart';
import 'pages/tic_tac_toe_game_page.dart';
import 'pages/players_names_page.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/firestore_service.dart';
import 'injection_container.dart' as di;
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
    return MultiProvider(
      providers: [
        // Keep existing Provider services for backward compatibility
        Provider<AuthService>(
          create: (_) => di.sl(),
        ),
        Provider<FirestoreService>(
          create: (_) => di.sl(),
        ),
        Provider<UserService>(
          create: (_) => di.sl(),
        ),
      ],
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
          // Use onGenerateRoute for better control over BLoC providers
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
            case '/lobby_browser':
              // New refactored lobby list page
              return CupertinoPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<LobbyListCubit>(),
                  child: const LobbyListPage(),
                ),
                settings: settings,
              );
            case '/lobby_waiting':
              // New refactored lobby waiting page
              return CupertinoPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<LobbyWaitingCubit>(),
                  child: const LobbyWaitingPage(),
                ),
                settings: settings,
              );
            case '/online_game':
              // Provide GameCubit for the new refactored page
              return CupertinoPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<GameCubit>(),
                  child: const OnlineGamePage(),
                ),
                settings: settings,
              );
            case '/settings':
              return CupertinoPageRoute(
                builder: (_) => const GameSettingsPage(),
                settings: settings,
              );
            case '/difficulty':
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

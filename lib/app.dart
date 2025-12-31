import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../pages/home_page.dart';
import '../pages/game_settings_page.dart';
import '../pages/difficulty_page.dart';
import '../pages/tic_tac_toe_game_page.dart';
import '../pages/players_names_page.dart';
import '../services/auth_service.dart';
import '../services/lobby_service.dart';
import '../services/game_service.dart';
import '../services/user_service.dart';
import '../services/firestore_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        ProxyProvider<AuthService, LobbyService>(
          update: (_, authService, __) => LobbyService(authService),
        ),
        ProxyProvider<AuthService, GameService>(
          update: (_, authService, __) => GameService(authService),
        ),
        ProxyProvider<AuthService, UserService>(
          update: (_, authService, __) => UserService(authService),
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
        routes: {
          '/': (context) => const HomePage(),
          '/settings': (context) => const GameSettingsPage(),
          '/difficulty': (context) => const DifficultyPage(),
          '/player_names': (context) => const PlayerNamesPage(),
          '/tic_tac_toe': (context) => const TicTacToePage(),
        },
      ),
    );
  }
}

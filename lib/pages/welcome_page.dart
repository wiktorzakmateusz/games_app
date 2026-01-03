import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/game_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Mini Games',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              GameButton(
                label: 'Play',
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              const SizedBox(height: 20),
              GameButton(
                label: 'Multiplayer',
                onTap: () {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  if (authService.isLoggedIn) {
                    Navigator.pushReplacementNamed(context, '/lobby_list');
                  } else {
                    Navigator.pushNamed(context, '/auth');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/app_text.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
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
              AppText.h1('Play Together'),
              const SizedBox(height: 60),
              GameButton(
                label: 'Play',
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return GameButton(
                    label: 'Multiplayer',
                    onTap: () {
                      if (state is Authenticated) {
                        Navigator.pushNamed(context, '/lobby_list');
                      } else {
                        Navigator.pushNamed(context, '/auth');
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


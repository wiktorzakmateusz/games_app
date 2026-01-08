import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/app_text.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../widgets/game_button.dart';
import '../core/utils/responsive_layout.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: ResponsiveLayout.constrainWidth(
          context,
          Padding(
            padding: ResponsiveLayout.getPadding(context),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.h1('Play Together'),
                  SizedBox(height: ResponsiveLayout.getLargeSpacing(context)),
                  GameButton(
                    label: 'Play',
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                  SizedBox(height: ResponsiveLayout.getSpacing(context)),
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
        ),
      ),
    );
  }
}


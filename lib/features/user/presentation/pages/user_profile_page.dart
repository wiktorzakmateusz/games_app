import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../widgets/user_avatar.dart';
import '../widgets/user_display_name.dart';
import '../widgets/user_username.dart';
import '../widgets/user_logout_button.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          
          return CupertinoPageScaffold(
            navigationBar: const AppNavBar(
              title: 'Profile',
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        UserAvatar(
                          imageUrl: user.photoURL,
                          size: 150,
                        ),
                        const SizedBox(height: 32),
                        UserDisplayName(displayName: user.displayName),
                        const SizedBox(height: 12),
                        UserUsername(username: user.username),
                        const SizedBox(height: 48),
                        const UserLogoutButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          // Should not happen if route is protected, but handle gracefully
          return CupertinoPageScaffold(
            navigationBar: const AppNavBar(title: 'Profile'),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.person_circle,
                      size: 64,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(height: 16),
                    const Text('Not authenticated'),
                    const SizedBox(height: 24),
                    CupertinoButton.filled(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: const Text('Go to Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}


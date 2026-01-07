import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/app_text.dart';
import 'package:games_app/widgets/game_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class UserLogoutButton extends StatelessWidget {
  const UserLogoutButton({super.key});

  void _handleLogout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: AppText.h3('Logout'),
        content: AppText.bodyLarge('Are you sure you want to logout?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText.button('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
            child: AppText.button('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameButton(
      label: 'Logout',
      onTap: () => _handleLogout(context),
    );
  }
}


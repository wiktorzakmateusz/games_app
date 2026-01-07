import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';

class UserUsername extends StatelessWidget {
  final String username;

  const UserUsername({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return AppText.bodyLarge('@$username');
  }
}


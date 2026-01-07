import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';

class UserDisplayName extends StatelessWidget {
  final String displayName;

  const UserDisplayName({
    super.key,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return AppText.h2(displayName);
  }
}


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:games_app/widgets/app_text.dart';

class AppMenuNavBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const AppMenuNavBar({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: AppText.h3(title),
      leading: onBackPressed != null
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.back),
              onPressed: onBackPressed,
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;
}


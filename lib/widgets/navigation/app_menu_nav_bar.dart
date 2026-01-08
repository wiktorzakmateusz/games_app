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
    final bool shouldShowBackButton = onBackPressed != null || Navigator.canPop(context);
    
    return CupertinoNavigationBar(
      middle: AppText.h3(title),
      leading: shouldShowBackButton
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              child: const Icon(
                CupertinoIcons.back,
                color: CupertinoColors.activeBlue,
                size: 26.0,
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;
}


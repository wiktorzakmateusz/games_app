import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:games_app/widgets/app_text.dart';

class AppNavBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final Widget? leading;
  final Widget? middle;
  final Widget? trailing;
  final String? title;

  const AppNavBar({
    super.key,
    this.leading,
    this.middle,
    this.trailing,
    this.title,
  }) : assert(middle != null || title != null, 'Either middle or title must be provided');

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      leading: leading,
      middle: middle ?? (title != null ? AppText.h3(title!) : null),
      trailing: trailing,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;
}


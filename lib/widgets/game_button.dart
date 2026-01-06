import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';

class GameButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const GameButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(vertical: 14),
        borderRadius: BorderRadius.circular(12),
        onPressed: onTap,
        child: AppText.button(label),
      ),
    );
  }
}

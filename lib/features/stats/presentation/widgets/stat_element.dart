import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../../../core/theme/app_typography.dart';

class StatElement extends StatelessWidget {
  final String category;
  final String amount;
  final Color? color;

  const StatElement({
    super.key,
    required this.category,
    required this.amount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          AppText.bodyMedium(category),
          const SizedBox(height: 4),
          AppText(
            amount,
            style: TextStyles.bodyLargeBold.copyWith(
              color: color ?? CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }
}


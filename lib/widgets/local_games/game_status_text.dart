import 'package:flutter/cupertino.dart';

class GameStatusText extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;

  const GameStatusText({
    super.key,
    required this.text,
    this.color,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: color ?? CupertinoColors.black,
      ),
      textAlign: TextAlign.center,
    );
  }
}


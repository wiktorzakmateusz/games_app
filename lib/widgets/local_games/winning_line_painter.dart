import 'package:flutter/cupertino.dart';

class WinningLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;

  WinningLinePainter({
    required this.start,
    required this.end,
    this.color = CupertinoColors.black,
    this.strokeWidth = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant WinningLinePainter oldDelegate) =>
      oldDelegate.start != start || oldDelegate.end != end;
}

/// Widget that animates a winning line over a game board
class AnimatedWinningLine extends StatelessWidget {
  final List<int>? winningPattern;
  final Animation<double> animation;
  final Offset Function(int index) getCellCenter;
  final Color lineColor;
  final double strokeWidth;

  const AnimatedWinningLine({
    super.key,
    required this.winningPattern,
    required this.animation,
    required this.getCellCenter,
    this.lineColor = CupertinoColors.black,
    this.strokeWidth = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (winningPattern == null || winningPattern!.length < 2) {
      return const SizedBox.shrink();
    }

    final start = getCellCenter(winningPattern!.first);
    final end = getCellCenter(winningPattern!.last);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final currentEnd = Offset(
          start.dx + (end.dx - start.dx) * animation.value,
          start.dy + (end.dy - start.dy) * animation.value,
        );
        return CustomPaint(
          painter: WinningLinePainter(
            start: start,
            end: currentEnd,
            color: lineColor,
            strokeWidth: strokeWidth,
          ),
        );
      },
    );
  }
}


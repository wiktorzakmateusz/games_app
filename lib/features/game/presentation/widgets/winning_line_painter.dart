import 'package:flutter/cupertino.dart';

class WinningLinePainter extends StatefulWidget {
  final List<int> winningPattern;
  final double boardSize;

  const WinningLinePainter({
    super.key,
    required this.winningPattern,
    required this.boardSize,
  });

  @override
  State<WinningLinePainter> createState() => _WinningLinePainterState();
}

class _WinningLinePainterState extends State<WinningLinePainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _cellCenter(int index, double cellSize) {
    final row = index ~/ 3;
    final col = index % 3;
    return Offset(
      (col + 0.5) * cellSize,
      (row + 0.5) * cellSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = widget.boardSize / 3;
    final start = _cellCenter(widget.winningPattern.first, cellSize);
    final end = _cellCenter(widget.winningPattern.last, cellSize);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentEnd = Offset(
          start.dx + (end.dx - start.dx) * _animation.value,
          start.dy + (end.dy - start.dy) * _animation.value,
        );
        return CustomPaint(
          painter: _LinePainter(start, currentEnd),
          size: Size(widget.boardSize, widget.boardSize),
        );
      },
    );
  }
}

class _LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  _LinePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CupertinoColors.black
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.start != start || oldDelegate.end != end;
}


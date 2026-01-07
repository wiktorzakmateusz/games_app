import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';
import 'package:games_app/core/theme/app_typography.dart';

class GameTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onTimeout;
  final bool isActive;
  final bool autoStart;

  const GameTimer({
    super.key,
    required this.duration,
    this.onTimeout,
    this.isActive = true,
    this.autoStart = true,
  });

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    if (widget.autoStart && widget.isActive) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(GameTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset timer if duration changed
    if (oldWidget.duration != widget.duration) {
      _resetTimer();
    }
    
    // Handle active state changes
    if (!oldWidget.isActive && widget.isActive && widget.autoStart) {
      // Reset and start when becoming active
      _resetTimer();
      _startTimer();
    } else if (oldWidget.isActive && !widget.isActive) {
      // Stop and reset when becoming inactive
      _stopTimer();
      _resetTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning || !widget.isActive) return;
    
    _isRunning = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_remainingTime.inMilliseconds > 100) {
          _remainingTime = Duration(milliseconds: _remainingTime.inMilliseconds - 100);
        } else {
          _remainingTime = Duration.zero;
          _handleTimeout();
        }
      });
    });
  }

  void _stopTimer() {
    _isRunning = false;
    _timer?.cancel();
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remainingTime = widget.duration;
    });
    if (widget.autoStart && widget.isActive) {
      _startTimer();
    }
  }

  void _handleTimeout() {
    _stopTimer();
    widget.onTimeout?.call();
  }

  // Public methods that can be called from parent
  void start() {
    if (!_isRunning) {
      _startTimer();
    }
  }

  void stop() {
    _stopTimer();
  }

  void reset() {
    _resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _remainingTime.inSeconds;
    final milliseconds = (_remainingTime.inMilliseconds % 1000) ~/ 100;
    final timeString = '${totalSeconds.toString().padLeft(2, '0')}.${milliseconds.toString()}';
    
    // Change color when time is low (less than 10 seconds, but not expired)
    final isExpired = _remainingTime.isNegative || _remainingTime.inMilliseconds == 0;
    final isLowTime = !isExpired && (_remainingTime.inMilliseconds < 10000);
    
    final textColor = isExpired
        ? CupertinoColors.destructiveRed
        : isLowTime
            ? CupertinoColors.systemOrange
            : CupertinoColors.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowTime || isExpired
              ? textColor
              : CupertinoColors.separator,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: 60,
        child: AppText(
          timeString,
          textAlign: TextAlign.center,
          style: TextStyles.h4.copyWith(
            color: textColor,
            fontFeatures: [
              const FontFeature.tabularFigures(),
            ],
          ),
        ),
      ),
    );
  }
}


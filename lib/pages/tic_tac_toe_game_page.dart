import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class TicTacToePage extends StatefulWidget {

  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> with SingleTickerProviderStateMixin {

  late bool isUserFirstPlayer;
  late bool isTwoPlayerMode;
  late String? playerOneName;
  late String? playerTwoName;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    isUserFirstPlayer = args?['isUserFirstPlayer'] ?? true;
    isTwoPlayerMode = args?['isTwoPlayerMode'] ?? false;
    playerOneName = args?['playerOneName'] ?? 'Player 1';
    playerTwoName = args?['playerTwoName'] ?? 'Player 2';

    currentPlayer = 'X';

    if (!isTwoPlayerMode && !isUserFirstPlayer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _makeComputerMove();
      });
    }
  }


  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );


  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  List<String> board = List.filled(9, '');
  String? winner;
  List<int>? winningPattern;
  late String currentPlayer;

  void _handleTap(int index) {
    if (board[index] != '' || winner != null) return;

    setState(() {
      board[index] = currentPlayer;
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    });

    _checkGameOver();

    if (!isTwoPlayerMode) {
      final isComputerTurn = (currentPlayer == 'X' && !isUserFirstPlayer) ||
          (currentPlayer == 'O' && isUserFirstPlayer);
      if (isComputerTurn && winner == null) {
        Future.delayed(const Duration(milliseconds: 1000), _makeComputerMove);
      }
    }

  }

  void _makeComputerMove() {
    if (winner != null) return;

    final emptyIndices = [
      for (int i = 0; i < board.length; i++)
        if (board[i] == '') i
    ];
    if (emptyIndices.isEmpty) return;

    final randomIndex = (emptyIndices..shuffle()).first;
    setState(() {
      board[randomIndex] = currentPlayer;
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    });

    _checkGameOver();
  }

  void _checkGameOver() {
    final result = _checkWinner();
    if (result != null) {
      setState(() {
        winner = result['winner'];
        winningPattern = result['pattern'];
      });
      if (winningPattern != null) {
        _lineController.forward(from: 0); // animate the line
      }
    }
  }

  Map<String, dynamic>? _checkWinner() {
    const List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      final a = pattern[0], b = pattern[1], c = pattern[2];
      if (board[a] != '' && board[a] == board[b] && board[a] == board[c]) {
        return {'winner': board[a], 'pattern': pattern};
      }
    }

    if (!board.contains('')) return {'winner': 'draw', 'pattern': null};
    return null;
  }

  Widget _buildCell(int index) {
    final isWinningCell = winningPattern?.contains(index) ?? false;
    final value = board[index];
    final textColor = switch (value) {
      'X' => CupertinoColors.systemRed,
      'O' => CupertinoColors.systemBlue,
      _ => CupertinoColors.black,
    };

    return GestureDetector(
      onTap: () => _handleTap(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.separator, width: 0.8),
          color: isWinningCell
              ? CupertinoColors.activeGreen.withOpacity(0.25)
              : CupertinoColors.white,
        ),
        child: Center(
          child: Text(
            board[index],
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWinningLine(BoxConstraints constraints) {
    if (winningPattern == null) return const SizedBox.shrink();

    final width = constraints.maxWidth;
    final cellSize = width / 3;

    final p = winningPattern!;
    final start = _cellCenter(p.first, cellSize);
    final end = _cellCenter(p.last, cellSize);

    return AnimatedBuilder(
      animation: _lineAnimation,
      builder: (context, child) {
        final currentEnd = Offset(
          start.dx + (end.dx - start.dx) * _lineAnimation.value,
          start.dy + (end.dy - start.dy) * _lineAnimation.value,
        );
        return CustomPaint(
          painter: _LinePainter(start, currentEnd),
          size: Size(width, width),
        );
      },
    );
  }

  Offset _cellCenter(int index, double cellSize) {
    final row = index ~/ 3;
    final col = index % 3;
    return Offset(
      (col + 0.5) * cellSize,
      (row + 0.5) * cellSize,
    );
  }

  void _resetBoard({bool? startAsUser}) {
    setState(() {
      board = List.filled(9, '');
      winner = null;
      winningPattern = null;
      currentPlayer = 'X';
      if (!isTwoPlayerMode &&
        ((currentPlayer == 'X' && !isUserFirstPlayer) ||
        (currentPlayer == 'O' && isUserFirstPlayer))) {
        Future.delayed(const Duration(milliseconds: 1000), _makeComputerMove);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    String statusText;
    if (winner == null) {
      if (isTwoPlayerMode) {
        statusText = '${currentPlayer == 'X' ? playerOneName : playerTwoName}\'s turn ($currentPlayer)';
      } else {
        final isUserTurn = (currentPlayer == 'X' && isUserFirstPlayer) ||
                          (currentPlayer == 'O' && !isUserFirstPlayer);
        statusText = isUserTurn
            ? 'Your turn ($currentPlayer)'
            : 'Computer\'s turn ($currentPlayer)';
        // statusText = '${(currentPlayer == 'X' && isUserFirstPlayer == true) ||
        //               (currentPlayer == 'O' && isUserFirstPlayer == false)
        //               ? 'Your' : "Computer's"} turn ($currentPlayer)';
      }
    } else if (winner == 'draw') {
      statusText = 'It\'s a draw!';
    } else {
      if (isTwoPlayerMode) {
        statusText = '${winner == 'X' ? playerOneName : playerTwoName} wins!';
      } else {
        statusText = ((winner == 'X' && isUserFirstPlayer) ||
                      (winner == 'O' && !isUserFirstPlayer))
            ? 'You won!'
            : 'Computer won!';
      }
    }

    const double boardSize = 320;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Tic-Tac-Toe'),
        leading: GestureDetector(
          child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.activeBlue),
          onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(statusText,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              Container(
                width: boardSize,
                height: boardSize,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: CupertinoColors.systemGrey4,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        GridView.builder(
                          itemCount: 9,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          itemBuilder: (context, index) => _buildCell(index),
                        ),
                        _buildWinningLine(constraints),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50, // reserve space for the button
                child: winner != null
                    ? CupertinoButton.filled(
                        onPressed: () => _resetBoard(startAsUser: isUserFirstPlayer),
                        child: const Text('Play Again'),
                      )
                    : const SizedBox.shrink(), // empty when no winner
              ),
                          ],
                        ),
                      ),
                    ),
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
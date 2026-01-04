import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Needed for Colors and CustomPainter
import '../logic/tic_tac_toe_logic.dart'; // Import the extracted logic

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> with SingleTickerProviderStateMixin {
  
  // 1. Instantiate the Logic Class
  final TicTacToeLogic _gameLogic = TicTacToeLogic();

  // Settings & State Variables
  late bool isUserFirstPlayer;
  late bool isTwoPlayerMode;
  late String difficulty;
  late String? playerOneName;
  late String? playerTwoName;

  List<String> board = List.filled(9, '');
  String? winner;
  List<int>? winningPattern;
  late String currentPlayer;

  // Animation Variables
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    isUserFirstPlayer = args?['isUserFirstPlayer'] ?? true;
    isTwoPlayerMode = args?['isTwoPlayerMode'] ?? false;
    difficulty = args?['difficulty'] ?? 'Easy';
    playerOneName = args?['playerOneName'] ?? 'Player 1';
    playerTwoName = args?['playerTwoName'] ?? 'Player 2';

    // Initialize turn
    currentPlayer = 'X';

    // If Computer starts (and it's not 2-player mode), trigger the first move
    if (!isTwoPlayerMode && !isUserFirstPlayer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _makeComputerMove();
      });
    }
  }

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

  // --- INTERACTION HANDLERS ---

  void _handleTap(int index) {
    if (board[index] != '' || winner != null) return;

    // 1. Human Move
    setState(() {
      board[index] = currentPlayer;
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    });

    _checkGameOver();

    // 2. Trigger Computer Move (if applicable)
    if (!isTwoPlayerMode && winner == null) {
      final isComputerTurn = (currentPlayer == 'X' && !isUserFirstPlayer) ||
                             (currentPlayer == 'O' && isUserFirstPlayer);
      
      if (isComputerTurn) {
        // Small delay for realism so the AI doesn't move instantly
        Future.delayed(const Duration(milliseconds: 600), _makeComputerMove);
      }
    }
  }

  void _makeComputerMove() {
    if (winner != null) return;

    // 3. Use the Logic Class to get the best move
    int bestMoveIndex = _gameLogic.getComputerMove(
      board: board, 
      difficulty: difficulty, 
      currentPlayer: currentPlayer
    );

    if (bestMoveIndex != -1) {
      setState(() {
        board[bestMoveIndex] = currentPlayer;
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      });
      _checkGameOver();
    }
  }

  void _checkGameOver() {
    // 4. Use the Logic Class to check for a winner
    final result = _gameLogic.checkWinner(board);
    
    if (result != null) {
      setState(() {
        winner = result['winner'];
        winningPattern = result['pattern'];
      });
      // Start the line animation if someone won
      if (winningPattern != null) {
        _lineController.forward(from: 0);
      }
    }
  }

  void _resetBoard({bool? startAsUser}) {
    setState(() {
      board = List.filled(9, '');
      winner = null;
      winningPattern = null;
      currentPlayer = 'X';
      
      // If computer starts, make the first move
      if (!isTwoPlayerMode &&
        ((currentPlayer == 'X' && !isUserFirstPlayer) ||
        (currentPlayer == 'O' && isUserFirstPlayer))) {
        Future.delayed(const Duration(milliseconds: 600), _makeComputerMove);
      }
    });
  }

  // --- UI BUILDERS ---

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
        middle: Text('Tic-Tac-Toe ($difficulty)'),
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
                height: 50,
                child: winner != null
                    ? CupertinoButton.filled(
                        onPressed: () => _resetBoard(startAsUser: isUserFirstPlayer),
                        child: const Text('Play Again'),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for the winning line
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
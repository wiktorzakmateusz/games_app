import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../logic/connect4_logic.dart';

class Connect4Page extends StatefulWidget {
  const Connect4Page({super.key});

  @override
  State<Connect4Page> createState() => _Connect4PageState();
}

class _Connect4PageState extends State<Connect4Page>
    with SingleTickerProviderStateMixin {
  final Connect4Logic _gameLogic = Connect4Logic();

  late bool isUserFirstPlayer;
  late bool isTwoPlayerMode;
  late String difficulty;
  late String? playerOneName;
  late String? playerTwoName;

  List<String> board = List.filled(42, '');
  String? winner;
  List<int>? winningPattern;
  late String currentPlayer;
  int? hoverColumn;

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

  void _handleColumnTap(int column) {
    if (winner != null) return;

    final row = _gameLogic.getDropRow(board, column);
    if (row == -1) return; // Column is full

    final index = row * Connect4Logic.columns + column;

    // Human Move
    setState(() {
      board[index] = currentPlayer;
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    });

    _checkGameOver();

    // Trigger Computer Move (if applicable)
    if (!isTwoPlayerMode && winner == null) {
      final isComputerTurn = (currentPlayer == 'X' && !isUserFirstPlayer) ||
          (currentPlayer == 'O' && isUserFirstPlayer);

      if (isComputerTurn) {
        Future.delayed(const Duration(milliseconds: 600), _makeComputerMove);
      }
    }
  }

  void _makeComputerMove() {
    if (winner != null) return;

    final column = _gameLogic.getComputerMove(
      board: board,
      difficulty: difficulty,
      currentPlayer: currentPlayer,
    );

    if (column != -1) {
      final row = _gameLogic.getDropRow(board, column);
      if (row != -1) {
        final index = row * Connect4Logic.columns + column;
        setState(() {
          board[index] = currentPlayer;
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        });
        _checkGameOver();
      }
    }
  }

  void _checkGameOver() {
    final result = _gameLogic.checkWinner(board);

    if (result != null) {
      setState(() {
        winner = result['winner'];
        winningPattern = result['pattern'] as List<int>?;
      });
      // Start the line animation if someone won
      if (winningPattern != null) {
        _lineController.forward(from: 0);
      }
    }
  }

  void _resetBoard({bool? startAsUser}) {
    setState(() {
      board = List.filled(42, '');
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

  Widget _buildCell(int row, int col) {
    final index = row * Connect4Logic.columns + col;
    final value = board[index];
    final isWinningCell = winningPattern?.contains(index) ?? false;
    
    // Show ghost piece in the top row of hovered column
    final showGhostPiece = hoverColumn == col && 
                          row == 0 && 
                          winner == null && 
                          value == '' &&
                          _gameLogic.getDropRow(board, col) != -1;

    Color cellColor;
    if (value == 'X') {
      cellColor = CupertinoColors.systemRed;
    } else if (value == 'O') {
      cellColor = CupertinoColors.systemBlue;
    } else {
      cellColor = CupertinoColors.white;
    }

    // Ghost piece color (current player's color, faded)
    Color ghostColor;
    if (currentPlayer == 'X') {
      ghostColor = CupertinoColors.systemRed.withOpacity(0.3);
    } else {
      ghostColor = CupertinoColors.systemBlue.withOpacity(0.3);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => hoverColumn = col),
      onExit: (_) => setState(() => hoverColumn = null),
      child: GestureDetector(
        onTap: winner == null ? () => _handleColumnTap(col) : null,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.separator, width: 0.8),
            color: isWinningCell
                ? CupertinoColors.activeGreen.withOpacity(0.25)
                : CupertinoColors.white,
            shape: BoxShape.circle,
          ),
          margin: const EdgeInsets.all(2),
          child: value != ''
              ? Container(
                  decoration: BoxDecoration(
                    color: cellColor,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.all(4),
                )
              : showGhostPiece
                  ? Container(
                      decoration: BoxDecoration(
                        color: ghostColor,
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.all(4),
                    )
                  : null,
        ),
      ),
    );
  }

  Widget _buildWinningLine(BoxConstraints constraints) {
    if (winningPattern == null || winningPattern!.length < 2) {
      return const SizedBox.shrink();
    }

    final cellSize = constraints.maxWidth / Connect4Logic.columns;
    final rowHeight = constraints.maxHeight / Connect4Logic.rows;

    final startIdx = winningPattern!.first;
    final endIdx = winningPattern!.last;

    final startRow = startIdx ~/ Connect4Logic.columns;
    final startCol = startIdx % Connect4Logic.columns;
    final endRow = endIdx ~/ Connect4Logic.columns;
    final endCol = endIdx % Connect4Logic.columns;

    final start = Offset(
      (startCol + 0.5) * cellSize,
      (startRow + 0.5) * rowHeight,
    );
    final end = Offset(
      (endCol + 0.5) * cellSize,
      (endRow + 0.5) * rowHeight,
    );

    return AnimatedBuilder(
      animation: _lineAnimation,
      builder: (context, child) {
        final currentEnd = Offset(
          start.dx + (end.dx - start.dx) * _lineAnimation.value,
          start.dy + (end.dy - start.dy) * _lineAnimation.value,
        );
        return CustomPaint(
          painter: _LinePainter(start, currentEnd),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String statusText;
    if (winner == null) {
      if (isTwoPlayerMode) {
        statusText =
            '${currentPlayer == 'X' ? playerOneName : playerTwoName}\'s turn ($currentPlayer)';
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
        statusText =
            '${winner == 'X' ? playerOneName : playerTwoName} wins!';
      } else {
        statusText = ((winner == 'X' && isUserFirstPlayer) ||
                (winner == 'O' && !isUserFirstPlayer))
            ? 'You won!'
            : 'Computer won!';
      }
    }

    const double boardWidth = 350;
    const double boardHeight = 300;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Connect 4 ($difficulty)'),
        leading: GestureDetector(
          child: const Icon(
            CupertinoIcons.xmark,
            color: CupertinoColors.activeBlue,
          ),
          onTap: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                // Game board
                Container(
                  width: boardWidth,
                  height: boardHeight,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5,
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
                            itemCount: Connect4Logic.totalCells,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: Connect4Logic.columns,
                            ),
                            itemBuilder: (context, index) {
                              final row = index ~/ Connect4Logic.columns;
                              final col = index % Connect4Logic.columns;
                              return _buildCell(row, col);
                            },
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
                          onPressed: () =>
                              _resetBoard(startAsUser: isUserFirstPlayer),
                          child: const Text('Play Again'),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),
              ],
            ),
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


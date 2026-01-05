import 'package:flutter/cupertino.dart';
import '../logic/connect4_logic.dart';
import '../widgets/local_games/game_status_text.dart';
import '../widgets/local_games/game_controls.dart';
import '../widgets/local_games/connect4/connect4_board.dart';

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

  String _getStatusText() {
    if (winner == null) {
      if (isTwoPlayerMode) {
        return '${currentPlayer == 'X' ? playerOneName : playerTwoName}\'s turn ($currentPlayer)';
      } else {
        final isUserTurn = (currentPlayer == 'X' && isUserFirstPlayer) ||
            (currentPlayer == 'O' && !isUserFirstPlayer);
        return isUserTurn
            ? 'Your turn ($currentPlayer)'
            : 'Computer\'s turn ($currentPlayer)';
      }
    } else if (winner == 'draw') {
      return 'It\'s a draw!';
    } else {
      if (isTwoPlayerMode) {
        return '${winner == 'X' ? playerOneName : playerTwoName} wins!';
      } else {
        return ((winner == 'X' && isUserFirstPlayer) ||
                (winner == 'O' && !isUserFirstPlayer))
            ? 'You won!'
            : 'Computer won!';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                GameStatusText(text: _getStatusText()),
                const SizedBox(height: 20),
                Connect4Board(
                  board: board,
                  winningPattern: winningPattern,
                  lineAnimation: _lineAnimation,
                  currentPlayer: currentPlayer,
                  hoverColumn: hoverColumn,
                  onColumnTap: _handleColumnTap,
                  onColumnHover: (col) => setState(() => hoverColumn = col),
                  onColumnHoverExit: () => setState(() => hoverColumn = null),
                  canDropInColumn: (col) => _gameLogic.getDropRow(board, col) != -1,
                  isGameOver: winner != null,
                  rows: Connect4Logic.rows,
                  columns: Connect4Logic.columns,
                ),
                const SizedBox(height: 20),
                GameControls(
                  isGameOver: winner != null,
                  onReset: () => _resetBoard(startAsUser: isUserFirstPlayer),
                  newGameLabel: 'Play Again',
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
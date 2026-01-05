import 'package:flutter/cupertino.dart';
import '../logic/tic_tac_toe_logic.dart';
import '../widgets/local_games/game_status_text.dart';
import '../widgets/local_games/game_controls.dart';
import '../widgets/local_games/tic_tac_toe/tic_tac_toe_board.dart';

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
              GameStatusText(text: _getStatusText()),
              const SizedBox(height: 20),
              TicTacToeBoard(
                board: board,
                winningPattern: winningPattern,
                lineAnimation: _lineAnimation,
                onCellTap: _handleTap,
              ),
              const SizedBox(height: 20),
              GameControls(
                isGameOver: winner != null,
                onReset: () => _resetBoard(startAsUser: isUserFirstPlayer),
                newGameLabel: 'Play Again',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
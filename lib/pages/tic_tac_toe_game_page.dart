import 'package:flutter/cupertino.dart';
import '../core/game_logic/game_logic.dart';
import '../widgets/local_games/game_status_text.dart';
import '../widgets/local_games/game_controls.dart';
import '../widgets/local_games/tic_tac_toe/tic_tac_toe_board.dart';

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage>
    with SingleTickerProviderStateMixin {
  final TicTacToeLogic _gameLogic = TicTacToeLogic();

  late TicTacToeState _gameState;

  //just added 07/01/2026
  bool _isInitialized = false;
  // i also modified didChangeDependencies below

  late bool isUserFirstPlayer;
  late bool isTwoPlayerMode;
  late GameDifficulty difficulty;
  late String? playerOneName;
  late String? playerTwoName;

  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

@override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //i added this check 07/01/2026. its to avoid re-initializing when the popup is shown
    if (!_isInitialized) {
      
      final args = ModalRoute.of(context)!.settings.arguments as Map?;
      isUserFirstPlayer = args?['isUserFirstPlayer'] ?? true;
      isTwoPlayerMode = args?['isTwoPlayerMode'] ?? false;
      final difficultyStr = args?['difficulty'] ?? 'Easy';
      difficulty = GameDifficultyExtension.fromString(difficultyStr);
      playerOneName = args?['playerOneName'] ?? 'Player 1';
      playerTwoName = args?['playerTwoName'] ?? 'Player 2';

      _gameState = _gameLogic.createInitialState(
        startingPlayer: PlayerSymbol.x,
      );

      if (!isTwoPlayerMode && !isUserFirstPlayer) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _makeComputerMove();
        });
      }

      _isInitialized = true;
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
    if (_gameState.isGameOver) return;

    final move = TicTacToeMove(index);
    if (!_gameLogic.isValidMove(_gameState, move)) return;

    setState(() {
      _gameState = _gameLogic.applyMove(_gameState, move);
    });

    if (_gameState.isGameOver && _gameState.winningPattern != null) {
      _lineController.forward(from: 0);
    }

    if (!isTwoPlayerMode && !_gameState.isGameOver) {
      final currentSymbol = _gameState.currentPlayerSymbol;
      if (currentSymbol != null) {
        final isComputerTurn = (currentSymbol == PlayerSymbol.x && !isUserFirstPlayer) ||
            (currentSymbol == PlayerSymbol.o && isUserFirstPlayer);

        if (isComputerTurn) {
          Future.delayed(const Duration(milliseconds: 600), _makeComputerMove);
        }
      }
    }
  }

  void _makeComputerMove() {
    if (_gameState.isGameOver) return;

    final currentSymbol = _gameState.currentPlayerSymbol;
    if (currentSymbol == null) return;

    final aiSymbol = isUserFirstPlayer ? PlayerSymbol.o : PlayerSymbol.x;

    final move = _gameLogic.getAIMove(
      state: _gameState,
      difficulty: difficulty,
      aiPlayer: aiSymbol,
    );

    setState(() {
      _gameState = _gameLogic.applyMove(_gameState, move);
    });

    if (_gameState.isGameOver && _gameState.winningPattern != null) {
      _lineController.forward(from: 0);
    }
  }

  void _resetBoard({bool? startAsUser}) {
    setState(() {
      _gameState = _gameLogic.createInitialState(
        startingPlayer: PlayerSymbol.x,
      );

      if (!isTwoPlayerMode && !isUserFirstPlayer) {
        Future.delayed(const Duration(milliseconds: 600), _makeComputerMove);
      }
    });
  }

  String _getStatusText() {
    if (!_gameState.isGameOver) {
      final currentSymbol = _gameState.currentPlayerSymbol;
      if (currentSymbol == null) return '';

      if (isTwoPlayerMode) {
        final playerName = currentSymbol == PlayerSymbol.x
            ? playerOneName
            : playerTwoName;
        return '$playerName\'s turn (${currentSymbol.symbol})';
      } else {
        final isUserTurn =
            (currentSymbol == PlayerSymbol.x && isUserFirstPlayer) ||
                (currentSymbol == PlayerSymbol.o && !isUserFirstPlayer);
        return isUserTurn
            ? 'Your turn (${currentSymbol.symbol})'
            : 'Computer\'s turn (${currentSymbol.symbol})';
      }
    } else if (_gameState.isDraw) {
      return 'It\'s a draw!';
    } else {
      final winnerSymbol = _gameState.winnerSymbol;
      if (winnerSymbol == null) return '';

      if (isTwoPlayerMode) {
        final winnerName =
            winnerSymbol == PlayerSymbol.x ? playerOneName : playerTwoName;
        return '$winnerName wins!';
      } else {
        final userWon = (winnerSymbol == PlayerSymbol.x && isUserFirstPlayer) ||
            (winnerSymbol == PlayerSymbol.o && !isUserFirstPlayer);
        return userWon ? 'You won!' : 'Computer won!';
      }
    }
  }

  List<String> _getBoardAsStrings() {
    return _gameState.board.map((symbol) {
      if (symbol == null) return '';
      return symbol.symbol;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Tic-Tac-Toe (${difficulty.displayName})'),
        leading: GestureDetector(
          child: const Icon(CupertinoIcons.xmark,
              color: CupertinoColors.activeBlue),
          onTap: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        ),

        //JUST ADDED THIS PART 07/01/2026
trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.info),
          onPressed: () {
            // Shows the pupup with the game rules
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Tic-Tac-Toe Rules'),
                content: const Text('\nFirst player to align 3 symbols wins.\n\nYou can win by:\n• Horizontal alignment\n• Vertical alignment\n• Diagonal alignment\n\nIf all cells are filled without a winner, the game ends in a draw.'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Got it!'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
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
                board: _getBoardAsStrings(),
                winningPattern: _gameState.winningPattern,
                lineAnimation: _lineAnimation,
                onCellTap: _handleTap,
              ),
              const SizedBox(height: 20),
              GameControls(
                isGameOver: _gameState.isGameOver,
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

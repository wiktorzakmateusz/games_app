import 'package:flutter/cupertino.dart';
import '../core/game_logic/game_logic.dart';
import '../widgets/local_games/game_controls.dart';
import '../widgets/local_games/tic_tac_toe/tic_tac_toe_board.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';
import 'package:games_app/widgets/game_header.dart';

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage>
    with SingleTickerProviderStateMixin {
  final TicTacToeLogic _gameLogic = TicTacToeLogic();

  late TicTacToeState _gameState;

  late bool isUserFirstPlayer;
  late bool isTwoPlayerMode;
  late GameDifficulty? difficulty;
  late String? playerOneName;
  late String? playerTwoName;

  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  bool _isProcessingMove = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    isUserFirstPlayer = args?['isUserFirstPlayer'] ?? true;
    isTwoPlayerMode = args?['isTwoPlayerMode'] ?? false;
    if (isTwoPlayerMode) {
      difficulty = null;
    } else {
      final difficultyStr = args?['difficulty'] ?? 'Easy';
      difficulty = GameDifficultyExtension.fromString(difficultyStr);
    }
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
    if (_isProcessingMove) return;

    // Check if it's the user's turn (only in single-player mode)
    if (!isTwoPlayerMode) {
      final currentSymbol = _gameState.currentPlayerSymbol;
      if (currentSymbol == null) return;
      
      final isUserTurn = (currentSymbol == PlayerSymbol.x && isUserFirstPlayer) ||
          (currentSymbol == PlayerSymbol.o && !isUserFirstPlayer);
      
      if (!isUserTurn) return; // It's computer's turn, ignore user input
    }

    final move = TicTacToeMove(index);
    if (!_gameLogic.isValidMove(_gameState, move)) return;

    _isProcessingMove = true;

    setState(() {
      _gameState = _gameLogic.applyMove(_gameState, move);
    });

    if (_gameState.isGameOver && _gameState.winningPattern != null) {
      _lineController.forward(from: 0);
      _isProcessingMove = false;
      return;
    }

    if (!isTwoPlayerMode && !_gameState.isGameOver) {
      final currentSymbol = _gameState.currentPlayerSymbol;
      if (currentSymbol != null) {
        final isComputerTurn = (currentSymbol == PlayerSymbol.x && !isUserFirstPlayer) ||
            (currentSymbol == PlayerSymbol.o && isUserFirstPlayer);

        if (isComputerTurn) {
          Future.delayed(const Duration(milliseconds: 600), _makeComputerMove);
        } else {
          _isProcessingMove = false;
        }
      } else {
        _isProcessingMove = false;
      }
    } else {
      _isProcessingMove = false;
    }
  }

  void _makeComputerMove() {
    if (_gameState.isGameOver) {
      _isProcessingMove = false;
      return;
    }

    final currentSymbol = _gameState.currentPlayerSymbol;
    if (currentSymbol == null) {
      _isProcessingMove = false;
      return;
    }

    final aiSymbol = isUserFirstPlayer ? PlayerSymbol.o : PlayerSymbol.x;

    final move = _gameLogic.getAIMove(
      state: _gameState,
      difficulty: difficulty!,
      aiPlayer: aiSymbol,
    );

    setState(() {
      _gameState = _gameLogic.applyMove(_gameState, move);
    });

    if (_gameState.isGameOver && _gameState.winningPattern != null) {
      _lineController.forward(from: 0);
    }
    
    _isProcessingMove = false;
  }

  void _resetBoard({bool? startAsUser}) {
    _isProcessingMove = false;
    setState(() {
      _gameState = _gameLogic.createInitialState(
        startingPlayer: PlayerSymbol.x,
      );

      if (!isTwoPlayerMode && !isUserFirstPlayer) {
        Future.delayed(const Duration(milliseconds: 600), _makeComputerMove);
      }
    });
  }

  bool _isPlayer1Turn() {
    final currentSymbol = _gameState.currentPlayerSymbol;
    if (currentSymbol == null) return false;
    return currentSymbol == PlayerSymbol.x;
  }

  bool _shouldRunTimer() {
    if (isTwoPlayerMode) return true; // Always run timer in two-player mode
    
    // In single-player mode, only run timer when it's the human player's turn
    final currentSymbol = _gameState.currentPlayerSymbol;
    if (currentSymbol == null) return false;
    
    final isUserTurn = (currentSymbol == PlayerSymbol.x && isUserFirstPlayer) ||
        (currentSymbol == PlayerSymbol.o && !isUserFirstPlayer);
    return isUserTurn;
  }

  void _handleTimeout() {
    if (_gameState.isGameOver || _isProcessingMove) return;

    // Make a random valid move
    final validMoves = <int>[];
    for (int i = 0; i < 9; i++) {
      if (_gameLogic.isValidMove(_gameState, TicTacToeMove(i))) {
        validMoves.add(i);
      }
    }

    if (validMoves.isNotEmpty) {
      final randomMove = validMoves[validMoves.length ~/ 2]; // Simple middle move
      _handleTap(randomMove);
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
      navigationBar: AppGameNavBar(
        gameName: 'Tic-Tac-Toe',
        difficulty: difficulty,
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              GameHeader(
                player1Name: isTwoPlayerMode ? playerOneName : (isUserFirstPlayer ? playerOneName : 'Computer'),
                player1IsBot: !isTwoPlayerMode && !isUserFirstPlayer,
                player1BorderColor: CupertinoColors.systemRed,
                player2Name: isTwoPlayerMode ? playerTwoName : (isUserFirstPlayer ? 'Computer' : playerTwoName),
                player2IsBot: !isTwoPlayerMode && isUserFirstPlayer,
                player2BorderColor: CupertinoColors.systemBlue,
                isPlayer1Turn: _isPlayer1Turn(),
                isGameOver: _gameState.isGameOver,
                shouldRunTimer: _shouldRunTimer(),
                timerDuration: const Duration(seconds: 60),
                onTimeout: _handleTimeout,
              ),
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

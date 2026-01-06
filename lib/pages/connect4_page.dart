import 'package:flutter/cupertino.dart';
import '../core/game_logic/game_logic.dart';
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

  late Connect4State _gameState;

  late bool isUserFirstPlayer;
  late bool isTwoPlayerMode;
  late GameDifficulty difficulty;
  late String? playerOneName;
  late String? playerTwoName;

  int? hoverColumn;

  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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


  void _handleColumnTap(int column) {
    if (_gameState.isGameOver) return;

    final move = Connect4Move(column);
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

  String _getCurrentPlayerSymbol() {
    final symbol = _gameState.currentPlayerSymbol;
    return symbol?.symbol ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Connect 4 (${difficulty.displayName})'),
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
                  board: _getBoardAsStrings(),
                  winningPattern: _gameState.winningPattern,
                  lineAnimation: _lineAnimation,
                  currentPlayer: _getCurrentPlayerSymbol(),
                  hoverColumn: hoverColumn,
                  onColumnTap: _handleColumnTap,
                  onColumnHover: (col) => setState(() => hoverColumn = col),
                  onColumnHoverExit: () => setState(() => hoverColumn = null),
                  canDropInColumn: (col) => !_gameState.isColumnFull(col),
                  isGameOver: _gameState.isGameOver,
                  rows: Connect4State.rows,
                  columns: Connect4State.columns,
                ),
                const SizedBox(height: 20),
                GameControls(
                  isGameOver: _gameState.isGameOver,
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


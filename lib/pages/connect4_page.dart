import 'package:flutter/cupertino.dart';
import '../core/game_logic/game_logic.dart';
import '../widgets/local_games/game_controls.dart';
import '../widgets/local_games/connect4/connect4_board.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';
import 'package:games_app/widgets/game_header.dart';
import '../core/utils/responsive_layout.dart';

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
  late GameDifficulty? difficulty;
  late String? playerOneName;
  late String? playerTwoName;

  int? hoverColumn;

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


  void _handleColumnTap(int column) {
    if (_gameState.isGameOver) return;
    if (_isProcessingMove) return;

    if (!isTwoPlayerMode) {
      final currentSymbol = _gameState.currentPlayerSymbol;
      if (currentSymbol == null) return;
      
      final isUserTurn = (currentSymbol == PlayerSymbol.x && isUserFirstPlayer) ||
          (currentSymbol == PlayerSymbol.o && !isUserFirstPlayer);
      
      if (!isUserTurn) return;
    }

    final move = Connect4Move(column);
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
    for (int col = 0; col < Connect4State.columns; col++) {
      if (!_gameState.isColumnFull(col)) {
        validMoves.add(col);
      }
    }

    if (validMoves.isNotEmpty) {
      final randomMove = validMoves[validMoves.length ~/ 2]; // Simple middle move
      _handleColumnTap(randomMove);
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
      navigationBar: AppGameNavBar(
        gameName: 'Connect 4',
        difficulty: difficulty,
      ),
      child: SafeArea(
        child: ResponsiveLayout.constrainWidth(
          context,
          SingleChildScrollView(
            child: Padding(
              padding: ResponsiveLayout.getPadding(context),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: ResponsiveLayout.getSpacing(context) * 1.25),
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
                    SizedBox(height: ResponsiveLayout.getSpacing(context) * 1.25),
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
                    SizedBox(height: ResponsiveLayout.getSpacing(context) * 1.25),
                    GameControls(
                      isGameOver: _gameState.isGameOver,
                      onReset: () => _resetBoard(startAsUser: isUserFirstPlayer),
                      newGameLabel: 'Play Again',
                    ),
                    SizedBox(height: ResponsiveLayout.getSpacing(context) * 1.25),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


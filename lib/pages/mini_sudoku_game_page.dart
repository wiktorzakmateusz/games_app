import 'package:flutter/cupertino.dart';
import '../core/game_logic/game_logic.dart';
import '../widgets/local_games/game_status_text.dart';
import '../widgets/local_games/game_controls.dart';
import '../widgets/local_games/mini_sudoku/mini_sudoku_board.dart';

class MiniSudokuPage extends StatefulWidget {
  const MiniSudokuPage({super.key});

  @override
  State<MiniSudokuPage> createState() => _MiniSudokuPageState();
}

class _MiniSudokuPageState extends State<MiniSudokuPage> {
  final MiniSudokuLogic _gameLogic = MiniSudokuLogic();
  late MiniSudokuState _gameState;
  late GameDifficulty difficulty;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map?;
      final difficultyStr = args?['difficulty'] ?? 'Easy';
      difficulty = GameDifficultyExtension.fromString(difficultyStr);
      _gameState = _gameLogic.createPuzzle(difficulty);
      _isInitialized = true;
    }
  }

  void _startNewGame() {
    setState(() {
      _gameState = _gameLogic.createPuzzle(difficulty);
    });
  }

  void _resetCurrentBoard() {
    setState(() {
      final newBoard = List<int>.from(_gameState.board);
      for (int i = 0; i < MiniSudokuState.totalCells; i++) {
        if (!_gameState.isLocked(i)) {
          newBoard[i] = 0;
        }
      }
      _gameState = _gameState.copyWith(
        board: newBoard,
        errorCells: {},
        isGameOver: false,
        result: GameResult.ongoing,
      );
    });
  }

  void _handleTap(int index) {
    if (_gameState.isLocked(index) || _gameState.isGameOver) return;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Number'),
        actions: [
          for (int i = 1; i <= 4; i++)
            CupertinoActionSheetAction(
              child: Text('$i'),
              onPressed: () {
                Navigator.pop(context);
                _updateBoard(index, i);
              },
            ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _updateBoard(index, 0);
            },
            child: const Text('Clear'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _updateBoard(int index, int value) {
    final move = MiniSudokuMove(position: index, number: value);

    if (!_gameLogic.isValidMove(_gameState, move)) {
      _showInvalidMoveAlert();
      return;
    }

    setState(() {
      _gameState = _gameLogic.applyMove(_gameState, move);
    });
  }

  void _showInvalidMoveAlert() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Invalid Move'),
        content: const Text(
            'This number conflicts with Sudoku rules (row, column, or box).'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (_gameState.isGameOver) {
      return 'Well done! Puzzle solved! 🎉';
    } else if (_gameState.errorCells.isNotEmpty) {
      return 'Some cells are incorrect (shown in red)';
    } else if (!_gameState.board.contains(0)) {
      return 'Board full - checking solution...';
    } else {
      return 'Fill the board';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Mini Sudoku (${difficulty.displayName})'),
        leading: GestureDetector(
          child: const Icon(CupertinoIcons.xmark,
              color: CupertinoColors.activeBlue),
          onTap: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        ),

        // I JUST ADDED THIS PART 07/01/2026
trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.info),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Mini Sudoku Rules'),
                content: const Text('\nFill the 4x4 grid with numbers 1 to 4.\n\nEvery row, column, and 2x2 box must contain each number exactly once.'),
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
              GameStatusText(text: _getStatusText()),
              const SizedBox(height: 20),
              MiniSudokuBoard(
                board: _gameState.board,
                isFixed: List.generate(
                  MiniSudokuState.totalCells,
                  (i) => _gameState.isLocked(i),
                ),
                wrongIndices: _gameState.errorCells,
                onCellTap: _handleTap,
              ),
              const SizedBox(height: 30),
              GameControls(
                isGameOver: _gameState.isGameOver,
                onReset: _resetCurrentBoard,
                onNewGame: _startNewGame,
                resetLabel: 'Reset',
                newGameLabel: 'New Game',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

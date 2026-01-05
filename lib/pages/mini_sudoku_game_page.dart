import 'package:flutter/cupertino.dart';
import 'dart:math';
import '../logic/mini_sudoku_logic.dart';
import '../widgets/local_games/game_status_text.dart';
import '../widgets/local_games/game_controls.dart';
import '../widgets/local_games/mini_sudoku/mini_sudoku_board.dart';

class MiniSudokuPage extends StatefulWidget {
  const MiniSudokuPage({super.key});

  @override
  State<MiniSudokuPage> createState() => _MiniSudokuPageState();
}

class _MiniSudokuPageState extends State<MiniSudokuPage> {
  List<int> board = List.filled(16, 0);
  List<int> solution = List.filled(16, 0);
  List<bool> isFixed = List.filled(16, false); 
  
  Set<int> wrongIndices = {};
  String statusText = 'Fill the board';
  bool isGameWon = false;
  String difficulty = 'Easy';

  final SudokuLogic _logic = SudokuLogic();
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (board.every((element) => element == 0)) {
       difficulty = args?['difficulty'] ?? 'Easy';
       _startNewGame();
    }
  }

  void _startNewGame() {
    setState(() {
      isGameWon = false;
      statusText = 'Fill the board';
      board = List.filled(16, 0);
      solution = List.filled(16, 0);
      isFixed = List.filled(16, false);
      wrongIndices.clear();
      
      // 1. Generate a full valid solution and SAVE it
      solution = _logic.generateSolvedBoard();
      
      // 2. Copy solution to board
      board = List.from(solution);
      
      // 3. Remove numbers based on difficulty
      int numbersToRemove;
      switch (difficulty) {
        case 'Hard': numbersToRemove = 10; break; 
        case 'Medium': numbersToRemove = 8; break; 
        case 'Easy': default: numbersToRemove = 6; break; 
      }
      
      final random = Random();
      int removedCount = 0;
      while (removedCount < numbersToRemove) {
        int index = random.nextInt(16);
        if (board[index] != 0) {
          board[index] = 0;
          removedCount++;
        }
      }

      // 4. Lock the remaining numbers
      for (int i = 0; i < 16; i++) {
        isFixed[i] = board[i] != 0;
      }
    });
  }

  /// Clears only the user's moves (keeps fixed numbers)
  void _resetCurrentBoard() {
    setState(() {
      wrongIndices.clear(); // Clear error red marks
      statusText = 'Fill the board';
      for (int i = 0; i < 16; i++) {
        if (!isFixed[i]) {
          board[i] = 0;
        }
      }
    });
  }

  void _handleTap(int index) {
    if (isFixed[index] || isGameWon) return;

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
    setState(() {
      board[index] = value;
      // If user changes a cell that was marked wrong, remove the red mark
      wrongIndices.remove(index); 
      
      // Check if board is full
      if (!board.contains(0)) {
        _validateFullBoard();
      } else {
        statusText = 'Keep going...';
      }
    });
  }

  void _validateFullBoard() {
    final result = _logic.validateFullBoard(board, solution);

    setState(() {
      wrongIndices = result['wrongIndices'];
      statusText = result['statusText'];
      isGameWon = result['isCorrect'];
    });
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Mini Sudoku'),
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
              GameStatusText(text: statusText),
              const SizedBox(height: 20),
              MiniSudokuBoard(
                board: board,
                isFixed: isFixed,
                wrongIndices: wrongIndices,
                onCellTap: _handleTap,
              ),
              const SizedBox(height: 30),
              GameControls(
                isGameOver: isGameWon,
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
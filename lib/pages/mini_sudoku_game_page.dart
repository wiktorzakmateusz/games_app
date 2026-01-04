import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Used for Colors
import 'dart:math';
import '../logic/mini_sudoku_logic.dart';

class MiniSudokuPage extends StatefulWidget {
  const MiniSudokuPage({super.key});

  @override
  State<MiniSudokuPage> createState() => _MiniSudokuPageState();
}

class _MiniSudokuPageState extends State<MiniSudokuPage> {

  

  // Game State
  List<int> board = List.filled(16, 0);
  List<int> solution = List.filled(16, 0); // Store the correct answer here
  List<bool> isFixed = List.filled(16, false); 
  
  // Validation State
  Set<int> wrongIndices = {}; // Tracks which cells are incorrect
  String statusText = 'Fill the board';
  bool isGameWon = false;
  String difficulty = 'Easy';

  final SudokuLogic _logic = SudokuLogic();
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    // Only generate if board is empty
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

  Widget _buildCell(int index) {
    final int value = board[index];
    final bool fixed = isFixed[index];
    final bool isWrong = wrongIndices.contains(index);
    
    // Grid styling
    final int row = index ~/ 4;
    final int col = index % 4;
    final bool rightBorder = (col == 1); 
    final bool bottomBorder = (row == 1); 

    // Determine Text Color
    Color textColor;
    if (isWrong) {
      textColor = CupertinoColors.systemRed; // Red if wrong
    } else if (fixed) {
      textColor = CupertinoColors.black; // Black if fixed
    } else {
      textColor = CupertinoColors.activeBlue; // Blue if user entered (and valid/unchecked)
    }

    return GestureDetector(
      onTap: () => _handleTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          border: Border(
            top: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
            left: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
            right: BorderSide(
              color: rightBorder ? CupertinoColors.black : CupertinoColors.systemGrey4, 
              width: rightBorder ? 2.0 : 0.5
            ),
            bottom: BorderSide(
              color: bottomBorder ? CupertinoColors.black : CupertinoColors.systemGrey4, 
              width: bottomBorder ? 2.0 : 0.5
            ),
          ),
        ),
        child: Center(
          child: Text(
            value == 0 ? '' : '$value',
            style: TextStyle(
              fontSize: 32,
              fontWeight: fixed ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double boardSize = 320;

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
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.black,
                ),
              ),
              
              const SizedBox(height: 20),
              
              Container(
                width: boardSize,
                height: boardSize,
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.black, width: 2),
                  color: CupertinoColors.white,
                  boxShadow: const [
                     BoxShadow(
                      color: CupertinoColors.systemGrey4,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: 16,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, 
                  ),
                  itemBuilder: (context, index) => _buildCell(index),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Button Logic:
              // Won -> New Game
              // Playing/Wrong -> Reset (Clears user input)
              CupertinoButton.filled(
                onPressed: isGameWon ? _startNewGame : _resetCurrentBoard,
                child: Text(isGameWon ? 'New Game' : 'Reset'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
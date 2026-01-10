library;

import 'dart:math' as math;
import '../game_logic_interface.dart';
import '../game_state.dart';
import '../game_types.dart';
import 'mini_sudoku_state.dart';

class MiniSudokuLogic extends GameLogic<MiniSudokuState, MiniSudokuMove> {
  @override
  GameType get gameType => GameType.miniSudoku;

  @override
  MiniSudokuState createInitialState({
    required PlayerSymbol startingPlayer,
  }) {
    final solution = _generateSolution();
    final lockedCells = _createPuzzle(solution);

    return MiniSudokuState.initial(
      solution: solution,
      lockedCells: lockedCells,
    );
  }

  MiniSudokuState createPuzzle(GameDifficulty difficulty) {
    final solution = _generateSolution();
    final lockedCells = _createPuzzleWithDifficulty(solution, difficulty);

    return MiniSudokuState.initial(
      solution: solution,
      lockedCells: lockedCells,
    );
  }

  @override
  bool isValidMove(MiniSudokuState state, MiniSudokuMove move) {
    if (state.isGameOver) return false;

    if (move.position < 0 || move.position >= MiniSudokuState.totalCells) {
      return false;
    }

    if (move.number < 0 || move.number > 4) return false;

    if (state.isLocked(move.position)) return false;

    if (move.number != 0) {
      return _isValidPlacement(state.board, move.position, move.number);
    }

    return true;
  }

  @override
  MiniSudokuState applyMove(MiniSudokuState state, MiniSudokuMove move) {
    if (!isValidMove(state, move)) {
      throw ArgumentError('Invalid move: $move');
    }

    final newBoard = List<int>.from(state.board);
    newBoard[move.position] = move.number;

    final newErrorCells = _findErrors(newBoard, state.solution);

    final isComplete = !newBoard.contains(0);
    final isCorrect = isComplete && newErrorCells.isEmpty;

    return MiniSudokuState(
      board: newBoard,
      solution: state.solution,
      lockedCells: state.lockedCells,
      errorCells: newErrorCells,
      isGameOver: isCorrect,
      result: isCorrect ? GameResult.win : GameResult.ongoing,
    );
  }

  @override
  WinCheckResult checkWinner(MiniSudokuState state) {
    final isComplete = !state.board.contains(0);
    final isCorrect = isComplete && state.errorCells.isEmpty;

    return WinCheckResult(
      hasWinner: isCorrect,
      winner: null,
    );
  }

  @override
  PlayerSymbol getNextPlayer(PlayerSymbol currentPlayer) {
    return currentPlayer;
  }

  @override
  List<MiniSudokuMove> getValidMoves(MiniSudokuState state) {
    if (state.isGameOver) return [];

    final validMoves = <MiniSudokuMove>[];

    for (int position = 0; position < MiniSudokuState.totalCells; position++) {
      if (state.isLocked(position)) continue;

      if (!state.isEmpty(position)) {
        validMoves.add(MiniSudokuMove(position: position, number: 0));
      }

      for (int number = 1; number <= 4; number++) {
        if (_isValidPlacement(state.board, position, number)) {
          validMoves.add(MiniSudokuMove(position: position, number: number));
        }
      }
    }

    return validMoves;
  }

  bool _isValidPlacement(List<int> board, int position, int number) {
    final row = position ~/ MiniSudokuState.size;
    final col = position % MiniSudokuState.size;

    final testBoard = List<int>.from(board);
    testBoard[position] = number;

    for (int c = 0; c < MiniSudokuState.size; c++) {
      if (c != col) {
        final index = row * MiniSudokuState.size + c;
        if (testBoard[index] == number) return false;
      }
    }

    for (int r = 0; r < MiniSudokuState.size; r++) {
      if (r != row) {
        final index = r * MiniSudokuState.size + col;
        if (testBoard[index] == number) return false;
      }
    }

    final boxStartRow = (row ~/ 2) * 2;
    final boxStartCol = (col ~/ 2) * 2;
    for (int r = boxStartRow; r < boxStartRow + 2; r++) {
      for (int c = boxStartCol; c < boxStartCol + 2; c++) {
        if (r != row || c != col) {
          final index = r * MiniSudokuState.size + c;
          if (testBoard[index] == number) return false;
        }
      }
    }

    return true;
  }

  Set<int> _findErrors(List<int> board, List<int> solution) {
    final errors = <int>{};
    for (int i = 0; i < MiniSudokuState.totalCells; i++) {
      if (board[i] != 0 && board[i] != solution[i]) {
        errors.add(i);
      }
    }
    return errors;
  }

  List<int> _generateSolution() {
    final board = List<int>.filled(MiniSudokuState.totalCells, 0);
    _solveBoardRecursively(board);
    return board;
  }

  bool _solveBoardRecursively(List<int> board) {
    final emptyIndex = board.indexOf(0);
    if (emptyIndex == -1) return true;

    final numbers = [1, 2, 3, 4]..shuffle();

    for (final num in numbers) {
      if (_isValidPlacement(board, emptyIndex, num)) {
        board[emptyIndex] = num;
        if (_solveBoardRecursively(board)) return true;
        board[emptyIndex] = 0;
      }
    }

    return false;
  }

  Set<int> _createPuzzle(List<int> solution) {
    return _createPuzzleWithDifficulty(solution, GameDifficulty.medium);
  }

  Set<int> _createPuzzleWithDifficulty(
      List<int> solution, GameDifficulty difficulty) {
    int cellsToKeep;
    switch (difficulty) {
      case GameDifficulty.easy:
        cellsToKeep = 10; // Keep 10 out of 16 cells
      case GameDifficulty.medium:
        cellsToKeep = 7; // Keep 7 out of 16 cells
      case GameDifficulty.hard:
        cellsToKeep = 5; // Keep 5 out of 16 cells
    }

    final allIndices = List<int>.generate(MiniSudokuState.totalCells, (i) => i);
    allIndices.shuffle(math.Random());

    return Set<int>.from(allIndices.take(cellsToKeep));
  }

  MiniSudokuMove? getHint(MiniSudokuState state) {
    for (int i = 0; i < MiniSudokuState.totalCells; i++) {
      if (state.isEmpty(i) && !state.isLocked(i)) {
        return MiniSudokuMove(
          position: i,
          number: state.solution[i],
        );
      }
    }
    return null;
  }

  Map<String, dynamic> validateBoard(
      List<int> currentBoard, List<int> solution) {
    final wrongIndices = <int>{};
    bool isCorrect = true;

    for (int i = 0; i < MiniSudokuState.totalCells; i++) {
      if (currentBoard[i] != solution[i]) {
        wrongIndices.add(i);
        isCorrect = false;
      }
    }

    return {
      'isCorrect': isCorrect,
      'wrongIndices': wrongIndices,
      'statusText': isCorrect ? 'Well done!' : 'Wrong. Fix red cells.'
    };
  }
}


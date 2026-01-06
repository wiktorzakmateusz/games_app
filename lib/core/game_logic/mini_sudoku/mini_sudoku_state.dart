library;

import '../game_state.dart';
import '../game_types.dart';

class MiniSudokuMove {
  final int position;
  final int number; // 1-4 for 4x4 sudoku

  const MiniSudokuMove({
    required this.position,
    required this.number,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiniSudokuMove &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          number == other.number;

  @override
  int get hashCode => position.hashCode ^ number.hashCode;

  @override
  String toString() => 'MiniSudokuMove(position: $position, number: $number)';
}

class MiniSudokuState extends GameState {
  static const int size = 4; // 4x4 board
  static const int totalCells = 16;

  /// 4x4 board represented as a flat list of 16 cells
  /// 0 means empty cell, 1-4 are the numbers
  final List<int> board;

  final List<int> solution;

  final Set<int> lockedCells;

  final Set<int> errorCells;

  const MiniSudokuState({
    required this.board,
    required this.solution,
    required this.lockedCells,
    required this.errorCells,
    required super.isGameOver,
    required super.result,
  }) : super(
          winnerSymbol: null,
          currentPlayerSymbol: null,
        );

  factory MiniSudokuState.initial({
    required List<int> solution,
    required Set<int> lockedCells,
  }) {
    final board = List<int>.filled(totalCells, 0);
    for (final index in lockedCells) {
      board[index] = solution[index];
    }

    return MiniSudokuState(
      board: board,
      solution: solution,
      lockedCells: lockedCells,
      errorCells: {},
      isGameOver: false,
      result: GameResult.ongoing,
    );
  }

  int getCell(int position) {
    if (position < 0 || position >= totalCells) return 0;
    return board[position];
  }

  bool isEmpty(int position) => getCell(position) == 0;

  bool isLocked(int position) => lockedCells.contains(position);

  bool hasError(int position) => errorCells.contains(position);

  int getRow(int position) => position ~/ size;

  int getCol(int position) => position % size;

  MiniSudokuState copyWith({
    List<int>? board,
    List<int>? solution,
    Set<int>? lockedCells,
    Set<int>? errorCells,
    bool? isGameOver,
    GameResult? result,
  }) {
    return MiniSudokuState(
      board: board ?? this.board,
      solution: solution ?? this.solution,
      lockedCells: lockedCells ?? this.lockedCells,
      errorCells: errorCells ?? this.errorCells,
      isGameOver: isGameOver ?? this.isGameOver,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
        board,
        solution,
        lockedCells,
        errorCells,
        isGameOver,
        result,
      ];
}


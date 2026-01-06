library;

import '../game_state.dart';
import '../game_types.dart';

class Connect4Move {
  final int column;

  const Connect4Move(this.column);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Connect4Move &&
          runtimeType == other.runtimeType &&
          column == other.column;

  @override
  int get hashCode => column.hashCode;

  @override
  String toString() => 'Connect4Move(column: $column)';
}

class Connect4State extends GameState {
  static const int columns = 7;
  static const int rows = 6;
  static const int totalCells = 42;

  /// 7x6 board represented as a flat list of 42 cells
  /// index = row * 7 + col
  /// Each cell contains either a PlayerSymbol or is null (empty)
  final List<PlayerSymbol?> board;

  final List<int>? winningPattern;

  const Connect4State({
    required this.board,
    required super.isGameOver,
    required super.result,
    super.winnerSymbol,
    super.currentPlayerSymbol,
    this.winningPattern,
  });

  factory Connect4State.initial({
    required PlayerSymbol startingPlayer,
  }) {
    return Connect4State(
      board: List.filled(totalCells, null),
      isGameOver: false,
      result: GameResult.ongoing,
      currentPlayerSymbol: startingPlayer,
      winningPattern: null,
    );
  }

  PlayerSymbol? getCell(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) return null;
    final index = row * columns + col;
    if (index < 0 || index >= totalCells) return null;
    return board[index];
  }

  bool isEmpty(int row, int col) => getCell(row, col) == null;

  int getDropRow(int column) {
    if (column < 0 || column >= columns) return -1;
    
    for (int row = rows - 1; row >= 0; row--) {
      if (isEmpty(row, column)) {
        return row;
      }
    }
    return -1; 
  }

  bool isColumnFull(int column) => getDropRow(column) == -1;

  Connect4State copyWith({
    List<PlayerSymbol?>? board,
    bool? isGameOver,
    GameResult? result,
    PlayerSymbol? winnerSymbol,
    PlayerSymbol? currentPlayerSymbol,
    List<int>? winningPattern,
  }) {
    return Connect4State(
      board: board ?? this.board,
      isGameOver: isGameOver ?? this.isGameOver,
      result: result ?? this.result,
      winnerSymbol: winnerSymbol ?? this.winnerSymbol,
      currentPlayerSymbol: currentPlayerSymbol ?? this.currentPlayerSymbol,
      winningPattern: winningPattern ?? this.winningPattern,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        board,
        winningPattern,
      ];
}


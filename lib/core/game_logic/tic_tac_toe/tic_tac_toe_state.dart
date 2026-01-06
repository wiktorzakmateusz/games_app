library;

import '../game_state.dart';
import '../game_types.dart';

class TicTacToeMove {
  final int position;

  const TicTacToeMove(this.position);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicTacToeMove &&
          runtimeType == other.runtimeType &&
          position == other.position;

  @override
  int get hashCode => position.hashCode;

  @override
  String toString() => 'TicTacToeMove($position)';
}

class TicTacToeState extends GameState {
  final List<PlayerSymbol?> board;
  final List<int>? winningPattern;

  const TicTacToeState({
    required this.board,
    required super.isGameOver,
    required super.result,
    super.winnerSymbol,
    super.currentPlayerSymbol,
    this.winningPattern,
  });

  factory TicTacToeState.initial({
    required PlayerSymbol startingPlayer,
  }) {
    return TicTacToeState(
      board: List.filled(9, null),
      isGameOver: false,
      result: GameResult.ongoing,
      currentPlayerSymbol: startingPlayer,
      winningPattern: null,
    );
  }

  PlayerSymbol? getCell(int position) {
    if (position < 0 || position >= 9) return null;
    return board[position];
  }

  bool isEmpty(int position) => getCell(position) == null;

  TicTacToeState copyWith({
    List<PlayerSymbol?>? board,
    bool? isGameOver,
    GameResult? result,
    PlayerSymbol? winnerSymbol,
    PlayerSymbol? currentPlayerSymbol,
    List<int>? winningPattern,
  }) {
    return TicTacToeState(
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


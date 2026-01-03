import 'package:equatable/equatable.dart';

abstract class BaseGameStateEntity extends Equatable {
  final bool gameOver;
  final String? winner;
  final bool isDraw;

  const BaseGameStateEntity({
    required this.gameOver,
    this.winner,
    required this.isDraw,
  });

  @override
  List<Object?> get props => [gameOver, winner, isDraw];
}

class TicTacToeGameStateEntity extends BaseGameStateEntity {
  final List<String?> board;

  const TicTacToeGameStateEntity({
    required this.board,
    required super.gameOver,
    super.winner,
    required super.isDraw,
  });

  String? getCell(int index) {
    if (index < 0 || index >= 9) return null;
    return board[index];
  }

  bool isEmpty(int index) {
    return getCell(index) == null;
  }

  List<int>? getWinningPattern() {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      final a = pattern[0], b = pattern[1], c = pattern[2];
      if (board[a] != null &&
          board[a] == board[b] &&
          board[a] == board[c]) {
        return pattern;
      }
    }
    return null;
  }

  TicTacToeGameStateEntity makeOptimisticMove(int position, String symbol) {
    if (!isEmpty(position)) return this;

    final newBoard = List<String?>.from(board);
    newBoard[position] = symbol;

    final hasWinner = _checkWinner(newBoard) != null;
    final isFull = !newBoard.contains(null);

    return TicTacToeGameStateEntity(
      board: newBoard,
      gameOver: hasWinner || isFull,
      winner: hasWinner ? symbol : null,
      isDraw: !hasWinner && isFull,
    );
  }

  String? _checkWinner(List<String?> board) {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      final a = pattern[0], b = pattern[1], c = pattern[2];
      if (board[a] != null &&
          board[a] == board[b] &&
          board[a] == board[c]) {
        return board[a];
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [board, gameOver, winner, isDraw];
}


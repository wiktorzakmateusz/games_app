import 'enums.dart';

/// Factory function type for creating game states from JSON
typedef GameStateFactory = BaseGameState Function(Map<String, dynamic>);

abstract class BaseGameState {
  final bool gameOver;
  final String? winner;
  final bool isDraw;

  BaseGameState({
    required this.gameOver,
    this.winner,
    required this.isDraw,
  });

  Map<String, dynamic> toJson();

  static final Map<GameType, GameStateFactory> _factories = {
    GameType.ticTacToe: (json) => TicTacToeGameState.fromJson(json),
    // Add new game types here:
    // GameType.yourGame: (json) => YourGameState.fromJson(json),
  };

  static BaseGameState fromJson(GameType gameType, Map<String, dynamic> json) {
    final factory = _factories[gameType];
    if (factory == null) {
      throw ArgumentError('No factory registered for game type: $gameType');
    }
    return factory(json);
  }
}

/// Tic Tac Toe specific game state
/// Board is a flat array of 9 cells (3x3 grid)
/// Each cell can be null (empty), 'X', or 'O'
class TicTacToeGameState extends BaseGameState {
  final List<String?> board;

  TicTacToeGameState({
    required this.board,
    required super.gameOver,
    super.winner,
    required super.isDraw,
  });

  factory TicTacToeGameState.fromJson(Map<String, dynamic> json) {
    final boardData = json['board'] as List? ?? [];
    final board = boardData.map((cell) {
      if (cell == null) return null;
      return cell.toString();
    }).toList();

    return TicTacToeGameState(
      board: List<String?>.from(board),
      gameOver: json['gameOver'] as bool? ?? false,
      winner: json['winner'] as String?,
      isDraw: json['isDraw'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'gameOver': gameOver,
      'winner': winner,
      'isDraw': isDraw,
    };
  }

  String? getCell(int index) {
    if (index < 0 || index >= 9) return null;
    return board[index];
  }

  bool isEmpty(int index) {
    return getCell(index) == null;
  }
}


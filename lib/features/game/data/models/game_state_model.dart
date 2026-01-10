import '../../../../core/utils/typedefs.dart';
import '../../../../core/shared/enums.dart';
import '../../domain/entities/game_state_entity.dart';

abstract class GameStateModel extends BaseGameStateEntity {
  const GameStateModel({
    required super.gameOver,
    super.winner,
    required super.isDraw,
  });

  JsonMap toJson();

  static BaseGameStateEntity fromJson(GameType gameType, JsonMap json) {
    if (gameType == GameType.ticTacToe) {
      return TicTacToeGameStateModel.fromJson(json);
    } else if (gameType == GameType.connect4) {
      return Connect4GameStateModel.fromJson(json);
    }
    throw ArgumentError('Unsupported game type: $gameType');
  }
}

class TicTacToeGameStateModel extends GameStateModel {
  final List<String?> board;

  const TicTacToeGameStateModel({
    required this.board,
    required super.gameOver,
    super.winner,
    required super.isDraw,
  });

  factory TicTacToeGameStateModel.fromJson(JsonMap json) {
    final boardData = json['board'] as List? ?? [];
    final board = boardData.map((cell) {
      if (cell == null) return null;
      return cell.toString();
    }).toList();

    return TicTacToeGameStateModel(
      board: List<String?>.from(board),
      gameOver: json['gameOver'] as bool? ?? false,
      winner: json['winner'] as String?,
      isDraw: json['isDraw'] as bool? ?? false,
    );
  }

  @override
  JsonMap toJson() {
    return {
      'board': board,
      'gameOver': gameOver,
      'winner': winner,
      'isDraw': isDraw,
    };
  }

  TicTacToeGameStateEntity toEntity() {
    return TicTacToeGameStateEntity(
      board: board,
      gameOver: gameOver,
      winner: winner,
      isDraw: isDraw,
    );
  }

  factory TicTacToeGameStateModel.fromEntity(TicTacToeGameStateEntity entity) {
    return TicTacToeGameStateModel(
      board: entity.board,
      gameOver: entity.gameOver,
      winner: entity.winner,
      isDraw: entity.isDraw,
    );
  }

  String? getCell(int index) {
    if (index < 0 || index >= 9) return null;
    return board[index];
  }

  bool isEmpty(int index) {
    return getCell(index) == null;
  }

  @override
  List<Object?> get props => [board, gameOver, winner, isDraw];
}

class Connect4GameStateModel extends GameStateModel {
  final List<String?> board; // 42 cells (7 columns x 6 rows)

  const Connect4GameStateModel({
    required this.board,
    required super.gameOver,
    super.winner,
    required super.isDraw,
  });

  factory Connect4GameStateModel.fromJson(JsonMap json) {
    final boardData = json['board'] as List? ?? [];
    final board = boardData.map((cell) {
      if (cell == null) return null;
      return cell.toString();
    }).toList();

    // Ensure board has exactly 42 cells
    final boardList = List<String?>.from(board);
    while (boardList.length < 42) {
      boardList.add(null);
    }
    if (boardList.length > 42) {
      boardList.removeRange(42, boardList.length);
    }

    return Connect4GameStateModel(
      board: boardList,
      gameOver: json['gameOver'] as bool? ?? false,
      winner: json['winner'] as String?,
      isDraw: json['isDraw'] as bool? ?? false,
    );
  }

  @override
  JsonMap toJson() {
    return {
      'board': board,
      'gameOver': gameOver,
      'winner': winner,
      'isDraw': isDraw,
    };
  }

  Connect4GameStateEntity toEntity() {
    return Connect4GameStateEntity(
      board: board,
      gameOver: gameOver,
      winner: winner,
      isDraw: isDraw,
    );
  }

  factory Connect4GameStateModel.fromEntity(Connect4GameStateEntity entity) {
    return Connect4GameStateModel(
      board: entity.board,
      gameOver: entity.gameOver,
      winner: entity.winner,
      isDraw: entity.isDraw,
    );
  }

  String? getCell(int row, int col) {
    if (row < 0 || row >= 6 || col < 0 || col >= 7) return null;
    final index = row * 7 + col;
    if (index < 0 || index >= 42) return null;
    return board[index];
  }

  bool isEmpty(int row, int col) {
    return getCell(row, col) == null;
  }

  @override
  List<Object?> get props => [board, gameOver, winner, isDraw];
}


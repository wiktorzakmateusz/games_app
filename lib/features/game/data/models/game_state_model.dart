import '../../../../core/utils/typedefs.dart';
import '../../../../models/enums.dart';
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


/// Enums matching the backend API
enum LobbyStatus {
  waiting('WAITING'),
  inGame('IN_GAME'),
  finished('FINISHED');

  final String value;
  const LobbyStatus(this.value);

  static LobbyStatus fromString(String value) {
    return LobbyStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LobbyStatus.waiting,
    );
  }
}

enum GameStatus {
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  abandoned('ABANDONED');

  final String value;
  const GameStatus(this.value);

  static GameStatus fromString(String value) {
    return GameStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GameStatus.inProgress,
    );
  }
}

enum GameType {
  ticTacToe('TIC_TAC_TOE');

  final String value;
  const GameType(this.value);

  static GameType fromString(String value) {
    return GameType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GameType.ticTacToe,
    );
  }
}


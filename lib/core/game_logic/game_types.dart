library;

enum GameType {
  ticTacToe,
  connect4,
  miniSudoku,
}

enum GameMode {
  localVsAI,
  localTwoPlayer,
  online,
}

enum GameDifficulty {
  easy,
  medium,
  hard,
}

enum GameResult {
  win,
  loss,
  draw,
  ongoing,
}

enum PlayerSymbol {
  x,
  o,
}

extension PlayerSymbolExtension on PlayerSymbol {
  String get symbol => this == PlayerSymbol.x ? 'X' : 'O';
  
  PlayerSymbol get opposite => 
      this == PlayerSymbol.x ? PlayerSymbol.o : PlayerSymbol.x;
}

extension GameDifficultyExtension on GameDifficulty {
  String get displayName {
    switch (this) {
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.medium:
        return 'Medium';
      case GameDifficulty.hard:
        return 'Hard';
    }
  }
  
  static GameDifficulty fromString(String str) {
    switch (str.toLowerCase()) {
      case 'easy':
        return GameDifficulty.easy;
      case 'medium':
        return GameDifficulty.medium;
      case 'hard':
        return GameDifficulty.hard;
      default:
        return GameDifficulty.easy;
    }
  }
}


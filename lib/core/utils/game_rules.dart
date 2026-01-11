import '../game_logic/game_types.dart';

class GameRules {
  static GameRuleInfo getRules(GameType gameType) {
    switch (gameType) {
      case GameType.ticTacToe:
        return GameRuleInfo(
          title: 'Tic-Tac-Toe Rules',
          description: 'First player to align 3 symbols wins.',
          rules: [
            'Horizontal alignment',
            'Vertical alignment',
            'Diagonal alignment',
          ],
          additionalInfo: 'If all cells are filled without a winner, the game ends in a draw.',
        );
      
      case GameType.miniSudoku:
        return GameRuleInfo(
          title: 'Mini Sudoku Rules',
          description: 'Fill the 4x4 grid with numbers 1 to 4.',
          rules: [
            'Every row, column, and 2x2 box must contain each number exactly once.',
          ],
          additionalInfo: null,
        );
      
      case GameType.connect4:
        return GameRuleInfo(
          title: 'Connect 4 Rules',
          description: 'The goal is to connect 4 discs of your color next to each other.',
          rules: [
            'Horizontally',
            'Vertically',
            'Diagonally',
          ],
          additionalInfo: null,
        );
    }
  }
  
  static String getDifficultyLabel(GameDifficulty difficulty) {
    return difficulty.displayName;
  }
}

class GameRuleInfo {
  final String title;
  final String description;
  final List<String> rules;
  final String? additionalInfo;

  const GameRuleInfo({
    required this.title,
    required this.description,
    required this.rules,
    this.additionalInfo,
  });
}


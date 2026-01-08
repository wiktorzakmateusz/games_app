import '../shared/enums.dart';

class GameImageHelper {
  static String _gameTypeToPath(GameType gameType) {
    return gameType.value.toLowerCase();
  }

  static String getPreviewImagePath(GameType gameType) {
    return 'images/${_gameTypeToPath(gameType)}/preview.png';
  }

  static String getIconImagePath(GameType gameType) {
    return 'images/${_gameTypeToPath(gameType)}/icon.png';
  }
}


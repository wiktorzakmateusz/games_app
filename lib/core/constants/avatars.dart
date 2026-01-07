import 'dart:math';

class Avatars {
  static const String basePath = 'images/avatars';
  
  static const List<String> availableAvatars = [
    '$basePath/avatar_0.png',
    '$basePath/avatar_1.png',
    '$basePath/avatar_2.png',
    '$basePath/avatar_3.png',
    '$basePath/avatar_4.png',
    '$basePath/avatar_5.png',
    '$basePath/avatar_6.png',
    '$basePath/avatar_7.png',
    '$basePath/avatar_8.png',
    '$basePath/avatar_9.png',
    '$basePath/avatar_10.png',
    '$basePath/avatar_11.png',
    '$basePath/avatar_12.png',
    '$basePath/avatar_13.png',
    '$basePath/avatar_14.png',
    '$basePath/avatar_15.png',
  ];

  static String defaultAvatar = getRandomAvatar();

  static String getRandomAvatar() {
    return availableAvatars[Random().nextInt(availableAvatars.length)];
  }

  static bool isValidAvatar(String? path) {
    if (path == null || path.isEmpty) return false;
    return availableAvatars.contains(path) || path == defaultAvatar;
  }

  static String? getAvatarByIndex(int index) {
    if (index < 0 || index >= availableAvatars.length) return null;
    return availableAvatars[index];
  }

  static int getAvatarIndex(String? path) {
    if (path == null || path.isEmpty) return -1;
    return availableAvatars.indexOf(path);
  }
}


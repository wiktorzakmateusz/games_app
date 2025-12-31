class Player {
  final String userId;
  final String username;
  final String displayName;
  final String? photoURL;
  final bool isReady;
  final DateTime joinedAt;

  Player({
    required this.userId,
    required this.username,
    required this.displayName,
    this.photoURL,
    required this.isReady,
    required this.joinedAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String? ?? json['username'] as String,
      photoURL: json['photoURL'] as String?,
      isReady: json['isReady'] as bool? ?? false,
      joinedAt: _parseDateTime(json['joinedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'photoURL': photoURL,
      'isReady': isReady,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is Map && value['seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['seconds'] as int) * 1000,
      );
    }
    return DateTime.now();
  }

}

class GamePlayer {
  final String userId;
  final String username;
  final String displayName;
  final String? symbol;

  GamePlayer({
    required this.userId,
    required this.username,
    required this.displayName,
    this.symbol,
  });

  factory GamePlayer.fromJson(Map<String, dynamic> json) {
    return GamePlayer(
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      symbol: json['symbol'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName,
      if (symbol != null) 'symbol': symbol,
    };
  }
}


import 'package:equatable/equatable.dart';

class GamePlayerEntity extends Equatable {
  final String userId;
  final String username;
  final String displayName;
  final String? symbol;

  const GamePlayerEntity({
    required this.userId,
    required this.username,
    required this.displayName,
    this.symbol,
  });

  @override
  List<Object?> get props => [userId, username, displayName, symbol];
}


library;

import 'package:equatable/equatable.dart';
import 'game_types.dart';

abstract class GameState extends Equatable {
  final bool isGameOver;
  final GameResult result;
  
  final PlayerSymbol? winnerSymbol;
  
  final PlayerSymbol? currentPlayerSymbol;

  const GameState({
    required this.isGameOver,
    required this.result,
    this.winnerSymbol,
    this.currentPlayerSymbol,
  });

  bool get isDraw => result == GameResult.draw;
  
  bool get hasWinner => winnerSymbol != null;

  @override
  List<Object?> get props => [
        isGameOver,
        result,
        winnerSymbol,
        currentPlayerSymbol,
      ];
}

class WinCheckResult {
  final bool hasWinner;
  final PlayerSymbol? winner;
  final List<int>? winningPattern;

  const WinCheckResult({
    required this.hasWinner,
    this.winner,
    this.winningPattern,
  });

  static const WinCheckResult noWinner = WinCheckResult(hasWinner: false);
}


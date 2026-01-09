import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/game/domain/entities/game_entity.dart';
import 'package:games_app/features/game/domain/entities/game_player_entity.dart';
import 'package:games_app/features/game/domain/entities/game_state_entity.dart';
import 'package:games_app/features/game/domain/repositories/game_repository.dart';
import 'package:games_app/features/game/domain/usecases/watch_game_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'watch_game_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([GameRepository])
void main() {
  late WatchGameUseCase usecase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    usecase = WatchGameUseCase(mockRepository);
  });

  const testGameId = 'game123';
  final testPlayers = [
    const GamePlayerEntity(
      userId: 'user1',
      username: 'player1',
      displayName: 'Player One',
      symbol: 'X',
    ),
    const GamePlayerEntity(
      userId: 'user2',
      username: 'player2',
      displayName: 'Player Two',
      symbol: 'O',
    ),
  ];
  final testGame = GameEntity(
    id: testGameId,
    lobbyId: 'lobby123',
    gameType: GameType.ticTacToe,
    status: GameStatus.inProgress,
    currentPlayerId: 'user1',
    players: testPlayers,
    state: const TicTacToeGameStateEntity(
      board: [null, null, null, null, null, null, null, null, null],
      gameOver: false,
      isDraw: false,
    ),
    startedAt: DateTime(2024),
  );

  group('WatchGameUseCase', () {
    test('should return stream of GameEntity from repository', () {
      // Arrange
      final stream = Stream<GameEntity>.value(testGame);
      when(mockRepository.watchGame(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testGameId);

      // Assert
      expect(result, stream);
      verify(mockRepository.watchGame(testGameId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should emit GameEntity when game state updates', () async {
      // Arrange
      final stream = Stream<GameEntity>.value(testGame);
      when(mockRepository.watchGame(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testGameId);

      // Assert
      await expectLater(result, emits(testGame));
    });

    test('should emit updated game state after move', () async {
      // Arrange
      final updatedGame = testGame.copyWith(
        currentPlayerId: 'user2',
        state: const TicTacToeGameStateEntity(
          board: ['X', null, null, null, null, null, null, null, null],
          gameOver: false,
          isDraw: false,
        ),
      );
      final stream = Stream<GameEntity>.fromIterable([testGame, updatedGame]);
      when(mockRepository.watchGame(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testGameId);

      // Assert
      await expectLater(
        result,
        emitsInOrder([testGame, updatedGame]),
      );
    });

    test('should emit game state when game ends', () async {
      // Arrange
      final endedGame = testGame.copyWith(
        status: GameStatus.completed,
        winnerId: 'user1',
        state: const TicTacToeGameStateEntity(
          board: ['X', 'X', 'X', 'O', 'O', null, null, null, null],
          gameOver: true,
          isDraw: false,
          winner: 'X',
        ),
        endedAt: DateTime(2024),
      );
      final stream = Stream<GameEntity>.value(endedGame);
      when(mockRepository.watchGame(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testGameId);

      // Assert
      await expectLater(result, emits(endedGame));
    });

    test('should emit multiple state changes in sequence', () async {
      // Arrange
      final game1 = testGame;
      final game2 = testGame.copyWith(
        currentPlayerId: 'user2',
        state: const TicTacToeGameStateEntity(
          board: ['X', null, null, null, null, null, null, null, null],
          gameOver: false,
          isDraw: false,
        ),
      );
      final game3 = testGame.copyWith(
        currentPlayerId: 'user1',
        state: const TicTacToeGameStateEntity(
          board: ['X', 'O', null, null, null, null, null, null, null],
          gameOver: false,
          isDraw: false,
        ),
      );

      final stream = Stream<GameEntity>.fromIterable([game1, game2, game3]);
      when(mockRepository.watchGame(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testGameId);

      // Assert
      await expectLater(
        result,
        emitsInOrder([game1, game2, game3]),
      );
    });

    test('should propagate errors from repository stream', () async {
      // Arrange
      final stream = Stream<GameEntity>.error(Exception('Game not found'));
      when(mockRepository.watchGame(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testGameId);

      // Assert
      await expectLater(result, emitsError(isA<Exception>()));
    });

    test('should handle stream that completes without emitting', () async {
      // Arrange
      final stream = Stream<GameEntity>.empty();
      when(mockRepository.watchGame(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testGameId);

      // Assert
      await expectLater(result, emitsDone);
    });

    test('should pass correct game ID to repository', () {
      // Arrange
      final stream = Stream<GameEntity>.value(testGame);
      when(mockRepository.watchGame(any)).thenAnswer((_) => stream);

      // Act
      usecase(testGameId);

      // Assert
      final captured = verify(mockRepository.watchGame(captureAny)).captured;
      expect(captured[0], testGameId);
    });
  });
}


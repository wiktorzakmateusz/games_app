import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/lobby/domain/entities/lobby_entity.dart';
import 'package:games_app/features/lobby/domain/entities/lobby_player_entity.dart';
import 'package:games_app/features/lobby/domain/repositories/lobby_repository.dart';
import 'package:games_app/features/lobby/domain/usecases/watch_lobby_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'watch_lobby_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([LobbyRepository])
void main() {
  late WatchLobbyUseCase usecase;
  late MockLobbyRepository mockRepository;

  setUp(() {
    mockRepository = MockLobbyRepository();
    usecase = WatchLobbyUseCase(mockRepository);
  });

  const testLobbyId = 'lobby123';
  final testLobby = LobbyEntity(
    id: testLobbyId,
    name: 'Test Lobby',
    ownerId: 'user1',
    gameType: GameType.ticTacToe,
    maxPlayers: 2,
    players: [
      LobbyPlayerEntity(
        userId: 'user1',
        username: 'player1',
        displayName: 'Player One',
        isReady: false,
        joinedAt: DateTime(2024),
      ),
    ],
    status: LobbyStatus.waiting,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  group('WatchLobbyUseCase', () {
    test('should return stream of LobbyEntity from repository', () {
      // Arrange
      final stream = Stream<LobbyEntity>.value(testLobby);
      when(mockRepository.watchLobby(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testLobbyId);

      // Assert
      expect(result, stream);
      verify(mockRepository.watchLobby(testLobbyId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should emit LobbyEntity when lobby updates', () async {
      // Arrange
      final stream = Stream<LobbyEntity>.value(testLobby);
      when(mockRepository.watchLobby(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testLobbyId);

      // Assert
      await expectLater(result, emits(testLobby));
    });

    test('should emit updated lobby when player joins', () async {
      // Arrange
      final updatedLobby = testLobby.copyWith(
        players: [
          ...testLobby.players,
          LobbyPlayerEntity(
            userId: 'user2',
            username: 'player2',
            displayName: 'Player Two',
            isReady: false,
            joinedAt: DateTime(2024),
          ),
        ],
      );
      final stream = Stream<LobbyEntity>.fromIterable([testLobby, updatedLobby]);
      when(mockRepository.watchLobby(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testLobbyId);

      // Assert
      await expectLater(
        result,
        emitsInOrder([testLobby, updatedLobby]),
      );
    });

    test('should emit updated lobby when player toggles ready', () async {
      // Arrange
      final updatedLobby = testLobby.copyWith(
        players: [
          testLobby.players[0].copyWith(isReady: true),
        ],
      );
      final stream = Stream<LobbyEntity>.fromIterable([testLobby, updatedLobby]);
      when(mockRepository.watchLobby(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testLobbyId);

      // Assert
      await expectLater(
        result,
        emitsInOrder([testLobby, updatedLobby]),
      );
    });

    test('should emit updated lobby when game starts', () async {
      // Arrange
      final startedLobby = testLobby.copyWith(
        status: LobbyStatus.inGame,
        gameId: 'game123',
      );
      final stream = Stream<LobbyEntity>.fromIterable([testLobby, startedLobby]);
      when(mockRepository.watchLobby(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testLobbyId);

      // Assert
      await expectLater(
        result,
        emitsInOrder([testLobby, startedLobby]),
      );
    });

    test('should propagate errors from repository stream', () async {
      // Arrange
      final stream = Stream<LobbyEntity>.error(Exception('Lobby not found'));
      when(mockRepository.watchLobby(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testLobbyId);

      // Assert
      await expectLater(result, emitsError(isA<Exception>()));
    });

    test('should handle stream that completes without emitting', () async {
      // Arrange
      final stream = Stream<LobbyEntity>.empty();
      when(mockRepository.watchLobby(any)).thenAnswer((_) => stream);

      // Act
      final result = usecase(testLobbyId);

      // Assert
      await expectLater(result, emitsDone);
    });

    test('should pass correct lobby ID to repository', () {
      // Arrange
      final stream = Stream<LobbyEntity>.value(testLobby);
      when(mockRepository.watchLobby(any)).thenAnswer((_) => stream);

      // Act
      usecase(testLobbyId);

      // Assert
      final captured = verify(mockRepository.watchLobby(captureAny)).captured;
      expect(captured[0], testLobbyId);
    });
  });
}


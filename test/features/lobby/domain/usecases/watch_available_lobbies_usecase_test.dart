import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/lobby/domain/entities/lobby_entity.dart';
import 'package:games_app/features/lobby/domain/entities/lobby_player_entity.dart';
import 'package:games_app/features/lobby/domain/repositories/lobby_repository.dart';
import 'package:games_app/features/lobby/domain/usecases/watch_available_lobbies_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'watch_available_lobbies_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([LobbyRepository])
void main() {
  late WatchAvailableLobbiesUseCase usecase;
  late MockLobbyRepository mockRepository;

  setUp(() {
    mockRepository = MockLobbyRepository();
    usecase = WatchAvailableLobbiesUseCase(mockRepository);
  });

  final testLobby1 = LobbyEntity(
    id: 'lobby1',
    name: 'Test Lobby 1',
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

  final testLobby2 = LobbyEntity(
    id: 'lobby2',
    name: 'Test Lobby 2',
    ownerId: 'user2',
    gameType: GameType.connect4,
    maxPlayers: 2,
    players: [
      LobbyPlayerEntity(
        userId: 'user2',
        username: 'player2',
        displayName: 'Player Two',
        isReady: false,
        joinedAt: DateTime(2024),
      ),
    ],
    status: LobbyStatus.waiting,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  group('WatchAvailableLobbiesUseCase', () {
    test('should return stream of lobby list from repository', () {
      // Arrange
      final stream = Stream<List<LobbyEntity>>.value([testLobby1, testLobby2]);
      when(mockRepository.watchAvailableLobbies()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      expect(result, stream);
      verify(mockRepository.watchAvailableLobbies()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should emit list of lobbies', () async {
      // Arrange
      final stream = Stream<List<LobbyEntity>>.value([testLobby1, testLobby2]);
      when(mockRepository.watchAvailableLobbies()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      await expectLater(result, emits([testLobby1, testLobby2]));
    });

    test('should emit empty list when no lobbies available', () async {
      // Arrange
      final stream = Stream<List<LobbyEntity>>.value([]);
      when(mockRepository.watchAvailableLobbies()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      await expectLater(result, emits([]));
    });

    test('should emit updated list when lobbies change', () async {
      // Arrange
      final stream = Stream<List<LobbyEntity>>.fromIterable([
        [testLobby1],
        [testLobby1, testLobby2],
        [testLobby2],
      ]);
      when(mockRepository.watchAvailableLobbies()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      await expectLater(
        result,
        emitsInOrder([
          [testLobby1],
          [testLobby1, testLobby2],
          [testLobby2],
        ]),
      );
    });

    test('should handle empty stream', () async {
      // Arrange
      final stream = Stream<List<LobbyEntity>>.empty();
      when(mockRepository.watchAvailableLobbies()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      await expectLater(result, emitsDone);
    });

    test('should propagate errors from repository stream', () async {
      // Arrange
      final stream = Stream<List<LobbyEntity>>.error(Exception('Connection error'));
      when(mockRepository.watchAvailableLobbies()).thenAnswer((_) => stream);

      // Act
      final result = usecase();

      // Assert
      await expectLater(result, emitsError(isA<Exception>()));
    });
  });
}


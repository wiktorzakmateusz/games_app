import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/exceptions.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/stats/data/datasources/stats_remote_datasource.dart';
import 'package:games_app/features/stats/data/models/stats_model.dart';
import 'package:games_app/features/stats/data/repositories/stats_repository_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'stats_repository_impl_test.mocks.dart';

@GenerateMocks([StatsRemoteDataSource])
void main() {
  late StatsRepositoryImpl repository;
  late MockStatsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockStatsRemoteDataSource();
    repository = StatsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  const testUserId = 'user123';

  final testStatsModelTicTacToe = StatsModel(
    userId: testUserId,
    gameType: GameType.ticTacToe,
    wins: 10,
    losses: 5,
    draws: 3,
    played: 18,
    totalGames: 18,
    winRate: 0.555,
  );

  final testStatsModelConnect4 = StatsModel(
    userId: testUserId,
    gameType: GameType.connect4,
    wins: 7,
    losses: 8,
    draws: 2,
    played: 17,
    totalGames: 17,
    winRate: 0.412,
  );

  final testAggregateStatsModel = AggregateStatsModel(
    userId: testUserId,
    totalWins: 20,
    totalLosses: 15,
    totalDraws: 8,
    totalPlayed: 43,
    overallWinRate: 0.465,
  );

  group('getUserStats', () {
    test('should return list of StatsEntity when successful', () async {
      // Arrange
      when(mockRemoteDataSource.getUserStats(any))
          .thenAnswer((_) async => [
                testStatsModelTicTacToe,
                testStatsModelConnect4,
              ]);

      // Act
      final result = await repository.getUserStats(testUserId);

      // Assert
      expect(result.isRight(), true);
      final statsList = result.getOrElse(() => throw Exception());
      expect(statsList.length, 2);
      expect(statsList[0].gameType, GameType.ticTacToe);
      expect(statsList[0].wins, 10);
      expect(statsList[1].gameType, GameType.connect4);
      expect(statsList[1].wins, 7);
      verify(mockRemoteDataSource.getUserStats(testUserId)).called(1);
    });

    test('should return empty list when user has no stats', () async {
      // Arrange
      when(mockRemoteDataSource.getUserStats(any))
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getUserStats(testUserId);

      // Assert
      expect(result.isRight(), true);
      final statsList = result.getOrElse(() => throw Exception());
      expect(statsList, isEmpty);
    });

    test('should return ServerFailure when ServerException occurs', () async {
      // Arrange
      when(mockRemoteDataSource.getUserStats(any))
          .thenThrow(ServerException('Failed to fetch stats', 500));

      // Act
      final result = await repository.getUserStats(testUserId);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'Failed to fetch stats');
    });

    test('should return ServerFailure on generic exception', () async {
      // Arrange
      when(mockRemoteDataSource.getUserStats(any))
          .thenThrow(Exception('Network timeout'));

      // Act
      final result = await repository.getUserStats(testUserId);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message,
          contains('Failed to get user stats'));
    });

    test('should handle multiple game types correctly', () async {
      // Arrange
      final allGameTypeStats = [
        StatsModel(
          userId: testUserId,
          gameType: GameType.ticTacToe,
          wins: 5,
          losses: 3,
          draws: 2,
          played: 10,
          totalGames: 10,
          winRate: 0.5,
        ),
        StatsModel(
          userId: testUserId,
          gameType: GameType.connect4,
          wins: 4,
          losses: 4,
          draws: 1,
          played: 9,
          totalGames: 9,
          winRate: 0.444,
        ),
      ];

      when(mockRemoteDataSource.getUserStats(any))
          .thenAnswer((_) async => allGameTypeStats);

      // Act
      final result = await repository.getUserStats(testUserId);

      // Assert
      expect(result.isRight(), true);
      final statsList = result.getOrElse(() => throw Exception());
      expect(statsList.length, 2);
      expect(
        statsList.map((s) => s.gameType).toSet(),
        {GameType.ticTacToe, GameType.connect4},
      );
    });
  });

  group('getUserStatsByGameType', () {
    const testGameType = GameType.ticTacToe;

    test('should return StatsEntity for specific game type', () async {
      // Arrange
      when(mockRemoteDataSource.getUserStatsByGameType(any, any))
          .thenAnswer((_) async => testStatsModelTicTacToe);

      // Act
      final result =
          await repository.getUserStatsByGameType(testUserId, testGameType);

      // Assert
      expect(result.isRight(), true);
      final stats = result.getOrElse(() => throw Exception());
      expect(stats, isNotNull);
      expect(stats!.gameType, GameType.ticTacToe);
      expect(stats.wins, 10);
      expect(stats.losses, 5);
      verify(mockRemoteDataSource.getUserStatsByGameType(
              testUserId, testGameType))
          .called(1);
    });

    test('should return null when user has no stats for game type', () async {
      // Arrange
      when(mockRemoteDataSource.getUserStatsByGameType(any, any))
          .thenAnswer((_) async => null);

      // Act
      final result =
          await repository.getUserStatsByGameType(testUserId, testGameType);

      // Assert
      expect(result.isRight(), true);
      final stats = result.getOrElse(() => throw Exception());
      expect(stats, isNull);
    });

    test('should return ServerFailure when ServerException occurs', () async {
      // Arrange
      when(mockRemoteDataSource.getUserStatsByGameType(any, any))
          .thenThrow(ServerException('User not found', 404));

      // Act
      final result =
          await repository.getUserStatsByGameType(testUserId, testGameType);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'User not found');
    });

    test('should return ServerFailure on generic exception', () async {
      // Arrange
      when(mockRemoteDataSource.getUserStatsByGameType(any, any))
          .thenThrow(Exception('Database error'));

      // Act
      final result =
          await repository.getUserStatsByGameType(testUserId, testGameType);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message,
          contains('Failed to get stats by game type'));
    });

    test('should handle all game types', () async {
      // Arrange & Act & Assert for each game type
      final gameTypeStats = {
        GameType.ticTacToe: testStatsModelTicTacToe,
        GameType.connect4: testStatsModelConnect4,
      };

      for (final entry in gameTypeStats.entries) {
        when(mockRemoteDataSource.getUserStatsByGameType(testUserId, entry.key))
            .thenAnswer((_) async => entry.value);

        final result =
            await repository.getUserStatsByGameType(testUserId, entry.key);

        expect(result.isRight(), true);
        final stats = result.getOrElse(() => throw Exception());
        expect(stats?.gameType, entry.key);
      }
    });
  });

  group('getAggregateStats', () {
    test('should return AggregateStatsEntity when successful', () async {
      // Arrange
      when(mockRemoteDataSource.getAggregateStats(any))
          .thenAnswer((_) async => testAggregateStatsModel);

      // Act
      final result = await repository.getAggregateStats(testUserId);

      // Assert
      expect(result.isRight(), true);
      final stats = result.getOrElse(() => throw Exception());
      expect(stats.userId, testUserId);
      expect(stats.totalWins, 20);
      expect(stats.totalLosses, 15);
      expect(stats.totalDraws, 8);
      expect(stats.totalPlayed, 43);
      expect(stats.overallWinRate, 0.465);
      verify(mockRemoteDataSource.getAggregateStats(testUserId)).called(1);
    });

    test('should handle user with zero games played', () async {
      // Arrange
      final zeroStatsModel = AggregateStatsModel(
        userId: testUserId,
        totalWins: 0,
        totalLosses: 0,
        totalDraws: 0,
        totalPlayed: 0,
        overallWinRate: 0.0,
      );

      when(mockRemoteDataSource.getAggregateStats(any))
          .thenAnswer((_) async => zeroStatsModel);

      // Act
      final result = await repository.getAggregateStats(testUserId);

      // Assert
      expect(result.isRight(), true);
      final stats = result.getOrElse(() => throw Exception());
      expect(stats.totalPlayed, 0);
      expect(stats.overallWinRate, 0.0);
    });

    test('should return ServerFailure when ServerException occurs', () async {
      // Arrange
      when(mockRemoteDataSource.getAggregateStats(any))
          .thenThrow(ServerException('Database unavailable', 503));

      // Act
      final result = await repository.getAggregateStats(testUserId);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'Database unavailable');
    });

    test('should return ServerFailure on generic exception', () async {
      // Arrange
      when(mockRemoteDataSource.getAggregateStats(any))
          .thenThrow(Exception('Connection failed'));

      // Act
      final result = await repository.getAggregateStats(testUserId);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message,
          contains('Failed to get aggregate stats'));
    });
  });

  group('Integration scenarios', () {
    test('should fetch both detailed and aggregate stats', () async {
      // Arrange
      when(mockRemoteDataSource.getUserStats(any))
          .thenAnswer((_) async => [
                testStatsModelTicTacToe,
                testStatsModelConnect4,
              ]);

      when(mockRemoteDataSource.getAggregateStats(any))
          .thenAnswer((_) async => testAggregateStatsModel);

      // Act
      final detailedResult = await repository.getUserStats(testUserId);
      final aggregateResult = await repository.getAggregateStats(testUserId);

      // Assert
      expect(detailedResult.isRight(), true);
      expect(aggregateResult.isRight(), true);

      final detailedStats = detailedResult.getOrElse(() => throw Exception());
      final aggregateStats =
          aggregateResult.getOrElse(() => throw Exception());

      expect(detailedStats.length, 2);
      expect(aggregateStats.totalPlayed, 43);

      verify(mockRemoteDataSource.getUserStats(testUserId)).called(1);
      verify(mockRemoteDataSource.getAggregateStats(testUserId)).called(1);
    });

    test('should handle fetching stats for multiple game types sequentially',
        () async {
      // Arrange
      when(mockRemoteDataSource.getUserStatsByGameType(any, GameType.ticTacToe))
          .thenAnswer((_) async => testStatsModelTicTacToe);

      when(mockRemoteDataSource.getUserStatsByGameType(any, GameType.connect4))
          .thenAnswer((_) async => testStatsModelConnect4);

      // Act
      final ticTacToeResult = await repository.getUserStatsByGameType(
        testUserId,
        GameType.ticTacToe,
      );
      final connect4Result = await repository.getUserStatsByGameType(
        testUserId,
        GameType.connect4,
      );

      // Assert
      expect(ticTacToeResult.isRight(), true);
      expect(connect4Result.isRight(), true);

      final ticTacToeStats =
          ticTacToeResult.getOrElse(() => throw Exception());
      final connect4Stats = connect4Result.getOrElse(() => throw Exception());

      expect(ticTacToeStats?.wins, 10);
      expect(connect4Stats?.wins, 7);
    });

    test('should verify stats consistency', () async {
      // Arrange - Stats from detailed call
      final stats1 = StatsModel(
        userId: testUserId,
        gameType: GameType.ticTacToe,
        wins: 10,
        losses: 5,
        draws: 3,
        played: 18,
        totalGames: 18,
        winRate: 0.555,
      );

      final stats2 = StatsModel(
        userId: testUserId,
        gameType: GameType.connect4,
        wins: 10,
        losses: 10,
        draws: 5,
        played: 25,
        totalGames: 25,
        winRate: 0.4,
      );

      // Arrange - Aggregate stats
      final aggregateStats = AggregateStatsModel(
        userId: testUserId,
        totalWins: 20, // 10 + 10
        totalLosses: 15, // 5 + 10
        totalDraws: 8, // 3 + 5
        totalPlayed: 43, // 18 + 25
        overallWinRate: 0.465,
      );

      when(mockRemoteDataSource.getUserStats(any))
          .thenAnswer((_) async => [stats1, stats2]);

      when(mockRemoteDataSource.getAggregateStats(any))
          .thenAnswer((_) async => aggregateStats);

      // Act
      final detailedResult = await repository.getUserStats(testUserId);
      final aggregateResult = await repository.getAggregateStats(testUserId);

      // Assert
      expect(detailedResult.isRight(), true);
      expect(aggregateResult.isRight(), true);

      final detailed = detailedResult.getOrElse(() => throw Exception());
      final aggregate = aggregateResult.getOrElse(() => throw Exception());

      // Verify totals match
      final totalWins = detailed.fold(0, (sum, stat) => sum + stat.wins);
      final totalLosses = detailed.fold(0, (sum, stat) => sum + stat.losses);

      expect(totalWins, aggregate.totalWins);
      expect(totalLosses, aggregate.totalLosses);
    });
  });
}


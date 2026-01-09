import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/stats/domain/entities/stats_entity.dart';
import 'package:games_app/features/stats/domain/usecases/get_aggregate_stats_usecase.dart';
import 'package:games_app/features/stats/domain/usecases/get_stats_by_game_type_usecase.dart';
import 'package:games_app/features/stats/domain/usecases/get_user_stats_usecase.dart';
import 'package:games_app/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:games_app/features/stats/presentation/cubit/stats_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'stats_cubit_test.mocks.dart';

@GenerateMocks([
  GetUserStatsUseCase,
  GetAggregateStatsUseCase,
  GetStatsByGameTypeUseCase,
])
void main() {
  late StatsCubit cubit;
  late MockGetUserStatsUseCase mockGetUserStatsUseCase;
  late MockGetAggregateStatsUseCase mockGetAggregateStatsUseCase;
  late MockGetStatsByGameTypeUseCase mockGetStatsByGameTypeUseCase;

  const testUserId = 'user123';

  final testTicTacToeStats = const StatsEntity(
    userId: testUserId,
    gameType: GameType.ticTacToe,
    wins: 10,
    losses: 5,
    draws: 2,
    played: 17,
    totalGames: 17,
    winRate: 0.588,
  );

  final testConnect4Stats = const StatsEntity(
    userId: testUserId,
    gameType: GameType.connect4,
    wins: 8,
    losses: 7,
    draws: 1,
    played: 16,
    totalGames: 16,
    winRate: 0.5,
  );

  final testAggregateStats = const AggregateStatsEntity(
    userId: testUserId,
    totalWins: 23,
    totalLosses: 15,
    totalDraws: 3,
    totalPlayed: 41,
    overallWinRate: 0.561,
  );

  setUp(() {
    mockGetUserStatsUseCase = MockGetUserStatsUseCase();
    mockGetAggregateStatsUseCase = MockGetAggregateStatsUseCase();
    mockGetStatsByGameTypeUseCase = MockGetStatsByGameTypeUseCase();

    cubit = StatsCubit(
      getUserStatsUseCase: mockGetUserStatsUseCase,
      getAggregateStatsUseCase: mockGetAggregateStatsUseCase,
      getStatsByGameTypeUseCase: mockGetStatsByGameTypeUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('Load User Stats Flow', () {
    blocTest<StatsCubit, StatsState>(
      'emits [StatsLoading, StatsLoaded] when loading stats with aggregate',
      build: () {
        when(mockGetUserStatsUseCase(any)).thenAnswer(
          (_) async => Right([
            testTicTacToeStats,
            testConnect4Stats,
          ]),
        );
        when(mockGetAggregateStatsUseCase(any)).thenAnswer(
          (_) async => Right(testAggregateStats),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadUserStats(testUserId),
      expect: () => [
        StatsLoading(),
        StatsLoaded(
          stats: [
            testTicTacToeStats,
            testConnect4Stats,
          ],
          aggregateStats: testAggregateStats,
        ),
      ],
      verify: (_) {
        verify(mockGetUserStatsUseCase(testUserId)).called(1);
        verify(mockGetAggregateStatsUseCase(testUserId)).called(1);
      },
    );

    blocTest<StatsCubit, StatsState>(
      'emits [StatsLoading, StatsLoaded] without aggregate when flag is false',
      build: () {
        when(mockGetUserStatsUseCase(any)).thenAnswer(
          (_) async => Right([testTicTacToeStats]),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadUserStats(testUserId, includeAggregate: false),
      expect: () => [
        StatsLoading(),
        StatsLoaded(stats: [testTicTacToeStats]),
      ],
      verify: (_) {
        verify(mockGetUserStatsUseCase(testUserId)).called(1);
        verifyNever(mockGetAggregateStatsUseCase(any));
      },
    );

    blocTest<StatsCubit, StatsState>(
      'emits [StatsLoading, StatsError] when loading stats fails',
      build: () {
        when(mockGetUserStatsUseCase(any)).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to load stats')),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadUserStats(testUserId),
      expect: () => [
        StatsLoading(),
        const StatsError('Failed to load stats'),
      ],
      verify: (_) {
        verify(mockGetUserStatsUseCase(testUserId)).called(1);
        verifyNever(mockGetAggregateStatsUseCase(any));
      },
    );

    blocTest<StatsCubit, StatsState>(
      'loads stats without aggregate when aggregate fetch fails',
      build: () {
        when(mockGetUserStatsUseCase(any)).thenAnswer(
          (_) async => Right([testTicTacToeStats]),
        );
        when(mockGetAggregateStatsUseCase(any)).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to load aggregate')),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadUserStats(testUserId),
      expect: () => [
        StatsLoading(),
        StatsLoaded(stats: [testTicTacToeStats]),
      ],
      verify: (_) {
        verify(mockGetUserStatsUseCase(testUserId)).called(1);
        verify(mockGetAggregateStatsUseCase(testUserId)).called(1);
      },
    );

    blocTest<StatsCubit, StatsState>(
      'handles empty stats list',
      build: () {
        when(mockGetUserStatsUseCase(any)).thenAnswer(
          (_) async => const Right([]),
        );
        when(mockGetAggregateStatsUseCase(any)).thenAnswer(
          (_) async => Right(testAggregateStats.copyWith(
            totalWins: 0,
            totalLosses: 0,
            totalDraws: 0,
            totalPlayed: 0,
            overallWinRate: 0.0,
          )),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadUserStats(testUserId),
      expect: () => [
        StatsLoading(),
        StatsLoaded(
          stats: const [],
          aggregateStats: testAggregateStats.copyWith(
            totalWins: 0,
            totalLosses: 0,
            totalDraws: 0,
            totalPlayed: 0,
            overallWinRate: 0.0,
          ),
        ),
      ],
    );
  });

  group('Load Aggregate Stats Flow', () {
    blocTest<StatsCubit, StatsState>(
      'emits [StatsLoading, StatsLoaded] when loading aggregate succeeds',
      build: () {
        when(mockGetAggregateStatsUseCase(any)).thenAnswer(
          (_) async => Right(testAggregateStats),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadAggregateStats(testUserId),
      expect: () => [
        StatsLoading(),
        StatsLoaded(
          stats: const [],
          aggregateStats: testAggregateStats,
        ),
      ],
      verify: (_) {
        verify(mockGetAggregateStatsUseCase(testUserId)).called(1);
        verifyNever(mockGetUserStatsUseCase(any));
      },
    );

    blocTest<StatsCubit, StatsState>(
      'emits [StatsLoading, StatsError] when loading aggregate fails',
      build: () {
        when(mockGetAggregateStatsUseCase(any)).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to load aggregate stats')),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadAggregateStats(testUserId),
      expect: () => [
        StatsLoading(),
        const StatsError('Failed to load aggregate stats'),
      ],
      verify: (_) {
        verify(mockGetAggregateStatsUseCase(testUserId)).called(1);
      },
    );

    blocTest<StatsCubit, StatsState>(
      'handles network failure for aggregate stats',
      build: () {
        when(mockGetAggregateStatsUseCase(any)).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection')),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadAggregateStats(testUserId),
      expect: () => [
        StatsLoading(),
        const StatsError('No internet connection'),
      ],
    );
  });

  group('Stats Calculation Verification', () {
    blocTest<StatsCubit, StatsState>(
      'verifies win rate calculation matches total wins and games',
      build: () {
        const statsWithPerfectWinRate = StatsEntity(
          userId: testUserId,
          gameType: GameType.ticTacToe,
          wins: 10,
          losses: 0,
          draws: 0,
          played: 10,
          totalGames: 10,
          winRate: 1.0,
        );
        when(mockGetUserStatsUseCase(any)).thenAnswer(
          (_) async => const Right([statsWithPerfectWinRate]),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadUserStats(testUserId, includeAggregate: false),
      expect: () => [
        StatsLoading(),
        const StatsLoaded(stats: [
          StatsEntity(
            userId: testUserId,
            gameType: GameType.ticTacToe,
            wins: 10,
            losses: 0,
            draws: 0,
            played: 10,
            totalGames: 10,
            winRate: 1.0,
          ),
        ]),
      ],
      verify: (_) {
        final state = cubit.state as StatsLoaded;
        expect(state.stats[0].winRate, 1.0);
        expect(state.stats[0].wins, state.stats[0].totalGames);
      },
    );

    blocTest<StatsCubit, StatsState>(
      'verifies stats consistency (wins + losses + draws = total)',
      build: () {
        when(mockGetUserStatsUseCase(any)).thenAnswer(
          (_) async => Right([testTicTacToeStats]),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadUserStats(testUserId, includeAggregate: false),
      expect: () => [
        StatsLoading(),
        StatsLoaded(stats: [testTicTacToeStats]),
      ],
      verify: (_) {
        final state = cubit.state as StatsLoaded;
        final stats = state.stats[0];
        expect(stats.wins + stats.losses + stats.draws, stats.totalGames);
      },
    );
  });

  group('Game Type Specific Stats', () {
    blocTest<StatsCubit, StatsState>(
      'loads stats for all game types',
      build: () {
        when(mockGetUserStatsUseCase(any)).thenAnswer(
          (_) async => Right([
            testTicTacToeStats,
            testConnect4Stats,
          ]),
        );
        when(mockGetAggregateStatsUseCase(any)).thenAnswer(
          (_) async => Right(testAggregateStats),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadUserStats(testUserId),
      expect: () => [
        StatsLoading(),
        StatsLoaded(
          stats: [
            testTicTacToeStats,
            testConnect4Stats,
          ],
          aggregateStats: testAggregateStats,
        ),
      ],
      verify: (_) {
        final state = cubit.state as StatsLoaded;
        expect(state.stats.length, 2);
        expect(
          state.stats.map((s) => s.gameType).toSet(),
          {GameType.ticTacToe, GameType.connect4},
        );
      },
    );

    blocTest<StatsCubit, StatsState>(
      'handles stats for only one game type',
      build: () {
        when(mockGetUserStatsUseCase(any)).thenAnswer(
          (_) async => Right([testTicTacToeStats]),
        );
        when(mockGetAggregateStatsUseCase(any)).thenAnswer(
          (_) async => const Right(AggregateStatsEntity(
            userId: testUserId,
            totalWins: 10,
            totalLosses: 5,
            totalDraws: 2,
            totalPlayed: 17,
            overallWinRate: 0.588,
          )),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadUserStats(testUserId),
      expect: () => [
        StatsLoading(),
        predicate<StatsLoaded>((state) {
          return state.stats.length == 1 &&
              state.stats[0].gameType == GameType.ticTacToe &&
              state.aggregateStats != null;
        }),
      ],
    );
  });

  group('Complete Stats Journey', () {
    test('load stats -> verify data -> reload stats', () async {
      // Initial load
      when(mockGetUserStatsUseCase(any)).thenAnswer(
        (_) async => Right([testTicTacToeStats]),
      );
      when(mockGetAggregateStatsUseCase(any)).thenAnswer(
        (_) async => Right(testAggregateStats),
      );

      await cubit.loadUserStats(testUserId);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, isA<StatsLoaded>());
      expect((cubit.state as StatsLoaded).stats.length, 1);
      expect((cubit.state as StatsLoaded).stats[0].gameType, GameType.ticTacToe);
      expect((cubit.state as StatsLoaded).aggregateStats, isNotNull);

      // User plays more games - stats update
      final updatedStats = testTicTacToeStats.copyWith(
        wins: testTicTacToeStats.wins + 1,
        played: testTicTacToeStats.played + 1,
        totalGames: testTicTacToeStats.totalGames + 1,
        winRate: (testTicTacToeStats.wins + 1) /
            (testTicTacToeStats.totalGames + 1),
      );

      final updatedAggregate = testAggregateStats.copyWith(
        totalWins: testAggregateStats.totalWins + 1,
        totalPlayed: testAggregateStats.totalPlayed + 1,
      );

      when(mockGetUserStatsUseCase(any)).thenAnswer(
        (_) async => Right([updatedStats]),
      );
      when(mockGetAggregateStatsUseCase(any)).thenAnswer(
        (_) async => Right(updatedAggregate),
      );

      // Reload stats
      await cubit.loadUserStats(testUserId);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, isA<StatsLoaded>());
      final finalState = cubit.state as StatsLoaded;
      expect(finalState.stats[0].wins, testTicTacToeStats.wins + 1);
      expect(finalState.stats[0].totalGames, testTicTacToeStats.totalGames + 1);
      expect(finalState.aggregateStats!.totalWins, testAggregateStats.totalWins + 1);

      verify(mockGetUserStatsUseCase(testUserId)).called(2);
      verify(mockGetAggregateStatsUseCase(testUserId)).called(2);
    });

    test('load aggregate only -> then load full stats', () async {
      // First load only aggregate
      when(mockGetAggregateStatsUseCase(any)).thenAnswer(
        (_) async => Right(testAggregateStats),
      );

      await cubit.loadAggregateStats(testUserId);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, isA<StatsLoaded>());
      expect((cubit.state as StatsLoaded).stats, isEmpty);
      expect((cubit.state as StatsLoaded).aggregateStats, testAggregateStats);

      // Then load full stats
      when(mockGetUserStatsUseCase(any)).thenAnswer(
        (_) async => Right([
          testTicTacToeStats,
          testConnect4Stats,
        ]),
      );
      when(mockGetAggregateStatsUseCase(any)).thenAnswer(
        (_) async => Right(testAggregateStats),
      );

      await cubit.loadUserStats(testUserId);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, isA<StatsLoaded>());
      final finalState = cubit.state as StatsLoaded;
      expect(finalState.stats.length, 2);
      expect(finalState.aggregateStats, testAggregateStats);

      verify(mockGetAggregateStatsUseCase(testUserId)).called(2);
      verify(mockGetUserStatsUseCase(testUserId)).called(1);
    });
  });
}

extension on StatsEntity {
  StatsEntity copyWith({
    String? userId,
    GameType? gameType,
    int? wins,
    int? losses,
    int? draws,
    int? played,
    int? totalGames,
    double? winRate,
  }) {
    return StatsEntity(
      userId: userId ?? this.userId,
      gameType: gameType ?? this.gameType,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      played: played ?? this.played,
      totalGames: totalGames ?? this.totalGames,
      winRate: winRate ?? this.winRate,
    );
  }
}

extension on AggregateStatsEntity {
  AggregateStatsEntity copyWith({
    String? userId,
    int? totalWins,
    int? totalLosses,
    int? totalDraws,
    int? totalPlayed,
    double? overallWinRate,
  }) {
    return AggregateStatsEntity(
      userId: userId ?? this.userId,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      totalDraws: totalDraws ?? this.totalDraws,
      totalPlayed: totalPlayed ?? this.totalPlayed,
      overallWinRate: overallWinRate ?? this.overallWinRate,
    );
  }
}


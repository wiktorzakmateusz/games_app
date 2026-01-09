import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/stats/domain/entities/stats_entity.dart';
import 'package:games_app/features/stats/domain/repositories/stats_repository.dart';
import 'package:games_app/features/stats/domain/usecases/get_stats_by_game_type_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_stats_by_game_type_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([StatsRepository])
void main() {
  late GetStatsByGameTypeUseCase usecase;
  late MockStatsRepository mockRepository;

  setUp(() {
    mockRepository = MockStatsRepository();
    usecase = GetStatsByGameTypeUseCase(mockRepository);
  });

  const testUserId = 'user123';
  const testGameType = GameType.ticTacToe;
  const testStats = StatsEntity(
    userId: testUserId,
    gameType: testGameType,
    wins: 10,
    losses: 5,
    draws: 2,
    played: 17,
    totalGames: 17,
    winRate: 0.588,
  );

  group('GetStatsByGameTypeUseCase', () {
    test('should return StatsEntity when retrieval succeeds', () async {
      // Arrange
      when(mockRepository.getUserStatsByGameType(any, any))
          .thenAnswer((_) async => const Right(testStats));

      // Act
      final result = await usecase(testUserId, testGameType);

      // Assert
      expect(result, const Right(testStats));
      verify(mockRepository.getUserStatsByGameType(testUserId, testGameType)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return null when user has no stats for game type', () async {
      // Arrange
      when(mockRepository.getUserStatsByGameType(any, any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(testUserId, testGameType);

      // Assert
      expect(result, const Right<Failure, StatsEntity?>(null));
    });

    test('should return stats for different game types', () async {
      // Arrange
      const connect4Stats = StatsEntity(
        userId: testUserId,
        gameType: GameType.connect4,
        wins: 8,
        losses: 7,
        draws: 1,
        played: 16,
        totalGames: 16,
        winRate: 0.5,
      );
      when(mockRepository.getUserStatsByGameType(any, any))
          .thenAnswer((_) async => const Right(connect4Stats));

      // Act
      final result = await usecase(testUserId, GameType.connect4);

      // Assert
      expect(result, const Right(connect4Stats));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Failed to get stats');
      when(mockRepository.getUserStatsByGameType(any, any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testUserId, testGameType);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.getUserStatsByGameType(any, any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testUserId, testGameType);

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      when(mockRepository.getUserStatsByGameType(any, any))
          .thenAnswer((_) async => const Right(testStats));

      // Act
      await usecase(testUserId, testGameType);

      // Assert
      final captured = verify(mockRepository.getUserStatsByGameType(
        captureAny,
        captureAny,
      )).captured;

      expect(captured[0], testUserId);
      expect(captured[1], testGameType);
    });
  });
}


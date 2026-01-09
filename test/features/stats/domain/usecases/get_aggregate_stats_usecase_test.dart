import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/stats/domain/entities/stats_entity.dart';
import 'package:games_app/features/stats/domain/repositories/stats_repository.dart';
import 'package:games_app/features/stats/domain/usecases/get_aggregate_stats_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_aggregate_stats_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([StatsRepository])
void main() {
  late GetAggregateStatsUseCase usecase;
  late MockStatsRepository mockRepository;

  setUp(() {
    mockRepository = MockStatsRepository();
    usecase = GetAggregateStatsUseCase(mockRepository);
  });

  const testUserId = 'user123';
  const testAggregateStats = AggregateStatsEntity(
    userId: testUserId,
    totalWins: 18,
    totalLosses: 12,
    totalDraws: 3,
    totalPlayed: 33,
    overallWinRate: 0.545,
  );

  group('GetAggregateStatsUseCase', () {
    test('should return AggregateStatsEntity when retrieval succeeds', () async {
      // Arrange
      when(mockRepository.getAggregateStats(any))
          .thenAnswer((_) async => const Right(testAggregateStats));

      // Act
      final result = await usecase(testUserId);

      // Assert
      expect(result, const Right(testAggregateStats));
      verify(mockRepository.getAggregateStats(testUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return aggregate stats with zero values for new user', () async {
      // Arrange
      const newUserStats = AggregateStatsEntity(
        userId: testUserId,
        totalWins: 0,
        totalLosses: 0,
        totalDraws: 0,
        totalPlayed: 0,
        overallWinRate: 0.0,
      );
      when(mockRepository.getAggregateStats(any))
          .thenAnswer((_) async => const Right(newUserStats));

      // Act
      final result = await usecase(testUserId);

      // Assert
      expect(result, const Right(newUserStats));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Failed to get aggregate stats');
      when(mockRepository.getAggregateStats(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testUserId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.getAggregateStats(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testUserId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct user ID to repository', () async {
      // Arrange
      when(mockRepository.getAggregateStats(any))
          .thenAnswer((_) async => const Right(testAggregateStats));

      // Act
      await usecase(testUserId);

      // Assert
      final captured = verify(mockRepository.getAggregateStats(captureAny)).captured;
      expect(captured[0], testUserId);
    });
  });
}


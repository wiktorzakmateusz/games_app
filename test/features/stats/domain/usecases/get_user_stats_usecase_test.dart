import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/shared/enums.dart';
import 'package:games_app/features/stats/domain/entities/stats_entity.dart';
import 'package:games_app/features/stats/domain/repositories/stats_repository.dart';
import 'package:games_app/features/stats/domain/usecases/get_user_stats_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_user_stats_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([StatsRepository])
void main() {
  late GetUserStatsUseCase usecase;
  late MockStatsRepository mockRepository;

  setUp(() {
    mockRepository = MockStatsRepository();
    usecase = GetUserStatsUseCase(mockRepository);
  });

  const testUserId = 'user123';
  final testStats = [
    const StatsEntity(
      userId: testUserId,
      gameType: GameType.ticTacToe,
      wins: 10,
      losses: 5,
      draws: 2,
      played: 17,
      totalGames: 17,
      winRate: 0.588,
    ),
    const StatsEntity(
      userId: testUserId,
      gameType: GameType.connect4,
      wins: 8,
      losses: 7,
      draws: 1,
      played: 16,
      totalGames: 16,
      winRate: 0.5,
    ),
  ];

  group('GetUserStatsUseCase', () {
    test('should return list of StatsEntity when retrieval succeeds', () async {
      // Arrange
      when(mockRepository.getUserStats(any))
          .thenAnswer((_) async => Right(testStats));

      // Act
      final result = await usecase(testUserId);

      // Assert
      expect(result, Right(testStats));
      verify(mockRepository.getUserStats(testUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when user has no stats', () async {
      // Arrange
      when(mockRepository.getUserStats(any))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await usecase(testUserId);

      // Assert
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (stats) => expect(stats, isEmpty),
      );
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const failure = ServerFailure('Failed to get stats');
      when(mockRepository.getUserStats(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testUserId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.getUserStats(any))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testUserId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should pass correct user ID to repository', () async {
      // Arrange
      when(mockRepository.getUserStats(any))
          .thenAnswer((_) async => Right(testStats));

      // Act
      await usecase(testUserId);

      // Assert
      final captured = verify(mockRepository.getUserStats(captureAny)).captured;
      expect(captured[0], testUserId);
    });
  });
}


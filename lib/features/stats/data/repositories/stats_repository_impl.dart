import 'package:dartz/dartz.dart';
import 'package:games_app/core/error/exceptions.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/utils/result.dart';
import '../../domain/entities/stats_entity.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_remote_datasource.dart';
import '../../../../core/shared/enums.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsRemoteDataSource remoteDataSource;

  StatsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Result<List<StatsEntity>>> getUserStats(String userId) async {
    try {
      final stats = await remoteDataSource.getUserStats(userId);
      return Right(stats.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get user stats: ${e.toString()}'));
    }
  }

  @override
  Future<Result<StatsEntity?>> getUserStatsByGameType(
    String userId,
    GameType gameType,
  ) async {
    try {
      final stats = await remoteDataSource.getUserStatsByGameType(
        userId,
        gameType,
      );
      return Right(stats?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          'Failed to get stats by game type: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<AggregateStatsEntity>> getAggregateStats(String userId) async {
    try {
      final stats = await remoteDataSource.getAggregateStats(userId);
      return Right(stats.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to get aggregate stats: ${e.toString()}'),
      );
    }
  }
}


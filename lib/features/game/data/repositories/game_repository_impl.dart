import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_firestore_datasource.dart';
import '../datasources/game_remote_datasource.dart';
import '../models/game_model.dart';

class GameRepositoryImpl implements GameRepository {
  final GameRemoteDataSource remoteDataSource;
  final GameFirestoreDataSource firestoreDataSource;

  GameRepositoryImpl({
    required this.remoteDataSource,
    required this.firestoreDataSource,
  });

  @override
  Stream<GameEntity> watchGame(String gameId) {
    try {
      return firestoreDataSource.watchGame(gameId).map((json) {
        final model = GameModel.fromJson(json);
        return model.toEntity();
      });
    } catch (e) {
      throw FirestoreFailure('Failed to watch game: $e');
    }
  }

  @override
  Future<Result<GameEntity>> startGame(String lobbyId) async {
    try {
      final json = await remoteDataSource.startGame(lobbyId);
      final model = GameModel.fromJson(json);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to start game: $e'));
    }
  }

  @override
  Future<Result<void>> makeMove({
    required String gameId,
    required int position,
  }) async {
    try {
      await remoteDataSource.makeMove(gameId: gameId, position: position);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to make move: $e'));
    }
  }

  @override
  Future<Result<void>> abandonGame(String gameId) async {
    try {
      await remoteDataSource.abandonGame(gameId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to abandon game: $e'));
    }
  }

  @override
  Future<Result<GameEntity>> getGame(String gameId) async {
    try {
      final json = await remoteDataSource.getGame(gameId);
      final model = GameModel.fromJson(json);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get game: $e'));
    }
  }
}


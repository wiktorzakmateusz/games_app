import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/shared/enums.dart';
import '../../domain/entities/lobby_entity.dart';
import '../../domain/repositories/lobby_repository.dart';
import '../datasources/lobby_firestore_datasource.dart';
import '../datasources/lobby_remote_datasource.dart';
import '../models/lobby_model.dart';

class LobbyRepositoryImpl implements LobbyRepository {
  final LobbyRemoteDataSource remoteDataSource;
  final LobbyFirestoreDataSource firestoreDataSource;

  LobbyRepositoryImpl({
    required this.remoteDataSource,
    required this.firestoreDataSource,
  });

  @override
  Stream<List<LobbyEntity>> watchAvailableLobbies() {
    try {
      return firestoreDataSource.watchAvailableLobbies().map((jsonList) {
        return jsonList.map((json) {
          final model = LobbyModel.fromJson(json);
          return model.toEntity();
        }).toList();
      });
    } catch (e) {
      throw FirestoreFailure('Failed to watch lobbies: $e');
    }
  }

  @override
  Stream<LobbyEntity> watchLobby(String lobbyId) {
    try {
      return firestoreDataSource.watchLobby(lobbyId).map((json) {
        final model = LobbyModel.fromJson(json);
        return model.toEntity();
      });
    } catch (e) {
      throw FirestoreFailure('Failed to watch lobby: $e');
    }
  }

  @override
  Future<Result<LobbyEntity>> createLobby({
    required String name,
    required GameType gameType,
    required int maxPlayers,
  }) async {
    try {
      final json = await remoteDataSource.createLobby(
        name: name,
        gameType: gameType,
        maxPlayers: maxPlayers,
      );
      final model = LobbyModel.fromJson(json);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to create lobby: $e'));
    }
  }

  @override
  Future<Result<void>> joinLobby(String lobbyId) async {
    try {
      await remoteDataSource.joinLobby(lobbyId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to join lobby: $e'));
    }
  }

  @override
  Future<Result<void>> leaveLobby(String lobbyId) async {
    try {
      await remoteDataSource.leaveLobby(lobbyId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to leave lobby: $e'));
    }
  }

  @override
  Future<Result<void>> toggleReady(String lobbyId) async {
    try {
      await remoteDataSource.toggleReady(lobbyId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to toggle ready: $e'));
    }
  }

  @override
  Future<Result<LobbyEntity>> getLobby(String lobbyId) async {
    try {
      final json = await remoteDataSource.getLobby(lobbyId);
      final model = LobbyModel.fromJson(json);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get lobby: $e'));
    }
  }

  @override
  Future<Result<LobbyEntity?>> getCurrentUserLobby() async {
    try {
      final json = await remoteDataSource.getCurrentUserLobby();
      if (json == null) return const Right(null);
      
      final model = LobbyModel.fromJson(json);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get current user lobby: $e'));
    }
  }
}


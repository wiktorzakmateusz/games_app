import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/enums.dart';
import '../../domain/usecases/create_lobby_usecase.dart';
import '../../domain/usecases/join_lobby_usecase.dart';
import '../../domain/usecases/watch_available_lobbies_usecase.dart';
import 'lobby_list_state.dart';

class LobbyListCubit extends Cubit<LobbyListState> {
  final WatchAvailableLobbiesUseCase watchAvailableLobbiesUseCase;
  final CreateLobbyUseCase createLobbyUseCase;
  final JoinLobbyUseCase joinLobbyUseCase;

  StreamSubscription? _lobbiesSubscription;

  LobbyListCubit({
    required this.watchAvailableLobbiesUseCase,
    required this.createLobbyUseCase,
    required this.joinLobbyUseCase,
  }) : super(const LobbyListInitial());

  void watchLobbies() {
    emit(const LobbyListLoading());

    _lobbiesSubscription?.cancel();
    _lobbiesSubscription = watchAvailableLobbiesUseCase().listen(
      (lobbies) {
        emit(LobbyListLoaded(lobbies));
      },
      onError: (error) {
        emit(LobbyListError('Failed to load lobbies: $error'));
      },
    );
  }

  Future<void> createLobby({
    required String name,
    required GameType gameType,
    required int maxPlayers,
  }) async {
    final currentState = state;
    if (currentState is! LobbyListLoaded) return;

    emit(currentState.copyWith(isPerformingAction: true));

    final result = await createLobbyUseCase(
      name: name,
      gameType: gameType,
      maxPlayers: maxPlayers,
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(isPerformingAction: false));
        emit(LobbyListError(failure.message));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (state is LobbyListError) {
            emit(currentState);
          }
        });
      },
      (lobby) {
        emit(LobbyCreated(lobby));
      },
    );
  }

  Future<void> joinLobby(String lobbyId) async {
    final currentState = state;
    if (currentState is! LobbyListLoaded) return;

    emit(currentState.copyWith(isPerformingAction: true));

    final result = await joinLobbyUseCase(lobbyId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(isPerformingAction: false));
        emit(LobbyListError(failure.message));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (state is LobbyListError) {
            emit(currentState);
          }
        });
      },
      (_) {
        emit(LobbyJoined(lobbyId));
      },
    );
  }

  void retry() {
    watchLobbies();
  }

  @override
  Future<void> close() {
    _lobbiesSubscription?.cancel();
    return super.close();
  }
}


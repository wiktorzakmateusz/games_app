import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'features/auth/data/datasources/auth_firebase_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/update_user_usecase.dart';
import 'features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

import 'features/game/data/datasources/game_firestore_datasource.dart';
import 'features/game/data/datasources/game_remote_datasource.dart';
import 'features/game/data/repositories/game_repository_impl.dart';
import 'features/game/domain/repositories/game_repository.dart';
import 'features/game/domain/usecases/abandon_game_usecase.dart';
import 'features/game/domain/usecases/make_move_usecase.dart';
import 'features/game/domain/usecases/start_game_usecase.dart';
import 'features/game/domain/usecases/watch_game_usecase.dart';
import 'features/game/presentation/cubit/game_cubit.dart';

import 'features/lobby/data/datasources/lobby_firestore_datasource.dart';
import 'features/lobby/data/datasources/lobby_remote_datasource.dart';
import 'features/lobby/data/repositories/lobby_repository_impl.dart';
import 'features/lobby/domain/repositories/lobby_repository.dart';
import 'features/lobby/domain/usecases/create_lobby_usecase.dart';
import 'features/lobby/domain/usecases/join_lobby_usecase.dart';
import 'features/lobby/domain/usecases/leave_lobby_usecase.dart';
import 'features/lobby/domain/usecases/toggle_ready_usecase.dart';
import 'features/lobby/domain/usecases/watch_available_lobbies_usecase.dart';
import 'features/lobby/domain/usecases/watch_lobby_usecase.dart';
import 'features/lobby/presentation/cubit/lobby_list_cubit.dart';
import 'features/lobby/presentation/cubit/lobby_waiting_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  sl.registerLazySingleton<AuthFirebaseDataSource>(
    () => AuthFirebaseDataSourceImpl(
      firebaseAuth: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      client: sl(),
      getIdToken: () async {
        final firebaseDataSource = sl<AuthFirebaseDataSource>();
        return await firebaseDataSource.getIdToken();
      },
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => WatchAuthStateUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));

  sl.registerFactory(
    () => AuthCubit(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      watchAuthStateUseCase: sl(),
      updateUserUseCase: sl(),
    ),
  );
  
  sl.registerLazySingleton<GameRemoteDataSource>(
    () => GameRemoteDataSourceImpl(
      authDataSource: sl(),
      client: sl(),
    ),
  );

  sl.registerLazySingleton<GameFirestoreDataSource>(
    () => GameFirestoreDataSourceImpl(
      firestore: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(
      remoteDataSource: sl(),
      firestoreDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => WatchGameUseCase(sl()));
  sl.registerLazySingleton(() => MakeMoveUseCase(sl()));
  sl.registerLazySingleton(() => AbandonGameUseCase(sl()));
  sl.registerLazySingleton(() => StartGameUseCase(sl()));

  sl.registerFactory(
    () => GameCubit(
      watchGameUseCase: sl(),
      makeMoveUseCase: sl(),
      abandonGameUseCase: sl(),
    ),
  );

  sl.registerLazySingleton<LobbyRemoteDataSource>(
    () => LobbyRemoteDataSourceImpl(
      authDataSource: sl(),
      client: sl(),
    ),
  );

  sl.registerLazySingleton<LobbyFirestoreDataSource>(
    () => LobbyFirestoreDataSourceImpl(
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<LobbyRepository>(
    () => LobbyRepositoryImpl(
      remoteDataSource: sl(),
      firestoreDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => WatchAvailableLobbiesUseCase(sl()));
  sl.registerLazySingleton(() => WatchLobbyUseCase(sl()));
  sl.registerLazySingleton(() => CreateLobbyUseCase(sl()));
  sl.registerLazySingleton(() => JoinLobbyUseCase(sl()));
  sl.registerLazySingleton(() => LeaveLobbyUseCase(sl()));
  sl.registerLazySingleton(() => ToggleReadyUseCase(sl()));

  sl.registerFactory(
    () => LobbyListCubit(
      watchAvailableLobbiesUseCase: sl(),
      createLobbyUseCase: sl(),
      joinLobbyUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => LobbyWaitingCubit(
      watchLobbyUseCase: sl(),
      leaveLobbyUseCase: sl(),
      toggleReadyUseCase: sl(),
      startGameUseCase: sl(),
    ),
  );
}


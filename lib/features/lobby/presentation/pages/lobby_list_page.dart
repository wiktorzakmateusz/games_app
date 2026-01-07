import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../../../core/shared/enums.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../user/presentation/widgets/user_avatar.dart';
import '../cubit/lobby_list_cubit.dart';
import '../cubit/lobby_list_state.dart';
import '../widgets/lobby_card.dart';

class LobbyListPage extends StatefulWidget {
  const LobbyListPage({super.key});

  @override
  State<LobbyListPage> createState() => _LobbyListPageState();
}

class _LobbyListPageState extends State<LobbyListPage> {
  final _lobbyNameController = TextEditingController();
  GameType _selectedGameType = GameType.ticTacToe;
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        context.read<LobbyListCubit>().watchLobbies();
      }
    }
  }

  @override
  void dispose() {
    _lobbyNameController.dispose();
    super.dispose();
  }

  void _showCreateLobbyDialog() {
    final cubit = context.read<LobbyListCubit>();
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: 400,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.separator.resolveFrom(context),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context);
                          _lobbyNameController.clear();
                        },
                        child: AppText.button('Cancel'),
                      ),
                      AppText.h3('Create Lobby'),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (_lobbyNameController.text.trim().isNotEmpty) {
                            Navigator.pop(context);
                            cubit.createLobby(
                              name: _lobbyNameController.text.trim(),
                              gameType: _selectedGameType,
                              maxPlayers: 2,
                            );
                            _lobbyNameController.clear();
                          }
                        },
                        child: AppText.button('Create'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bodyMediumSemiBold('Lobby Name'),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _lobbyNameController,
                          placeholder: 'Enter lobby name',
                          padding: const EdgeInsets.all(12),
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                          clearButtonMode: OverlayVisibilityMode.editing,
                        ),
                        const SizedBox(height: 24),
                        AppText.bodyMediumSemiBold('Game Type'),
                        const SizedBox(height: 8),
                        CupertinoSegmentedControl<GameType>(
                          children: {
                            for (var gameType in GameType.values)
                              gameType: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: AppText.bodyMedium(gameType.displayName),
                              ),
                          },
                          groupValue: _selectedGameType,
                          onValueChanged: (GameType value) {
                            setState(() {
                              _selectedGameType = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: AppText.h3('Error'),
        content: AppText.bodyLarge(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: AppText.bodyLarge('OK'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState is Unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
        }
      },
      builder: (context, authState) {
        final user = authState is Authenticated ? authState.user : null;
        final currentUserUid = authState is Authenticated ? authState.user.firebaseUid : '';

        if (authState is! Authenticated) {
          return CupertinoPageScaffold(
            navigationBar: const AppNavBar(title: 'Lobbies'),
            child: SafeArea(
              child: Center(
                child: AppText.bodyMedium('Not authenticated'),
              ),
            ),
          );
        }

        return BlocConsumer<LobbyListCubit, LobbyListState>(
          listener: (context, state) {
            if (state is LobbyListError) {
              final currentAuthState = context.read<AuthCubit>().state;
              if (currentAuthState is Authenticated) {
                _showError(state.message);
              }
            } else if (state is LobbyCreated) {
              Navigator.pushReplacementNamed(
                context,
                '/lobby_waiting',
                arguments: {'lobbyId': state.lobby.id},
              );
            } else if (state is LobbyJoined) {
              Navigator.pushReplacementNamed(
                context,
                '/lobby_waiting',
                arguments: {'lobbyId': state.lobbyId},
              );
            }
          },
          builder: (context, state) {
            return CupertinoPageScaffold(
              navigationBar: AppNavBar(
                title: 'Lobbies',
                trailing: user != null
                    ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pushNamed(context, '/user_profile');
                        },
                        child: ClipOval(
                          child: UserAvatar(
                            imageUrl: user.photoURL,
                            size: 32,
                          ),
                        ),
                      )
                    : null,
              ),
              child: SafeArea(
                child: _buildBody(state, currentUserUid),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(LobbyListState state, String currentUserUid) {
    return switch (state) {
      LobbyListInitial() => Center(child: AppText.bodyMedium('Initializing...')),
      LobbyListLoading() => const Center(child: CupertinoActivityIndicator()),
      LobbyListError() => _buildErrorView(state),
      LobbyListLoaded() => _buildLobbiesView(state, currentUserUid),
      _ => const Center(child: CupertinoActivityIndicator()),
    };
  }

  Widget _buildErrorView(LobbyListError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 64,
            color: CupertinoColors.destructiveRed,
          ),
          const SizedBox(height: 16),
          AppText(
            state.message,
            style: const TextStyle(color: CupertinoColors.destructiveRed),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () => context.read<LobbyListCubit>().retry(),
            child: AppText.button('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLobbiesView(LobbyListLoaded state, String currentUserUid) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: !state.isPerformingAction ? _showCreateLobbyDialog : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.add,
                        color: CupertinoColors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      AppText(
                        'Create Lobby',
                        style: TextStyles.button.copyWith(
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.lobbies.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    'No available lobbies',
                    style: TextStyle(
                      fontSize: 18,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    'Create one to get started!',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: state.lobbies.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final lobby = state.lobbies[index];
                final isJoined = lobby.hasPlayer(currentUserUid);

                return LobbyCard(
                  lobby: lobby,
                  isFull: lobby.isFull,
                  isJoined: isJoined,
                  onTap: (!state.isPerformingAction && !lobby.isFull && !isJoined)
                      ? () {
                          context.read<LobbyListCubit>().joinLobby(lobby.id);
                        }
                      : null,
                );
              },
            ),
          ),
        if (state.isPerformingAction)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CupertinoActivityIndicator(),
          ),
      ],
    );
  }
}


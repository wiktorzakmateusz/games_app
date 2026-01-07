import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../../../core/shared/enums.dart';
import '../../../../widgets/game_button.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
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
      context.read<LobbyListCubit>().watchLobbies();
    }
  }

  @override
  void dispose() {
    _lobbyNameController.dispose();
    super.dispose();
  }

  void _showCreateLobbyDialog() {
    // Save the correct context before showing dialog
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
                // Header
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
                // Content
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

  void _handleLogout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: AppText.h3('Logout'),
        content: AppText.bodyLarge('Are you sure you want to logout?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText.button('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
            child: AppText.button('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current user from AuthCubit (assuming it's provided higher in the tree)
    final authState = context.watch<AuthCubit>().state;
    final currentUserUid = authState is Authenticated ? authState.user.firebaseUid : '';

    return BlocConsumer<LobbyListCubit, LobbyListState>(
      listener: (context, state) {
        if (state is LobbyListError) {
          _showError(state.message);
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _handleLogout(context),
                  child: const Icon(CupertinoIcons.square_arrow_right),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: state is LobbyListLoaded && !state.isPerformingAction
                      ? _showCreateLobbyDialog
                      : null,
                  child: const Icon(CupertinoIcons.add),
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: _buildBody(state, currentUserUid),
          ),
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
    if (state.lobbies.isEmpty) {
      return Center(
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
            const SizedBox(height: 24),
            GameButton(
              label: 'Create Lobby',
              onTap: state.isPerformingAction ? null : _showCreateLobbyDialog,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: state.lobbies.length,
            padding: const EdgeInsets.all(16),
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


import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/enums.dart';
import '../../../../services/auth_service.dart';
import '../../../../widgets/game_button.dart';
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
    
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Create Lobby'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: _lobbyNameController,
            placeholder: 'Lobby name',
            padding: const EdgeInsets.all(12),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(dialogContext);
              _lobbyNameController.clear();
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              if (_lobbyNameController.text.trim().isNotEmpty) {
                // Use the cubit we saved earlier
                cubit.createLobby(
                  name: _lobbyNameController.text.trim(),
                  gameType: GameType.ticTacToe,
                  maxPlayers: 2,
                );
              }
              _lobbyNameController.clear();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final currentUserUid = authService.uid ?? '';

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
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Lobbies'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: state is LobbyListLoaded && !state.isPerformingAction
                  ? _showCreateLobbyDialog
                  : null,
              child: const Icon(CupertinoIcons.add),
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
      LobbyListInitial() => const Center(child: Text('Initializing...')),
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
          Text(
            state.message,
            style: const TextStyle(color: CupertinoColors.destructiveRed),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () => context.read<LobbyListCubit>().retry(),
            child: const Text('Retry'),
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
            const Text(
              'No available lobbies',
              style: TextStyle(
                fontSize: 18,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
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


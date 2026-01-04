import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../widgets/game_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/lobby_waiting_cubit.dart';
import '../cubit/lobby_waiting_state.dart';
import '../widgets/empty_slot_widget.dart';
import '../widgets/lobby_player_item.dart';

class LobbyWaitingPage extends StatefulWidget {
  const LobbyWaitingPage({super.key});

  @override
  State<LobbyWaitingPage> createState() => _LobbyWaitingPageState();
}

class _LobbyWaitingPageState extends State<LobbyWaitingPage> {
  String? _lobbyId;
  String? _currentUserId;
  bool _isLoadingUserId = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_lobbyId == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      _lobbyId = args?['lobbyId'] as String?;

      if (_lobbyId != null) {
        context.read<LobbyWaitingCubit>().watchLobby(_lobbyId!);
      }
    }

    if (_currentUserId == null && !_isLoadingUserId) {
      _loadCurrentUserId();
    }
  }

  Future<void> _loadCurrentUserId() async {
    if (_isLoadingUserId) return;

    setState(() {
      _isLoadingUserId = true;
    });

    try {
      // Get user from AuthCubit
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        if (mounted) {
          setState(() {
            _currentUserId = authState.user.id;
            _isLoadingUserId = false;
          });

          context.read<LobbyWaitingCubit>().setCurrentUserId(_currentUserId!);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserId = false;
        });
      }
    }
  }

  Future<void> _leaveLobby() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Leave Lobby?'),
        content: const Text('Are you sure you want to leave this lobby?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<LobbyWaitingCubit>().leaveLobby();
    }
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
    if (_lobbyId == null) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Lobby'),
        ),
        child: const Center(
          child: Text('Lobby ID not provided'),
        ),
      );
    }

    return BlocConsumer<LobbyWaitingCubit, LobbyWaitingState>(
      listener: (context, state) {
        if (state is LobbyWaitingError) {
          _showError(state.message);
        } else if (state is LobbyLeft) {
          Navigator.pushReplacementNamed(context, '/lobby_list');
        } else if (state is GameStarted) {
          Navigator.pushReplacementNamed(
            context,
            '/online_game',
            arguments: {'gameId': state.gameId},
          );
        }
      },
      builder: (context, state) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Lobby'),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: state is LobbyWaitingLoaded && !state.isPerformingAction
                  ? _leaveLobby
                  : null,
              child: const Icon(CupertinoIcons.back),
            ),
          ),
          child: SafeArea(
            child: _buildBody(state),
          ),
        );
      },
    );
  }

  Widget _buildBody(LobbyWaitingState state) {
    return switch (state) {
      LobbyWaitingInitial() => const Center(child: Text('Initializing...')),
      LobbyWaitingLoading() => const Center(child: CupertinoActivityIndicator()),
      LobbyWaitingError() => _buildErrorView(state),
      LobbyWaitingLoaded() => _buildLobbyView(state),
      GameStarting() => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(),
              SizedBox(height: 16),
              Text(
                'Starting game...',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      _ => const Center(child: CupertinoActivityIndicator()),
    };
  }

  Widget _buildErrorView(LobbyWaitingError state) {
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
            onPressed: () => context.read<LobbyWaitingCubit>().retry(),
            child: const Text('Retry'),
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/lobby_list');
            },
            child: const Text('Back to Lobbies'),
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyView(LobbyWaitingLoaded state) {
    final lobby = state.lobby;
    final isOwner = _currentUserId != null && lobby.isOwner(_currentUserId!);
    final currentPlayer = lobby.getPlayer(_currentUserId ?? '');

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        lobby.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${lobby.currentPlayerCount}/${lobby.maxPlayers} Players',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Players',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...lobby.players.map((player) {
                  final isCurrentPlayer = player.userId == _currentUserId;
                  return LobbyPlayerItem(
                    player: player,
                    isCurrentPlayer: isCurrentPlayer,
                  );
                }),
                ...List.generate(
                  lobby.maxPlayers - lobby.currentPlayerCount,
                  (_) => const EmptySlotWidget(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GameButton(
                label: currentPlayer?.isReady == true
                    ? 'Not Ready'
                    : 'Ready',
                onTap: !state.isPerformingAction
                    ? () {
                        context.read<LobbyWaitingCubit>().toggleReady();
                      }
                    : null,
              ),
              if (isOwner && lobby.canStartGame) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: state.isPerformingAction
                        ? null
                        : () {
                            context.read<LobbyWaitingCubit>().startGame();
                          },
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    borderRadius: BorderRadius.circular(12),
                    child: state.isPerformingAction
                        ? const CupertinoActivityIndicator()
                        : const Text(
                            'Start Game',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ] else if (isOwner && !lobby.allPlayersReady) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Waiting for all players to be ready...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}


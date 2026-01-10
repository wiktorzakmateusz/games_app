import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/app_text.dart';
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
        title: AppText.h3('Leave Lobby?'),
        content: AppText.bodyLarge('Are you sure you want to leave this lobby?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: AppText.button('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: AppText.button('Leave'),
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
    if (_lobbyId == null) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: AppText.h2('Lobby'),
        ),
        child: Center(
          child: AppText.bodyLarge('Lobby ID not provided'),
        ),
      );
    }

    return BlocConsumer<LobbyWaitingCubit, LobbyWaitingState>(
      listener: (context, state) {
        if (state is LobbyWaitingError) {
          _showError(state.message);
        } else if (state is LobbyLeft) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/lobby_list',
            (route) => route.settings.name == '/',
          );
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
            middle: AppText.h2('Lobby'),
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
      LobbyWaitingInitial() => Center(child: AppText.bodyLarge('Initializing...')),
      LobbyWaitingLoading() => const Center(child: CupertinoActivityIndicator()),
      LobbyWaitingError() => _buildErrorView(state),
      LobbyWaitingLoaded() => _buildLobbyView(state),
      GameStarting() => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CupertinoActivityIndicator(),
              const SizedBox(height: 16),
              AppText.bodyLarge('Starting game...'),
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
          AppText(
            state.message,
            style: const TextStyle(color: CupertinoColors.destructiveRed),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () => context.read<LobbyWaitingCubit>().retry(),
            child: AppText.button('Retry'),
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/lobby_list',
                (route) => route.settings.name == '/',
              );
            },
            child: AppText.button('Back to Lobbies'),
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
                      AppText.h2(lobby.name),
                      const SizedBox(height: 8),
                      AppText.bodyMedium(
                        '${lobby.currentPlayerCount}/${lobby.maxPlayers} Players',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppText.h3('Players'),
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
              if (!isOwner) ...[
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
              ],
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
                        : AppText.button('Start Game'),
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
                  child: AppText(
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


import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../../../injection_container.dart' as di;
import '../../../../widgets/game_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../lobby/domain/usecases/leave_lobby_usecase.dart';
import '../cubit/game_cubit.dart';
import '../cubit/game_state.dart';
import '../widgets/game_board.dart';
import '../widgets/game_status_header.dart';
import '../widgets/player_info_card.dart';

class OnlineGamePage extends StatefulWidget {
  const OnlineGamePage({super.key});

  @override
  State<OnlineGamePage> createState() => _OnlineGamePageState();
}

class _OnlineGamePageState extends State<OnlineGamePage> {
  String? _gameId;
  String? _lobbyId;
  String? _currentUserId;
  bool _isLoadingUserId = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_gameId == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      _gameId = args?['gameId'] as String?;

      if (_gameId != null) {
        context.read<GameCubit>().watchGame(_gameId!);
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

          // Set user ID in cubit for optimistic updates
          context.read<GameCubit>().setCurrentUserId(_currentUserId!);
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

  Future<void> _abandonGame() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: AppText.h3('Abandon Game?'),
        content: AppText.bodyMedium('Are you sure you want to abandon this game?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: AppText.bodyLarge('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: AppText.bodyLarge('Abandon'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<GameCubit>().abandonGame();
    }
  }

  Future<void> _leaveLobbyAndNavigateBack(String lobbyId) async {
    try {
      final leaveLobbyUseCase = di.sl<LeaveLobbyUseCase>();
      await leaveLobbyUseCase(lobbyId);
    } catch (e) {
      // Silently fail - we'll navigate back anyway
    }

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/lobby_list',
        (route) => route.settings.name == '/',
      );
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: AppText.h3('Error'),
        content: AppText.bodyMedium(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: AppText.bodyMedium('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_gameId == null) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: AppText.h3('Game'),
        ),
        child: Center(
          child: AppText.bodyLarge('Game ID not provided'),
        ),
      );
    }

    return BlocConsumer<GameCubit, GameState>(
      listener: (context, state) {
        if (state is GameLoaded && _lobbyId == null) {
          // Store the lobby ID when game first loads
          _lobbyId = state.game.lobbyId;
        }
        
        if (state is GameError) {
          _showError(state.message);
        } else if (state is GameAbandoned) {
          if (_lobbyId != null) {
            _leaveLobbyAndNavigateBack(_lobbyId!);
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/lobby_list',
              (route) => route.settings.name == '/',
            );
          }
        }
      },
      builder: (context, state) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: AppText.bodyLarge('Tic Tac Toe'),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: state is GameLoaded && !state.isPerformingAction
                  ? _abandonGame
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

  Widget _buildBody(GameState state) {
    return switch (state) {
      GameInitial() => Center(child: AppText.bodyMedium('Initializing...')),
      GameLoading() => const Center(child: CupertinoActivityIndicator()),
      GameError() => _buildErrorView(state),
      GameLoaded() => _buildGameView(state),
      GameAbandoned() => Center(child: AppText.bodyMedium('Game abandoned')),
    };
  }

  Widget _buildErrorView(GameError state) {
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
            style: const TextStyle(
              color: CupertinoColors.destructiveRed,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () => context.read<GameCubit>().retry(),
            child: const Text('Retry'),
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            onPressed: () {
              if (_lobbyId != null) {
                _leaveLobbyAndNavigateBack(_lobbyId!);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/lobby_list',
                  (route) => route.settings.name == '/',
                );
              }
            },
            child: const Text('Back to Lobbies'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(GameLoaded state) {
    final game = state.game;
    final myPlayer = game.players.firstWhere(
      (p) => p.userId == _currentUserId,
      orElse: () => game.players.first,
    );
    final opponent = game.players.firstWhere(
      (p) => p.userId != _currentUserId,
      orElse: () => game.players.last,
    );
    final currentPlayer = game.currentPlayer;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Player info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PlayerInfoCard(
                  player: myPlayer,
                  isCurrentTurn: currentPlayer?.userId == myPlayer.userId,
                ),
                AppText.bodyLargeBold('VS'),
                PlayerInfoCard(
                  player: opponent,
                  isCurrentTurn: currentPlayer?.userId == opponent.userId,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Status
            GameStatusHeader(
              game: game,
              currentUserId: _currentUserId,
            ),
            const SizedBox(height: 24),
            // Game board
            GameBoard(
              game: game,
              currentUserId: _currentUserId,
              isPerformingAction: state.isPerformingAction,
              onCellTap: (position) {
                context.read<GameCubit>().makeMove(position);
              },
            ),
            const SizedBox(height: 24),
            // Actions
            if (game.isOver) ...[
              GameButton(
                label: 'Back to Lobbies',
                onTap: () {
                  _leaveLobbyAndNavigateBack(game.lobbyId);
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


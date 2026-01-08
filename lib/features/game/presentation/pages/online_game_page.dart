import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/app_text.dart';
import 'package:games_app/widgets/game_header.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';
import '../../../../injection_container.dart' as di;
import '../../../../widgets/game_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../lobby/domain/usecases/leave_lobby_usecase.dart';
import '../cubit/game_cubit.dart';
import '../cubit/game_state.dart';
import '../widgets/game_board.dart';
import '../widgets/game_status_header.dart';

class OnlineGamePage extends StatefulWidget {
  const OnlineGamePage({super.key});

  @override
  State<OnlineGamePage> createState() => _OnlineGamePageState();
}

class _OnlineGamePageState extends State<OnlineGamePage> with WidgetsBindingObserver {
  String? _gameId;
  String? _lobbyId;
  String? _currentUserId;
  bool _isLoadingUserId = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.detached) {
      if (mounted && _gameId != null) {
        final gameState = context.read<GameCubit>().state;
        if (gameState is GameLoaded) {
          context.read<GameCubit>().abandonGame();
        }

        if (_lobbyId != null) {
          _leaveLobbySilently(_lobbyId!);
        }
      }
    }
  }

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

  Future<void> _leaveLobbySilently(String lobbyId) async {
    try {
      final leaveLobbyUseCase = di.sl<LeaveLobbyUseCase>();
      await leaveLobbyUseCase(lobbyId);
    } catch (e) {
      // Silently fail - app is closing anyway
    }
  }

  void _navigateToWaitingLobby(String lobbyId) {
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/lobby_waiting',
        arguments: {'lobbyId': lobbyId},
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
        navigationBar: const AppNavBar(title: 'Game'),
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
        final gameTitle = state is GameLoaded 
            ? state.game.gameType.displayName 
            : 'Game';
        
        final canShowAbandonDialog = state is GameLoaded && !state.isPerformingAction;
        
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (canShowAbandonDialog) {
              await _abandonGame();
            }
          },
          child: CupertinoPageScaffold(
            navigationBar: AppNavBar(
              title: gameTitle,
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: canShowAbandonDialog
                    ? _abandonGame
                    : null,
                child: const Icon(
                  CupertinoIcons.back,
                  color: CupertinoColors.activeBlue,
                  size: 26.0,
                ),
              ),
            ),
            child: SafeArea(
              child: _buildBody(state),
            ),
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
                _navigateToWaitingLobby(_lobbyId!);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/lobby_list',
                  (route) => route.settings.name == '/',
                );
              }
            },
            child: const Text('Back to Lobby'),
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
    
    // Determine border colors based on symbols
    final player1BorderColor = myPlayer.symbol == 'X' 
        ? CupertinoColors.systemRed 
        : CupertinoColors.systemBlue;
    final player2BorderColor = opponent.symbol == 'X' 
        ? CupertinoColors.systemRed 
        : CupertinoColors.systemBlue;
    
    final isPlayer1Turn = currentPlayer?.userId == myPlayer.userId;

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              GameHeader(
                player1Name: myPlayer.displayName,
                player1IsBot: false,
                player1BorderColor: player1BorderColor,
                player2Name: opponent.displayName,
                player2IsBot: false,
                player2BorderColor: player2BorderColor,
                isPlayer1Turn: isPlayer1Turn,
                isGameOver: game.isOver,
                shouldRunTimer: !game.isOver,
                timerDuration: const Duration(seconds: 60),
                onTimeout: () {
                  // Handle timeout - could show a message or make a move
                },
              ),
              const SizedBox(height: 24),
              GameStatusHeader(
                game: game,
                currentUserId: _currentUserId,
              ),
              const SizedBox(height: 24),
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
                  label: 'Back to Lobby',
                  onTap: () {
                    _navigateToWaitingLobby(game.lobbyId);
                  },
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


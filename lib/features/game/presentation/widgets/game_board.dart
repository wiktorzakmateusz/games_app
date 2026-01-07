import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/shared/enums.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../../../widgets/local_games/tic_tac_toe/tic_tac_toe_board.dart';
import '../../../../widgets/local_games/connect4/connect4_board.dart';

class GameBoard extends StatefulWidget {
  final GameEntity game;
  final String? currentUserId;
  final bool isPerformingAction;
  final Function(int) onCellTap;

  const GameBoard({
    super.key,
    required this.game,
    required this.currentUserId,
    required this.isPerformingAction,
    required this.onCellTap,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with SingleTickerProviderStateMixin {
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;
  int? _hoverColumn;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate winning line when game ends
    if (widget.game.isOver && !oldWidget.game.isOver) {
      final winningPattern = _getWinningPattern();
      if (winningPattern != null) {
        _lineController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  List<String> _getBoardAsStrings() {
    final state = widget.game.state;
    if (state is TicTacToeGameStateEntity) {
      return state.board.map((symbol) => symbol ?? '').toList();
    } else if (state is Connect4GameStateEntity) {
      return state.board.map((symbol) => symbol ?? '').toList();
    }
    return [];
  }

  List<int>? _getWinningPattern() {
    final state = widget.game.state;
    if (state is TicTacToeGameStateEntity) {
      return state.getWinningPattern();
    } else if (state is Connect4GameStateEntity) {
      return state.getWinningPattern();
    }
    return null;
  }

  String _getCurrentPlayerSymbol() {
    final currentPlayer = widget.game.currentPlayer;
    return currentPlayer?.symbol ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.game.gameType == GameType.connect4) {
      return _buildConnect4Board();
    } else {
      return _buildTicTacToeBoard();
    }
  }

  Widget _buildTicTacToeBoard() {
    final isMyTurn = widget.currentUserId != null && 
        widget.game.isPlayerTurn(widget.currentUserId!);
    final canMakeMove = !widget.game.isOver && 
        isMyTurn && 
        !widget.isPerformingAction;

    return TicTacToeBoard(
      board: _getBoardAsStrings(),
      winningPattern: _getWinningPattern(),
      lineAnimation: _lineAnimation,
      onCellTap: canMakeMove ? widget.onCellTap : (_) {},
    );
  }

  Widget _buildConnect4Board() {
    final state = widget.game.state as Connect4GameStateEntity;
    final isMyTurn = widget.currentUserId != null && 
        widget.game.isPlayerTurn(widget.currentUserId!);
    final canMakeMove = !widget.game.isOver && 
        isMyTurn && 
        !widget.isPerformingAction;

    return Connect4Board(
      board: _getBoardAsStrings(),
      winningPattern: _getWinningPattern(),
      lineAnimation: _lineAnimation,
      currentPlayer: _getCurrentPlayerSymbol(),
      hoverColumn: _hoverColumn,
      onColumnTap: canMakeMove ? widget.onCellTap : (_) {},
      onColumnHover: (col) {
        if (canMakeMove) {
          setState(() {
            _hoverColumn = col;
          });
        }
      },
      onColumnHoverExit: () {
        setState(() {
          _hoverColumn = null;
        });
      },
      canDropInColumn: (col) => !state.isColumnFull(col),
      isGameOver: widget.game.isOver,
    );
  }
}


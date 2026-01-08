import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../../../core/shared/enums.dart';
import '../cubit/lobby_list_cubit.dart';
import '../cubit/lobby_list_state.dart';

class CreateLobbyDialog extends StatefulWidget {
  final BuildContext pageContext;
  final Function(bool) onCreatingStateChanged;

  const CreateLobbyDialog({
    super.key,
    required this.pageContext,
    required this.onCreatingStateChanged,
  });

  @override
  State<CreateLobbyDialog> createState() => _CreateLobbyDialogState();
}

class _CreateLobbyDialogState extends State<CreateLobbyDialog> {
  final _lobbyNameController = TextEditingController();
  GameType _selectedGameType = GameType.ticTacToe;

  @override
  void dispose() {
    _lobbyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = widget.pageContext.read<LobbyListCubit>();
    final modalContext = context;

    return BlocProvider.value(
      value: cubit,
      child: BlocListener<LobbyListCubit, LobbyListState>(
        listener: (context, state) {
          if (state is LobbyCreated) {
            widget.onCreatingStateChanged(false);
            Navigator.pop(modalContext);
            _lobbyNameController.clear();
            // Navigate after modal closes using page context
            Future.microtask(() {
              if (widget.pageContext.mounted) {
                Navigator.pushReplacementNamed(
                  widget.pageContext,
                  '/lobby_waiting',
                  arguments: {'lobbyId': state.lobby.id},
                );
              }
            });
          }
        },
        child: StatefulBuilder(
          builder: (context, setState) => BlocBuilder<LobbyListCubit, LobbyListState>(
            builder: (context, cubitState) {
              final isCreating = cubitState is LobbyListLoaded && cubitState.isPerformingAction;
              final errorMessage = cubitState is LobbyListError ? cubitState.message : null;

              return Container(
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
                              onPressed: isCreating
                                  ? null
                                  : () {
                                      widget.onCreatingStateChanged(false);
                                      Navigator.pop(modalContext);
                                      _lobbyNameController.clear();
                                    },
                              child: AppText.button('Cancel'),
                            ),
                            AppText.h3('Create Lobby'),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: isCreating
                                  ? null
                                  : () {
                                      if (_lobbyNameController.text.trim().isNotEmpty) {
                                        widget.onCreatingStateChanged(true);
                                        cubit.createLobby(
                                          name: _lobbyNameController.text.trim(),
                                          gameType: _selectedGameType,
                                          maxPlayers: 2,
                                        );
                                      }
                                    },
                              child: AppText.button('Create'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (errorMessage != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.destructiveRed.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.exclamationmark_circle_fill,
                                            color: CupertinoColors.destructiveRed,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: AppText(
                                              errorMessage,
                                              style: const TextStyle(
                                                color: CupertinoColors.destructiveRed,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  AppText.bodyMediumSemiBold('Lobby Name'),
                                  const SizedBox(height: 8),
                                  CupertinoTextField(
                                    controller: _lobbyNameController,
                                    placeholder: 'Enter lobby name',
                                    padding: const EdgeInsets.all(12),
                                    autofocus: true,
                                    textCapitalization: TextCapitalization.words,
                                    clearButtonMode: OverlayVisibilityMode.editing,
                                    enabled: !isCreating,
                                  ),
                                  const SizedBox(height: 24),
                                  AppText.bodyMediumSemiBold('Game Type'),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: GameType.values.map((gameType) {
                                      final isSelected = _selectedGameType == gameType;
                                      return GestureDetector(
                                        onTap: isCreating
                                            ? null
                                            : () {
                                                setState(() {
                                                  _selectedGameType = gameType;
                                                });
                                              },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? CupertinoColors.activeBlue
                                                : CupertinoColors.tertiarySystemFill.resolveFrom(context),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isSelected
                                                  ? CupertinoColors.activeBlue
                                                  : CupertinoColors.separator.resolveFrom(context),
                                              width: 1,
                                            ),
                                          ),
                                          child: AppText(
                                            gameType.displayName,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? CupertinoColors.white
                                                  : CupertinoColors.label.resolveFrom(context),
                                              fontSize: 15,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            if (isCreating)
                              Container(
                                color: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.7),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CupertinoActivityIndicator(),
                                      const SizedBox(height: 16),
                                      AppText.bodyMedium('Creating lobby...'),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


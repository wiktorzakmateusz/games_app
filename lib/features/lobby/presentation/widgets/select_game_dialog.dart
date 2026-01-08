import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/app_text.dart';
import '../../../../core/shared/enums.dart';
import '../cubit/lobby_waiting_cubit.dart';
import '../cubit/lobby_waiting_state.dart';

class SelectGameDialog extends StatefulWidget {
  final GameType currentGameType;

  const SelectGameDialog({
    super.key,
    required this.currentGameType,
  });

  @override
  State<SelectGameDialog> createState() => _SelectGameDialogState();
}

class _SelectGameDialogState extends State<SelectGameDialog> {
  late GameType _selectedGameType;
  bool _hasInitiatedUpdate = false;

  @override
  void initState() {
    super.initState();
    _selectedGameType = widget.currentGameType;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LobbyWaitingCubit>();
    final modalContext = context;

    return BlocProvider.value(
      value: cubit,
      child: BlocListener<LobbyWaitingCubit, LobbyWaitingState>(
        listener: (context, state) {
          if (_hasInitiatedUpdate) {
            if (state is LobbyWaitingLoaded && !state.isPerformingAction) {
              Navigator.pop(modalContext);
            } else if (state is LobbyWaitingError) {
              Navigator.pop(modalContext);
            }
          }
        },
        child: StatefulBuilder(
          builder: (context, setState) => BlocBuilder<LobbyWaitingCubit, LobbyWaitingState>(
            builder: (context, state) {
              final isUpdating = state is LobbyWaitingLoaded && state.isPerformingAction;

              return Container(
                height: 300,
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
                              onPressed: isUpdating
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                    },
                              child: AppText.button('Cancel'),
                            ),
                            AppText.h3('Select Game'),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: isUpdating || _selectedGameType == widget.currentGameType
                                  ? null
                                  : () {
                                      _hasInitiatedUpdate = true;
                                      cubit.updateGameType(_selectedGameType);
                                    },
                              child: AppText.button('Change'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppText.bodyMediumSemiBold('Game Type'),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      alignment: WrapAlignment.start,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: GameType.values.map((gameType) {
                                      final isSelected = _selectedGameType == gameType;
                                      return GestureDetector(
                                        onTap: isUpdating
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
                            ),
                            if (isUpdating)
                              Positioned.fill(
                                child: Container(
                                  color: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.7),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const CupertinoActivityIndicator(),
                                        const SizedBox(height: 16),
                                        AppText.bodyMedium('Updating game type...'),
                                      ],
                                    ),
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


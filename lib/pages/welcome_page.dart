import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/app_text.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../widgets/game_button.dart';
import '../core/utils/responsive_layout.dart';
import '../core/services/audio_service.dart';
import '../core/services/settings_service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final audioService = AudioService();

  @override
  void initState() {
    super.initState();
    // Initialize audio in the background without blocking the UI
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      final settingsService = await SettingsService.getInstance();
      await audioService.initialize(settingsService);
    } catch (e) {
      // Fail silently if audio initialization fails
      print('Audio initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Settings button
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  audioService.playClickSound();
                  Navigator.pushNamed(context, '/app_settings');
                },
                child: const Icon(
                  CupertinoIcons.settings,
                  size: 28,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: ResponsiveLayout.constrainWidth(
              context,
              Padding(
                padding: ResponsiveLayout.getPadding(context),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText.h1('Play Together'),
                      SizedBox(height: ResponsiveLayout.getLargeSpacing(context)),
                      GameButton(
                        label: 'Play',
                        onTap: () {
                          Navigator.pushNamed(context, '/home');
                        },
                      ),
                      SizedBox(height: ResponsiveLayout.getSpacing(context)),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return GameButton(
                            label: 'Multiplayer',
                            onTap: () {
                              if (state is Authenticated) {
                                Navigator.pushNamed(context, '/lobby_list');
                              } else {
                                Navigator.pushNamed(context, '/auth');
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
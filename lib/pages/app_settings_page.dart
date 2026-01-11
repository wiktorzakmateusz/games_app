import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:games_app/widgets/app_text.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';
import '../core/services/settings_service.dart';
import '../core/services/audio_service.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  late SettingsService _settingsService;
  late AudioService _audioService;
  
  bool _soundEffects = true;
  bool _backgroundMusic = true;
  bool _hapticFeedback = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    _settingsService = await SettingsService.getInstance();
    _audioService = AudioService();
    
    setState(() {
      _soundEffects = _settingsService.soundEffectsEnabled;
      _backgroundMusic = _settingsService.backgroundMusicEnabled;
      _hapticFeedback = _settingsService.hapticFeedbackEnabled;
      _isLoading = false;
    });
  }

  Future<void> _toggleSoundEffects(bool value) async {
    if (_hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    setState(() => _soundEffects = value);
    await _settingsService.setSoundEffects(value);
  }

  Future<void> _toggleBackgroundMusic(bool value) async {
    if (_hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    setState(() => _backgroundMusic = value);
    await _settingsService.setBackgroundMusic(value);
    await _audioService.onBackgroundMusicSettingChanged(value);
  }

  Future<void> _toggleHapticFeedback(bool value) async {
    if (value) {
      HapticFeedback.lightImpact();
    }
    
    setState(() => _hapticFeedback = value);
    await _settingsService.setHapticFeedback(value);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: AppMenuNavBar(
        title: 'Settings',
        onBackPressed: () => Navigator.pop(context),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : CustomScrollView(
                slivers: [
                  SliverSafeArea(
                    sliver: SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Preferences Section
                          AppText.h5('PREFERENCES'),
                          const SizedBox(height: 8),
                          
                          // Sound Effects Toggle
                          _buildSettingTile(
                            icon: CupertinoIcons.volume_up,
                            iconColor: CupertinoColors.systemRed,
                            title: 'Sound Effects',
                            value: _soundEffects,
                            onChanged: _toggleSoundEffects,
                          ),
                          
                          const SizedBox(height: 1),
                          
                          // Background Music Toggle
                          _buildSettingTile(
                            icon: CupertinoIcons.music_note_2,
                            iconColor: CupertinoColors.systemPurple,
                            title: 'Background Music',
                            value: _backgroundMusic,
                            onChanged: _toggleBackgroundMusic,
                          ),
                          
                          const SizedBox(height: 1),
                          
                          // Haptic Feedback Toggle
                          _buildSettingTile(
                            icon: CupertinoIcons.device_phone_portrait,
                            iconColor: CupertinoColors.systemOrange,
                            title: 'Haptic Feedback',
                            value: _hapticFeedback,
                            onChanged: _toggleHapticFeedback,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // About Section
                          AppText.h5('ABOUT'),
                          const SizedBox(height: 8),
                          
                          // App Version
                          _buildInfoTile(
                            icon: CupertinoIcons.info_circle,
                            iconColor: CupertinoColors.systemBlue,
                            title: 'App Version',
                            trailing: '1.0.0 (Beta)',
                          ),
                          
                          const SizedBox(height: 1),
                          
                          // Terms of Service
                          _buildInfoTile(
                            icon: CupertinoIcons.doc_text,
                            iconColor: CupertinoColors.systemGrey,
                            title: 'Terms of Service',
                            showChevron: true,
                          ),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      color: CupertinoColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(child: AppText.bodyMedium(title)),
            CupertinoSwitch(
              value: value,
              activeColor: CupertinoColors.systemGreen,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? trailing,
    bool showChevron = false,
  }) {
    return Container(
      color: CupertinoColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(child: AppText.bodyMedium(title)),
            if (trailing != null)
              AppText.bodySmall(trailing)
            else if (showChevron)
              const Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}


import 'package:just_audio/just_audio.dart';
import 'settings_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  SettingsService? _settingsService;
  bool _isInitialized = false;

  Future<void> initialize(SettingsService settingsService) async {
    _settingsService = settingsService;
    _isInitialized = true;
    
    // Set music player to loop
    await _musicPlayer.setLoopMode(LoopMode.all);
    await _musicPlayer.setVolume(0.3); // Set to 30% volume
    
    // Start background music if enabled
    if (_settingsService!.backgroundMusicEnabled) {
      await playBackgroundMusic();
    }
  }

  // Background Music
  Future<void> playBackgroundMusic() async {
    if (!_isInitialized || !_settingsService!.backgroundMusicEnabled) return;
    
    try {
      await _musicPlayer.setAsset('assets/audio/background_music.mp3');
      await _musicPlayer.play();
    } catch (e) {
      // If audio file doesn't exist, fail silently
      print('Background music file not found: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isInitialized || !_settingsService!.backgroundMusicEnabled) return;
    await _musicPlayer.play();
  }

  // Sound Effects
  Future<void> playClickSound() async {
    if (!_isInitialized || !_settingsService!.soundEffectsEnabled) return;
    
    try {
      await _sfxPlayer.setAsset('assets/audio/click.mp3');
      await _sfxPlayer.play();
    } catch (e) {
      // Fail silently if sound doesn't exist
    }
  }

  Future<void> playWinSound() async {
    if (!_isInitialized || !_settingsService!.soundEffectsEnabled) return;
    
    try {
      await _sfxPlayer.setAsset('assets/audio/win.mp3');
      await _sfxPlayer.play();
    } catch (e) {
      // Fail silently if sound doesn't exist
    }
  }

  Future<void> playMoveSound() async {
    if (!_isInitialized || !_settingsService!.soundEffectsEnabled) return;
    
    try {
      await _sfxPlayer.setAsset('assets/audio/move.mp3');
      await _sfxPlayer.play();
    } catch (e) {
      // Fail silently if sound doesn't exist
    }
  }

  // Settings Change Handlers
  Future<void> onBackgroundMusicSettingChanged(bool enabled) async {
    if (enabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  // Cleanup
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}


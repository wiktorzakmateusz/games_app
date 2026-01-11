import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _soundEffectsKey = 'sound_effects';
  static const String _backgroundMusicKey = 'background_music';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // Sound Effects
  bool get soundEffectsEnabled => _prefs.getBool(_soundEffectsKey) ?? true;
  Future<void> setSoundEffects(bool enabled) async {
    await _prefs.setBool(_soundEffectsKey, enabled);
  }

  // Background Music
  bool get backgroundMusicEnabled => _prefs.getBool(_backgroundMusicKey) ?? true;
  Future<void> setBackgroundMusic(bool enabled) async {
    await _prefs.setBool(_backgroundMusicKey, enabled);
  }

  // Initialize
  static Future<SettingsService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }
}


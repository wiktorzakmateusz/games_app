import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'injection_container.dart' as di;
import 'core/services/settings_service.dart';
import 'core/services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');
  
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize dependency injection
  await di.initializeDependencies();
  
  // Initialize audio and settings
  final settingsService = await SettingsService.getInstance();
  final audioService = AudioService();
  await audioService.initialize(settingsService);
  
  runApp(const MyApp());
}
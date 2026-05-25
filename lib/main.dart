import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card2_dialogue/dialogue_screen.dart';
import 'features/card3_document/document_screen.dart';
import 'features/card4_stories/stories_screen.dart';
import 'features/games/rubik_cube/rubik_cube_screen.dart';
import 'features/games/chess/chess_screen.dart';
import 'features/home_screen.dart';
import 'features/settings/settings_screen.dart';
import 'core/theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/floating_bubble_service.dart';
import 'services/tts_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MirrorScriptionApp());
}

class MirrorScriptionApp extends StatelessWidget {
  const MirrorScriptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => FloatingBubbleService()..initialize()),
        ChangeNotifierProvider(create: (_) => TTSService()),
      ],
      child: MaterialApp(
        title: 'Mirror Scription',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/translate': (context) => const TextTranslationScreen(),
          '/dialogue': (context) => const DialogueTranslationScreen(),
          '/document': (context) => const DocumentTranslationScreen(),
          '/stories': (context) => const StoriesScreen(),
          '/chess': (context) => const ChessScreen(),
          '/rubik': (context) => const RubikCubeScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/text_translation/text_translation_screen.dart';
import 'features/dialogue_translation/dialogue_translation_screen.dart';
import 'features/document_camera_translation/document_camera_translation_screen.dart';
import 'features/hadith_stories/hadith_stories_screen.dart';
import 'features/games/games_screen.dart';
import 'features/settings/settings_screen.dart';

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
    return MaterialApp(
      title: 'Mirror Scription',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        fontFamily: 'sans-serif',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B2838),
              Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // App Title
                Text(
                  'Mirror Scription',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade300,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'نسخة المرآة - ترجمة، قصص، وألعاب',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 40),
                // Cards Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildCard(
                        context,
                        icon: Icons.translate,
                        label: 'ترجمة نصوص',
                        labelEn: 'Text Translation',
                        color: Colors.blue,
                        route: const TextTranslationScreen(),
                      ),
                      _buildCard(
                        context,
                        icon: Icons.headset_mic,
                        label: 'ترجمة حوار',
                        labelEn: 'Dialogue Translation',
                        color: Colors.green,
                        route: const DialogueTranslationScreen(),
                      ),
                      _buildCard(
                        context,
                        icon: Icons.document_scanner,
                        label: 'ترجمة مستندات',
                        labelEn: 'Document/Camera',
                        color: Colors.orange,
                        route: const DocumentCameraTranslationScreen(),
                      ),
                      _buildCard(
                        context,
                        icon: Icons.auto_stories,
                        label: 'أحاديث وقصص',
                        labelEn: 'Hadith & Stories',
                        color: Colors.purple,
                        route: const HadithStoriesScreen(),
                      ),
                      _buildCard(
                        context,
                        icon: Icons.sports_esports,
                        label: 'ألعاب',
                        labelEn: 'Games',
                        color: Colors.teal,
                        route: const GamesScreen(),
                      ),
                      _buildCard(
                        context,
                        icon: Icons.settings,
                        label: 'الإعدادات',
                        labelEn: 'Settings',
                        color: Colors.grey,
                        route: const SettingsScreen(),
                      ),
                    ],
                  ),
                ),
                // Footer
                const SizedBox(height: 8),
                Text(
                  'Mirror Scription v1.0 | TetoCollctionWay',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String labelEn,
    required Color color,
    required Widget route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => route),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.08),
            ],
          ),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: color.withOpacity(0.8)),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labelEn,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

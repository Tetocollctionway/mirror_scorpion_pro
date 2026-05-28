import 'features/admin/key_generator_screen.dart';
import 'core/utils/r_bridge.dart';
import 'package:flutter/foundation.dart';
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
import 'services/database_service.dart';
import 'services/floating_bubble_service.dart';
import 'services/tts_service.dart';
import 'services/premium_verification_service.dart';
import 'core/theme/theme_provider.dart';

void main() {
  initializeRVariables();
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => FloatingBubbleService()..initialize()),
        ChangeNotifierProvider(create: (_) => TTSService()),
        ChangeNotifierProvider(create: (_) => PremiumVerificationService()..initialize()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Mirror Scription',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
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
          '/admin_gen': (context) => const _AdminGate(),
            },
          );
        },
      ),
    );
  }
}

/// Gate that requires a password before granting access to the key generator.
class _AdminGate extends StatefulWidget {
  const _AdminGate();

  @override
  State<_AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<_AdminGate> {
  static const String _adminPassword = String.fromEnvironment(
    'MIRROR_ADMIN_PASSWORD',
    defaultValue: '',
  );

  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final input = _controller.text.trim();
    if (_adminPassword.isEmpty) {
      setState(() => _error = 'Admin access is disabled in this build');
      return;
    }
    if (input == _adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const KeyGeneratorScreen()),
      );
    } else {
      setState(() => _error = 'كلمة المرور غير صحيحة');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('تسجيل دخول المطور',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, color: Colors.amber, size: 64),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'أدخل كلمة مرور المطور',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                errorText: _error,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('دخول',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

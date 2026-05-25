import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _selectedVoice = 'voice_1_female';
  
  // 5 voices for the app as per requirements
  static const List<Map<String, String>> availableVoices = [
    {'id': 'voice_1_female', 'name': 'سلمى'},
    {'id': 'voice_2_male', 'name': 'سيف'},
    {'id': 'voice_3_female_warm', 'name': 'سما'},
    {'id': 'voice_4_male_deep', 'name': 'ساره'}, // Note: Name in requirement is Sara, but often voices vary
    {'id': 'voice_5_premium_ai', 'name': 'صوت المستخدم'}, // Premium AI cloned voice
  ];

  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  String get selectedVoice => _selectedVoice;

  TTSService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ar');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      debugPrint('TTS Error: $msg');
      notifyListeners();
    });
  }

  Future<void> setVoice(String voiceId) async {
    _selectedVoice = voiceId;
    
    // Configure based on voice type
    switch (voiceId) {
      case 'voice_1_female': // سلمى
        await _flutterTts.setPitch(1.2);
        await _flutterTts.setSpeechRate(0.5);
        break;
      case 'voice_2_male': // سيف
        await _flutterTts.setPitch(0.8);
        await _flutterTts.setSpeechRate(0.45);
        break;
      case 'voice_3_female_warm': // سما
        await _flutterTts.setPitch(1.1);
        await _flutterTts.setSpeechRate(0.4);
        break;
      case 'voice_4_male_deep': // ساره (as requested, but configured deep)
        await _flutterTts.setPitch(0.7);
        await _flutterTts.setSpeechRate(0.4);
        break;
      case 'voice_5_premium_ai':
        // Premium AI voice - uses external API or special config
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.5);
        break;
    }
    
    notifyListeners();
  }

  Future<void> speak(String text, {String? language}) async {
    if (_isSpeaking) {
      await stop();
    }

    _isSpeaking = true;
    notifyListeners();

    if (language != null) {
      await _flutterTts.setLanguage(language);
    } else {
      await _flutterTts.setLanguage('ar');
    }

    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    _isPaused = false;
    notifyListeners();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
    _isPaused = true;
    notifyListeners();
  }

  Future<void> resume() async {
    // Note: resume behavior depends on platform
    _isPaused = false;
    notifyListeners();
  }

  Future<List<String>> getAvailableLanguages() async {
    return await _flutterTts.getLanguages;
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}

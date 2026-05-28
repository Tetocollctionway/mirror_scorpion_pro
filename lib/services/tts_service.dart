import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _selectedVoice = 'voice_1_female';
  List<dynamic> _deviceVoices = [];
  
  // 5 voices for the app as per requirements
  static const List<Map<String, String>> availableVoices = [
    {'id': 'voice_1_female', 'name': 'سلمى'},
    {'id': 'voice_2_male', 'name': 'سيف'},
    {'id': 'voice_3_female_warm', 'name': 'سما'},
    {'id': 'voice_4_female_soft', 'name': 'سارة'},
    {'id': 'voice_5_premium_ai', 'name': 'صوت المستخدم (نسخ)'},
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
    
    // Load available device voices to assign distinct ones
    try {
      _deviceVoices = await _flutterTts.getVoices;
    } catch (e) {
      debugPrint('Error loading voices: $e');
    }
    
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

  /// Find a device voice matching criteria
  Map<String, String>? _findVoice({String? locale, String? gender}) {
    if (_deviceVoices.isEmpty) return null;
    for (var voice in _deviceVoices) {
      if (voice is Map) {
        final voiceLocale = voice['locale']?.toString() ?? '';
        final voiceName = voice['name']?.toString().toLowerCase() ?? '';
        
        bool localeMatch = locale == null || voiceLocale.startsWith(locale);
        bool genderMatch = gender == null || voiceName.contains(gender);
        
        if (localeMatch && genderMatch) {
          return {'name': voice['name'].toString(), 'locale': voiceLocale};
        }
      }
    }
    return null;
  }

  Future<void> setVoice(String voiceId) async {
    _selectedVoice = voiceId;
    
    // Each voice uses distinct pitch, rate, AND attempts to use a different device voice
    switch (voiceId) {
      case 'voice_1_female': // سلمى - Balanced female
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.5);
        final voice = _findVoice(locale: 'ar', gender: 'female');
        if (voice != null) await _flutterTts.setVoice(voice);
        break;
      case 'voice_2_male': // سيف - Deep male
        await _flutterTts.setPitch(0.7);
        await _flutterTts.setSpeechRate(0.42);
        final voice = _findVoice(locale: 'ar', gender: 'male');
        if (voice != null) await _flutterTts.setVoice(voice);
        break;
      case 'voice_3_female_warm': // سما - Warm female  
        await _flutterTts.setPitch(1.15);
        await _flutterTts.setSpeechRate(0.48);
        final voice = _findVoice(locale: 'ar');
        if (voice != null) await _flutterTts.setVoice(voice);
        break;
      case 'voice_4_female_soft': // سارة - Soft/gentle female
        await _flutterTts.setPitch(1.35);
        await _flutterTts.setSpeechRate(0.55);
        final voice = _findVoice(locale: 'ar');
        if (voice != null) await _flutterTts.setVoice(voice);
        break;
      case 'voice_5_premium_ai': // صوت المستخدم - AI voice clone (premium)
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

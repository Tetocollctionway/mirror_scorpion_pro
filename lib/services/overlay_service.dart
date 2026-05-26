import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_service.dart';

class OverlayService extends ChangeNotifier {
  final AIService aiService;
  late SharedPreferences _prefs;
  
  bool _isOverlayActive = false;
  String _sourceLanguage = 'en';
  String _targetLanguage = 'ar';
  String? _selectedApp;
  bool _isFloatingBubbleEnabled = true;
  String _selectedVoice = 'voice_1_female';

  OverlayService({required this.aiService}) {
    _initializePreferences();
  }

  bool get isOverlayActive => _isOverlayActive;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String? get selectedApp => _selectedApp;
  bool get isFloatingBubbleEnabled => _isFloatingBubbleEnabled;
  String get selectedVoice => _selectedVoice;

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _sourceLanguage = _prefs.getString('overlay_source_lang') ?? 'en';
    _targetLanguage = _prefs.getString('overlay_target_lang') ?? 'ar';
    _isFloatingBubbleEnabled = _prefs.getBool('floating_bubble_enabled') ?? true;
    _selectedVoice = _prefs.getString('overlay_voice') ?? 'voice_1_female';
    notifyListeners();
  }

  /// Toggle overlay visibility
  void toggleOverlay() {
    _isOverlayActive = !_isOverlayActive;
    notifyListeners();
  }

  /// Toggle floating bubble
  Future<void> toggleFloatingBubble() async {
    _isFloatingBubbleEnabled = !_isFloatingBubbleEnabled;
    await _prefs.setBool('floating_bubble_enabled', _isFloatingBubbleEnabled);
    notifyListeners();
  }

  /// Get spiritual support for text
  Future<String> getSpiritualSupport() async {
    final text = await translateFromClipboard();
    if (text.isNotEmpty) {
      return AIService.generateInspiration(userMood: text, context: 'overlay');
    }
    return "استعن بالله، فأنت في حفظه.";
  }

  /// Get text from clipboard
  Future<String> translateFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) return clipboardData!.text!;
    } catch (e) {
      debugPrint('Clipboard error: $e');
    }
    return '';
  }

  /// Translate text with selected languages
  Future<String> translateText(String text) async {
    try {
      // Simulate translation API call
      // In real app, this would call Google Translate API
      return 'Translated: $text from $_sourceLanguage to $_targetLanguage';
    } catch (e) {
      debugPrint('Translation error: $e');
      return text;
    }
  }

  /// Set source language
  Future<void> setSourceLanguage(String lang) async {
    _sourceLanguage = lang;
    await _prefs.setString('overlay_source_lang', lang);
    notifyListeners();
  }

  /// Set target language
  Future<void> setTargetLanguage(String lang) async {
    _targetLanguage = lang;
    await _prefs.setString('overlay_target_lang', lang);
    notifyListeners();
  }

  /// Set selected voice
  Future<void> setSelectedVoice(String voice) async {
    _selectedVoice = voice;
    await _prefs.setString('overlay_voice', voice);
    notifyListeners();
  }

  /// Set selected app
  void setSelectedApp(String app) {
    _selectedApp = app;
    notifyListeners();
  }

  /// Deactivate overlay
  void deactivateOverlay() {
    _isOverlayActive = false;
    _selectedApp = null;
    notifyListeners();
  }

  /// Create floating bubble via native channel
  Future<void> createFloatingBubble() async {
    const channel = MethodChannel('mirror_scription/overlay');
    try {
      await channel.invokeMethod('createFloatingBubble', {
        'sourceLanguage': _sourceLanguage,
        'targetLanguage': _targetLanguage,
        'voice': _selectedVoice,
      });
    } catch (e) {
      debugPrint('Floating bubble error: $e');
    }
  }

  /// Get overlay status
  Map<String, dynamic> getStatus() {
    return {
      'is_active': _isOverlayActive,
      'source_language': _sourceLanguage,
      'target_language': _targetLanguage,
      'selected_app': _selectedApp,
      'floating_bubble_enabled': _isFloatingBubbleEnabled,
      'selected_voice': _selectedVoice,
    };
  }

  /// Intercept and translate messages from other apps
  Future<String> interceptAndTranslate(String message) async {
    try {
      final translated = await translateText(message);
      return translated;
    } catch (e) {
      debugPrint('Interception error: $e');
      return message;
    }
  }

  /// Get supported languages
  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'ar', 'name': 'العربية'},
      {'code': 'en', 'name': 'English'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'es', 'name': 'Español'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'zh', 'name': '中文'},
      {'code': 'ja', 'name': '日本語'},
      {'code': 'ko', 'name': '한국어'},
      {'code': 'ru', 'name': 'Русский'},
      {'code': 'pt', 'name': 'Português'},
      {'code': 'it', 'name': 'Italiano'},
      {'code': 'tr', 'name': 'Türkçe'},
      {'code': 'hi', 'name': 'हिन्दी'},
      {'code': 'ur', 'name': 'اردو'},
    ];
  }

  /// Get supported apps for overlay
  List<String> getSupportedApps() {
    return [
      'WhatsApp',
      'Telegram',
      'Facebook Messenger',
      'Instagram',
      'Twitter',
      'Gmail',
      'SMS',
      'Discord',
      'Viber',
      'Signal',
    ];
  }
}

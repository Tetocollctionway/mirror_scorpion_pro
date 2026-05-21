import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ai_service.dart';

class OverlayService extends ChangeNotifier {
  final AIService aiService;
  bool _isOverlayActive = false;
  String _sourceLanguage = 'en';
  String _targetLanguage = 'ar';
  String? _selectedApp;

  OverlayService({required this.aiService});

  bool get isOverlayActive => _isOverlayActive;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String? get selectedApp => _selectedApp;

  void toggleOverlay() {
    _isOverlayActive = !_isOverlayActive;
    notifyListeners();
  }

  // --- دمج الأداة الشعورية ---
  Future<String> getSpiritualSupport() async {
    final text = await translateFromClipboard();
    if (text.isNotEmpty) {
      return aiService.getInspirationForText(text);
    }
    return "استعن بالله، فأنت في حفظه.";
  }

  Future<String> translateFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) return clipboardData.text!;
    } catch (e) {
      debugPrint('Clipboard error: $e');
    }
    return '';
  }

  // الدوال الأصلية للتحكم بالواجهة
  void setSourceLanguage(String lang) { _sourceLanguage = lang; notifyListeners(); }
  void setTargetLanguage(String lang) { _targetLanguage = lang; notifyListeners(); }
  void setSelectedApp(String app) { _selectedApp = app; notifyListeners(); }
  void deactivateOverlay() { _isOverlayActive = false; _selectedApp = null; notifyListeners(); }

  Future<void> createFloatingBubble() async {
    const channel = MethodChannel('mirror_scription/overlay');
    await channel.invokeMethod('createFloatingBubble', {
      'sourceLanguage': _sourceLanguage,
      'targetLanguage': _targetLanguage,
    });
  }
}

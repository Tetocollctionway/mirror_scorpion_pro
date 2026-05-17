import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OverlayService extends ChangeNotifier {
  bool _isOverlayActive = false;
  String _sourceLanguage = 'en';
  String _targetLanguage = 'ar';
  String? _selectedApp;
  
  bool get isOverlayActive => _isOverlayActive;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String? get selectedApp => _selectedApp;

  static const List<String> supportedApps = [
    'WhatsApp',
    'Messenger',
    'Telegram',
    'Instagram',
    'Twitter/X',
    'Snapchat',
  ];

  void toggleOverlay() {
    _isOverlayActive = !_isOverlayActive;
    notifyListeners();
  }

  void setSourceLanguage(String lang) {
    _sourceLanguage = lang;
    notifyListeners();
  }

  void setTargetLanguage(String lang) {
    _targetLanguage = lang;
    notifyListeners();
  }

  void setSelectedApp(String app) {
    _selectedApp = app;
    notifyListeners();
  }

  void deactivateOverlay() {
    _isOverlayActive = false;
    _selectedApp = null;
    notifyListeners();
  }

  // When overlay is closed, revert translated messages to original
  void revertTranslation() {
    // This would trigger the reversion of all translated texts
    // back to their original language in the chat
    debugPrint('Overlay closed: reverting translations to original languages');
  }

  // Request overlay permissions (Android)
  Future<bool> requestOverlayPermission() async {
    try {
      // This would use platform channels to request
      // android.permission.SYSTEM_ALERT_WINDOW
      const channel = MethodChannel('mirror_scription/overlay');
      final result = await channel.invokeMethod<bool>('requestOverlayPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('Overlay permission error: $e');
      return false;
    }
  }

  // Create floating bubble
  Future<void> createFloatingBubble() async {
    try {
      const channel = MethodChannel('mirror_scription/overlay');
      await channel.invokeMethod('createFloatingBubble', {
        'sourceLanguage': _sourceLanguage,
        'targetLanguage': _targetLanguage,
      });
    } catch (e) {
      debugPrint('Floating bubble error: $e');
    }
  }

  // Translate text from other apps
  Future<String> translateFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        return clipboardData.text!;
      }
    } catch (e) {
      debugPrint('Clipboard error: $e');
    }
    return '';
  }
}

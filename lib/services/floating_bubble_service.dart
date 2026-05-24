import 'package:dash_bubble/dash_bubble.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced Floating Bubble Service with full control
class FloatingBubbleService extends ChangeNotifier {
  static final FloatingBubbleService _instance = FloatingBubbleService._internal();
  
  factory FloatingBubbleService() => _instance;
  FloatingBubbleService._internal();
  
  late SharedPreferences _prefs;
  bool _isStarted = false;
  bool _isEnabled = false;
  double _opacity = 0.8;
  int _size = 120;
  String _selectedLanguage = 'en';
  bool _autoTranslate = true;
  bool _soundEnabled = true;
  
  // Getters
  bool get isStarted => _isStarted;
  bool get isEnabled => _isEnabled;
  double get opacity => _opacity;
  int get size => _size;
  String get selectedLanguage => _selectedLanguage;
  bool get autoTranslate => _autoTranslate;
  bool get soundEnabled => _soundEnabled;
  
  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }
  
  /// Load settings from SharedPreferences
  void _loadSettings() {
    _isEnabled = _prefs.getBool('bubble_enabled') ?? false;
    _opacity = _prefs.getDouble('bubble_opacity') ?? 0.8;
    _size = _prefs.getInt('bubble_size') ?? 120;
    _selectedLanguage = _prefs.getString('bubble_language') ?? 'en';
    _autoTranslate = _prefs.getBool('bubble_auto_translate') ?? true;
    _soundEnabled = _prefs.getBool('bubble_sound') ?? true;
    notifyListeners();
  }
  
  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    await _prefs.setBool('bubble_enabled', _isEnabled);
    await _prefs.setDouble('bubble_opacity', _opacity);
    await _prefs.setInt('bubble_size', _size);
    await _prefs.setString('bubble_language', _selectedLanguage);
    await _prefs.setBool('bubble_auto_translate', _autoTranslate);
    await _prefs.setBool('bubble_sound', _soundEnabled);
  }
  
  /// Start the floating bubble
  Future<void> startBubble(BuildContext context) async {
    if (_isStarted) return;
    
    try {
      // Check and request overlay permission
      final hasPermission = await DashBubble.instance.hasOverlayPermission();
      if (!hasPermission) {
        debugPrint('🫧 Requesting overlay permission...');
        await DashBubble.instance.requestOverlayPermission();
      }
      
      // Start the bubble with saved settings
      _isStarted = await DashBubble.instance.startBubble(
        bubbleOptions: BubbleOptions(
          bubbleIcon: "scorpion_icon",
          distanceToClose: 100,
          enableAnimateToEdge: true,
          enableClose: true,
          size: _size,
          opacity: _opacity,
        ),
        onTap: () {
          debugPrint('🫧 Bubble Tapped!');
          _onBubbleTapped(context);
        },
      );
      
      _isEnabled = true;
      await _saveSettings();
      notifyListeners();
      
      debugPrint('🫧 Floating bubble started successfully!');
      debugPrint('📍 Size: $_size | Opacity: $_opacity | Language: $_selectedLanguage');
    } catch (e) {
      debugPrint('❌ Error starting bubble: $e');
      _isStarted = false;
    }
  }
  
  /// Stop the floating bubble
  Future<void> stopBubble() async {
    if (!_isStarted) return;
    
    try {
      await DashBubble.instance.stopBubble();
      _isStarted = false;
      _isEnabled = false;
      await _saveSettings();
      notifyListeners();
      debugPrint('🫧 Floating bubble stopped');
    } catch (e) {
      debugPrint('❌ Error stopping bubble: $e');
    }
  }
  
  /// Toggle bubble on/off
  Future<void> toggleBubble(BuildContext context, bool enabled) async {
    if (enabled && !_isStarted) {
      await startBubble(context);
    } else if (!enabled && _isStarted) {
      await stopBubble();
    }
    notifyListeners();
  }
  
  /// Update bubble opacity
  Future<void> setOpacity(double opacity) async {
    _opacity = opacity.clamp(0.3, 1.0);
    
    if (_isStarted) {
      await stopBubble();
      // Restart with new settings (in real app, would update live)
    }
    
    await _saveSettings();
    notifyListeners();
  }
  
  /// Update bubble size
  Future<void> setSize(int size) async {
    _size = size.clamp(60, 200);
    
    if (_isStarted) {
      await stopBubble();
      // Restart with new settings (in real app, would update live)
    }
    
    await _saveSettings();
    notifyListeners();
  }
  
  /// Set target language for translation
  Future<void> setTargetLanguage(String language) async {
    _selectedLanguage = language;
    await _saveSettings();
    notifyListeners();
    debugPrint('🌐 Bubble language changed to: $language');
  }
  
  /// Toggle auto-translate feature
  Future<void> toggleAutoTranslate(bool enabled) async {
    _autoTranslate = enabled;
    await _saveSettings();
    notifyListeners();
    debugPrint('🔄 Auto-translate: ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Toggle sound for translations
  Future<void> toggleSound(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();
    notifyListeners();
    debugPrint('🔊 Sound: ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Handle bubble tap event
  void _onBubbleTapped(BuildContext context) {
    if (_soundEnabled) {
      _playSound();
    }
    
    // Show a quick translation dialog or menu
    _showBubbleMenu(context);
  }
  
  /// Show bubble menu/options
  void _showBubbleMenu(BuildContext context) {
    debugPrint('📋 Showing bubble menu...');
    // In a real app, show a menu with translation options
  }
  
  /// Play sound effect
  void _playSound() {
    debugPrint('🔊 Playing sound...');
    // In a real app, use audio_players package
  }
  
  /// Get bubble status
  Map<String, dynamic> getBubbleStatus() {
    return {
      'isStarted': _isStarted,
      'isEnabled': _isEnabled,
      'opacity': _opacity,
      'size': _size,
      'language': _selectedLanguage,
      'autoTranslate': _autoTranslate,
      'soundEnabled': _soundEnabled,
    };
  }
  
  /// Reset to default settings
  Future<void> resetToDefaults() async {
    _opacity = 0.8;
    _size = 120;
    _selectedLanguage = 'en';
    _autoTranslate = true;
    _soundEnabled = true;
    await _saveSettings();
    notifyListeners();
    debugPrint('🔄 Bubble settings reset to defaults');
  }
}

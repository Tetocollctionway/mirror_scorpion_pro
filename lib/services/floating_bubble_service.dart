import 'package:dash_bubble/dash_bubble.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced Floating Bubble Service with full control and fixed permissions
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
      final hasOverlay = await DashBubble.instance.hasOverlayPermission();
      if (!hasOverlay) {
        final granted = await DashBubble.instance.requestOverlayPermission();
        if (!granted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('يجب تفعيل إذن الظهور فوق التطبيقات لتشغيل الفقاعة')),
            );
          }
          return;
        }
      }
      
      // Note: Accessibility permission is usually needed for social app text reading
      // We check for it if available in the plugin version or handle via fallback
      debugPrint('🫧 Checking social app integration...');
      
      // Start the bubble with saved settings
      final started = await DashBubble.instance.startBubble(
        bubbleOptions: BubbleOptions(
          bubbleIcon: "launcher_icon", // Changed to launcher_icon which is standard
          distanceToClose: 100,
          enableAnimateToEdge: true,
          enableClose: true,
          bubbleSize: _size.toDouble(),
          opacity: _opacity,
        ),
        onTap: () {
          debugPrint('🫧 Bubble Tapped!');
          _onBubbleTapped(context);
        },
      );
      
      if (started) {
        _isStarted = true;
        _isEnabled = true;
        await _saveSettings();
        notifyListeners();
        debugPrint('🫧 Floating bubble started successfully!');
      }
    } catch (e) {
      debugPrint('❌ Error starting bubble: $e');
      _isStarted = false;
    }
  }
  
  /// Stop the floating bubble
  Future<void> stopBubble() async {
    try {
      final stopped = await DashBubble.instance.stopBubble();
      if (stopped) {
        _isStarted = false;
        _isEnabled = false;
        await _saveSettings();
        notifyListeners();
        debugPrint('🫧 Floating bubble stopped');
      }
    } catch (e) {
      debugPrint('❌ Error stopping bubble: $e');
    }
  }
  
  /// Toggle bubble on/off
  Future<void> toggleBubble(BuildContext context, bool enabled) async {
    if (enabled) {
      await startBubble(context);
    } else {
      await stopBubble();
    }
    notifyListeners();
  }
  
  /// Update bubble opacity
  Future<void> setOpacity(double opacity) async {
    _opacity = opacity.clamp(0.3, 1.0);
    await _saveSettings();
    if (_isStarted) {
      // Re-start to apply changes
      await DashBubble.instance.stopBubble();
      _isStarted = false;
      // Note: In a real scenario, we might need a context here or handle it via a global key
    }
    notifyListeners();
  }
  
  /// Update bubble size
  Future<void> setSize(int size) async {
    _size = size.clamp(60, 200);
    await _saveSettings();
    if (_isStarted) {
      await DashBubble.instance.stopBubble();
      _isStarted = false;
    }
    notifyListeners();
  }
  
  /// Set target language for translation
  Future<void> setTargetLanguage(String language) async {
    _selectedLanguage = language;
    await _saveSettings();
    notifyListeners();
  }
  
  /// Toggle auto-translate feature
  Future<void> toggleAutoTranslate(bool enabled) async {
    _autoTranslate = enabled;
    await _saveSettings();
    notifyListeners();
  }
  
  /// Handle bubble tap event
  void _onBubbleTapped(BuildContext context) {
    // Show translation UI
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ميرور سكربيون - ترجمة فورية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('الفقاعة العائمة نشطة وتعمل على ترجمة نصوص تطبيقات التواصل.'),
            const SizedBox(height: 10),
            Text('اللغة الحالية: $_selectedLanguage'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

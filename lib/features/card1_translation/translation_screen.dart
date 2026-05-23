import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  late stt.SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  CameraController? _cameraController;
  
  String _sourceLang = 'en';
  String _targetLang = 'ar';
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isLensMode = false;
  bool _showOriginal = false;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'ar', 'name': 'Arabic', 'native': 'العربية'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
    {'code': 'si', 'name': 'Sinhala', 'native': 'සිංහල'},
    {'code': 'fr', 'name': 'French', 'native': 'Français'},
    {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
    {'code': 'de', 'name': 'German', 'native': 'Deutsch'},
    {'code': 'tr', 'name': 'Turkish', 'native': 'Türkçe'},
    {'code': 'ur', 'name': 'Urdu', 'native': 'اردو'},
    {'code': 'fa', 'name': 'Persian', 'native': 'فارسی'},
    {'code': 'id', 'name': 'Indonesian', 'native': 'Bahasa Indonesia'},
    {'code': 'ms', 'name': 'Malay', 'native': 'Bahasa Melayu'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'zh', 'name': 'Chinese', 'native': '中文'},
    {'code': 'ja', 'name': 'Japanese', 'native': '日本語'},
    {'code': 'ko', 'name': 'Korean', 'native': '한국어'},
    {'code': 'ru', 'name': 'Russian', 'native': 'Русский'},
    {'code': 'it', 'name': 'Italian', 'native': 'Italiano'},
    {'code': 'pt', 'name': 'Portuguese', 'native': 'Português'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeSpeechAndTTS();
  }

  Future<void> _initializeSpeechAndTTS() async {
    _speechToText = stt.SpeechToText();
    _flutterTts = FlutterTts();
    
    await _speechToText.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );

    await _flutterTts.setLanguage(_targetLang);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    _speechToText.stop();
    _flutterTts.stop();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> translate() async {
    final text = _sourceController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=$_sourceLang&tl=$_targetLang&dt=t&q=${Uri.encodeComponent(text)}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        setState(() => _targetController.text = translated);
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleLensMode() {
    setState(() {
      _isLensMode = !_isLensMode;
      if (_isLensMode) {
        _initializeCamera();
      } else {
        _cameraController?.dispose();
        _cameraController = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(_isLensMode ? 'عدسة ميرور (Lens)' : 'الترجمة النصية', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isLensMode ? Icons.text_fields : Icons.camera_alt, color: Colors.white),
            onPressed: _toggleLensMode,
            tooltip: _isLensMode ? 'الوضع النصي' : 'وضع العدسة',
          ),
        ],
      ),
      body: _isLensMode ? _buildLensUI() : _buildTextUI(),
    );
  }

  Widget _buildLensUI() {
    return Stack(
      children: [
        // Camera Preview
        if (_cameraController != null && _cameraController!.value.isInitialized)
          Positioned.fill(child: CameraPreview(_cameraController!))
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),

        // Scanning Overlay (Google Lens Style)
        Center(
          child: Container(
            width: 250,
            height: 350,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.transparent, Colors.blue.withOpacity(0.8), Colors.transparent]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Language Dropdown (Floating)
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSimpleLangDropdown(_sourceLang, (v) => setState(() => _sourceLang = v)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ),
                _buildSimpleLangDropdown(_targetLang, (v) => setState(() => _targetLang = v)),
              ],
            ),
          ),
        ),

        // Bottom Controls
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Touch to show original (Description)
              GestureDetector(
                onLongPressStart: (_) => setState(() => _showOriginal = true),
                onLongPressEnd: (_) => setState(() => _showOriginal = false),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                  ),
                  child: Center(
                    child: Text(
                      _showOriginal ? 'إظهار الأصل...' : 'الترجمة الفورية نشطة (المس للأصل)',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Transparent Signature (130 degrees)
              Transform.rotate(
                angle: 130 * 3.14 / 180,
                child: Text(
                  'Mirror Scorpion',
                  style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextUI() {
    final isRtl = _targetLang == 'ar' || _targetLang == 'ur' || _targetLang == 'fa';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLanguageSelector('من', _sourceLang, (v) => setState(() => _sourceLang = v)),
          const SizedBox(height: 16),
          _buildTextInputField(_sourceController, 'أدخل النص هنا...', Icons.mic),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : translate,
              icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.translate),
              label: const Text('ترجمة الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLanguageSelector('إلى', _targetLang, (v) => setState(() => _targetLang = v)),
          const SizedBox(height: 16),
          _buildResultField(_targetController, 'ستظهر الترجمة هنا...', isRtl),
        ],
      ),
    );
  }

  Widget _buildSimpleLangDropdown(String value, ValueChanged<String> onChanged) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        dropdownColor: Colors.black,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        items: _languages.map((l) => DropdownMenuItem(value: l['code'], child: Text(l['native']!))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }

  Widget _buildLanguageSelector(String label, String current, ValueChanged<String> onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: _buildSimpleLangDropdown(current, onChanged),
          ),
        ),
      ],
    );
  }

  Widget _buildTextInputField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue.withOpacity(0.3))),
      child: TextField(
        controller: controller,
        maxLines: 5,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: Icon(icon, color: Colors.blueAccent),
        ),
      ),
    );
  }

  Widget _buildResultField(TextEditingController controller, String hint, bool isRtl) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.green.withOpacity(0.3))),
      child: TextField(
        controller: controller,
        maxLines: 5,
        readOnly: true,
        textAlign: isRtl ? TextAlign.right : TextAlign.left,
        style: const TextStyle(color: Colors.greenAccent, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: const Icon(Icons.volume_up, color: Colors.green),
        ),
      ),
    );
  }
}

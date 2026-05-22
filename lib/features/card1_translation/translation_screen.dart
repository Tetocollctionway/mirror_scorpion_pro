import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

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
  
  String _sourceLang = 'en';
  String _targetLang = 'ar';
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _swapLock = false;

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

  String? _selectedSourceLang;
  String? _selectedTargetLang;

  @override
  void initState() {
    super.initState();
    _selectedSourceLang = 'en';
    _selectedTargetLang = 'ar';
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

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    _speechToText.stop();
    _flutterTts.stop();
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Translation failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().substring(0, 50)}...')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startListening() async {
    if (!_isListening && await _speechToText.initialize()) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _sourceController.text = result.recognizedWords;
          });
        },
        localeId: _sourceLang,
      );
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
    
    if (_sourceController.text.isNotEmpty) {
      await translate();
    }
  }

  Future<void> _speakTranslation() async {
    if (_targetController.text.isEmpty) return;
    
    setState(() => _isSpeaking = true);
    
    try {
      await _flutterTts.setLanguage(_targetLang);
      await _flutterTts.speak(_targetController.text);
      
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (e) {
      debugPrint('TTS Error: $e');
      setState(() => _isSpeaking = false);
    }
  }

  void swapLanguages() {
    if (_swapLock) return;
    final temp = _sourceLang;
    setState(() {
      _sourceLang = _targetLang;
      _targetLang = temp;
      _selectedSourceLang = _sourceLang;
      _selectedTargetLang = _targetLang;
      _sourceController.text = _targetController.text;
      _targetController.clear();
    });
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _targetController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _shareTranslation() {
    final text = 'ترجمة بواسطة Mirror Scorpion:\n\n${_sourceController.text}\n\n➜\n\n${_targetController.text}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Translation copied for sharing')),
    );
  }

  void clearAll() {
    _sourceController.clear();
    _targetController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = _targetLang == 'ar' || _targetLang == 'ur' || _targetLang == 'fa';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Translation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.swap_horiz), onPressed: swapLanguages, tooltip: 'Swap languages'),
          IconButton(icon: const Icon(Icons.clear_all), onPressed: clearAll, tooltip: 'Clear'),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)]),
        ),
        child: Column(
          children: [
            // Source language selector
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _buildLanguageSelector('Source', _sourceLang, (v) => setState(() { _sourceLang = v; _selectedSourceLang = v; })),
            ),
            // Source text input with microphone
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _sourceController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Enter text or use microphone...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: _sourceController.text.isNotEmpty
                            ? IconButton(icon: const Icon(Icons.clear, color: Colors.white38), onPressed: () => setState(() => _sourceController.clear()))
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.blue),
                            onPressed: _isListening ? _stopListening : _startListening,
                            tooltip: _isListening ? 'Stop listening' : 'Start listening',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Translate button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _sourceController.text.trim().isEmpty || _isLoading ? null : translate,
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.translate),
                  label: Text(_isLoading ? 'Translating...' : 'Translate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Target language selector
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _buildLanguageSelector('Target', _targetLang, (v) => setState(() { _targetLang = v; _selectedTargetLang = v; })),
            ),
            // Target text output with speaker and share
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _targetController,
                      maxLines: 4,
                      readOnly: true,
                      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Translation will appear here...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    if (_targetController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(_isSpeaking ? Icons.volume_up : Icons.volume_mute, color: Colors.green),
                              onPressed: _speakTranslation,
                              tooltip: 'Speak translation',
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.green),
                              onPressed: _shareTranslation,
                              tooltip: 'Share translation',
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.green),
                              onPressed: copyToClipboard,
                              tooltip: 'Copy translation',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Footer
            Text('Mirror Scription - Text Translation', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.2))),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(String label, String current, ValueChanged<String> onChanged) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: current,
                isExpanded: true,
                dropdownColor: const Color(0xFF1B2838),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: _languages.map((lang) {
                  return DropdownMenuItem(
                    value: lang['code'],
                    child: Text('${lang['native']} (${lang['name']})'),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

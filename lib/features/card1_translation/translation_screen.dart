import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';
import '../../services/ai_service.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  late stt.SpeechToText _speechToText;

  String _selectedLanguage = 'en';
  bool _isListening = false;
  bool _isTranslating = false;
  bool _hasTranslated = false;

  final Map<String, String> _languages = {
    'af': 'Afrikaans', 'sq': 'Albanian', 'am': 'Amharic', 'ar': 'العربية', 'hy': 'Armenian',
    'az': 'Azerbaijani', 'eu': 'Basque', 'be': 'Belarusian', 'bn': 'Bengali', 'bs': 'Bosnian',
    'bg': 'Bulgarian', 'ca': 'Catalan', 'ceb': 'Cebuano', 'ny': 'Chichewa', 'zh': '中文',
    'co': 'Corsican', 'hr': 'Croatian', 'cs': 'Czech', 'da': 'Danish', 'nl': 'Dutch',
    'en': 'English', 'eo': 'Esperanto', 'et': 'Estonian', 'tl': 'Filipino', 'fi': 'Finnish',
    'fr': 'Français', 'fy': 'Frisian', 'gl': 'Galician', 'ka': 'Georgian', 'de': 'Deutsch',
    'el': 'Greek', 'gu': 'Gujarati', 'ht': 'Haitian Creole', 'ha': 'Hausa', 'haw': 'Hawaiian',
    'iw': 'Hebrew', 'hi': 'Hindi', 'hmn': 'Hmong', 'hu': 'Hungarian', 'is': 'Icelandic',
    'ig': 'Igbo', 'id': 'Indonesian', 'ga': 'Irish', 'it': 'Italiano', 'ja': '日本語',
    'jw': 'Javanese', 'kn': 'Kannada', 'kk': 'Kazakh', 'km': 'Khmer', 'ko': '한국어',
    'ku': 'Kurdish', 'ky': 'Kyrgyz', 'lo': 'Lao', 'la': 'Latin', 'lv': 'Latvian',
    'lt': 'Lithuanian', 'lb': 'Luxembourgish', 'mk': 'Macedonian', 'mg': 'Malagasy', 'ms': 'Malay',
    'ml': 'Malayalam', 'mt': 'Maltese', 'mi': 'Maori', 'mr': 'Marathi', 'mn': 'Mongolian',
    'my': 'Myanmar', 'ne': 'Nepali', 'no': 'Norwegian', 'ps': 'Pashto', 'fa': 'Persian',
    'pl': 'Polish', 'pt': 'Português', 'pa': 'Punjabi', 'ro': 'Romanian', 'ru': 'Русский',
    'sm': 'Samoan', 'gd': 'Scots Gaelic', 'sr': 'Serbian', 'st': 'Sesotho', 'sn': 'Shona',
    'sd': 'Sindhi', 'si': 'Sinhala', 'sk': 'Slovak', 'sl': 'Slovenian', 'so': 'Somali',
    'es': 'Español', 'su': 'Sundanese', 'sw': 'Swahili', 'sv': 'Swedish', 'tg': 'Tajik',
    'ta': 'Tamil', 'te': 'Telugu', 'th': 'Thai', 'tr': 'Türkçe', 'uk': 'Ukrainian',
    'ur': 'Urdu', 'uz': 'Uzbek', 'vi': 'Vietnamese', 'cy': 'Welsh', 'xh': 'Xhosa',
    'yi': 'Yiddish', 'yo': 'Yoruba', 'zu': 'Zulu',
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _translatedController.dispose();
    super.dispose();
  }

  Future<void> _handleMic() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      _translate();
    } else {
      _onMicStart();
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() => _sourceController.text = result.recognizedWords);
            if (result.finalResult) {
              setState(() => _isListening = false);
              _translate();
            }
          },
        );
      }
    }
  }

  void _onSourceChanged(String value) {
    // Clear both if keyboard or mic is used after translation as requested
    if (_hasTranslated && value.isNotEmpty) {
      _translatedController.clear();
      setState(() => _hasTranslated = false);
    }
  }

  void _onMicStart() {
    // If user clicks mic after translation, clear both editors
    if (_hasTranslated) {
      _sourceController.clear();
      _translatedController.clear();
      setState(() => _hasTranslated = false);
    }
  }

  Future<void> _translate() async {
    if (_sourceController.text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$_selectedLanguage&dt=t&q=${Uri.encodeComponent(_sourceController.text)}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        setState(() {
          _translatedController.text = translated;
          _hasTranslated = true;
        });
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    setState(() => _isTranslating = false);
  }

  void _shareAudio() {
    if (_translatedController.text.isEmpty) return;
    final signature = "\n\n── تمت الترجمة بواسطة ميرور سكربيون ──\n🦂 Mirror Scorpion | حيث تُصنع البدايات";
    final content = _translatedController.text + signature;
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الترجمة مع توقيع التطبيق للمشاركة'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _copyText() {
    if (_translatedController.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ النص المترجم')),
    );
  }

  void _speakTranslation() {
    if (_translatedController.text.isNotEmpty) {
      Provider.of<TTSService>(context, listen: false)
          .speak(_translatedController.text, language: _selectedLanguage);
    }
  }

  void _showManusAI() async {
    final inspiration = await AIService.generateInspiration(
      userMood: _sourceController.text,
      context: 'Translation Screen',
    );
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber),
            SizedBox(width: 10),
            Expanded(child: Text('مساعد الذكاء الصناعي', style: TextStyle(color: Colors.amber, fontSize: 16))),
          ],
        ),
        backgroundColor: const Color(0xFF1B2838),
        content: Text(inspiration, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showManusAI,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.auto_awesome, color: Colors.black),
      ),
      appBar: AppBar(
        title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Language Selector centered at top
              Center(
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1B2838),
                      icon: const Icon(Icons.language, color: Colors.blueAccent),
                      items: _languages.entries.map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      )).toList(),
                      onChanged: (v) {
                        setState(() => _selectedLanguage = v!);
                        if (_sourceController.text.isNotEmpty) _translate();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Source Editor
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _sourceController,
                      maxLines: 6,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: 'اكتب النص هنا أو استخدم المايك...',
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                      onChanged: _onSourceChanged,
                    ),
                    Row(
                      children: [
                        // Mic on the left bottom as requested
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.stop_circle : Icons.mic,
                            color: _isListening ? Colors.redAccent : Colors.blueAccent,
                            size: 32,
                          ),
                          onPressed: _handleMic,
                        ),
                        const Spacer(),
                        if (_sourceController.text.isNotEmpty)
                          TextButton.icon(
                            icon: const Icon(Icons.translate, color: Colors.amber, size: 20),
                            label: const Text('ترجم', style: TextStyle(color: Colors.amber)),
                            onPressed: _translate,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Loading indicator
              if (_isTranslating)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2),
                ),

              // Translated Editor
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _translatedController,
                      maxLines: 6,
                      readOnly: true,
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        hintText: 'الترجمة ستظهر هنا...',
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Copy (no watermark) - leftmost
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white70, size: 22),
                          onPressed: _copyText,
                          tooltip: 'نسخ بدون توقيع',
                        ),
                        const Spacer(),
                        // Share (next to speaker)
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.greenAccent, size: 24),
                          onPressed: _shareAudio,
                          tooltip: 'مشاركة مع التوقيع',
                        ),
                        // Speaker (far right)
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.blueAccent, size: 26),
                          onPressed: _speakTranslation,
                          tooltip: 'نطق الترجمة',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Opacity(
                opacity: 0.3,
                child: Text(
                  "Mirror Scorpion Translate",
                  style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

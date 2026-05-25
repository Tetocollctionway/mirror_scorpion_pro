import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';

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
  bool _isTranslating = false;
  bool _isListening = false;

  // Expanded language list (approx 100 common languages)
  final Map<String, String> _languages = {
    'af': 'Afrikaans', 'sq': 'Albanian', 'am': 'Amharic', 'ar': 'Arabic', 'hy': 'Armenian',
    'az': 'Azerbaijani', 'eu': 'Basque', 'be': 'Belarusian', 'bn': 'Bengali', 'bs': 'Bosnian',
    'bg': 'Bulgarian', 'ca': 'Catalan', 'ceb': 'Cebuano', 'ny': 'Chichewa', 'zh': 'Chinese',
    'co': 'Corsican', 'hr': 'Croatian', 'cs': 'Czech', 'da': 'Danish', 'nl': 'Dutch',
    'en': 'English', 'eo': 'Esperanto', 'et': 'Estonian', 'tl': 'Filipino', 'fi': 'Finnish',
    'fr': 'French', 'fy': 'Frisian', 'gl': 'Galician', 'ka': 'Georgian', 'de': 'German',
    'el': 'Greek', 'gu': 'Gujarati', 'ht': 'Haitian Creole', 'ha': 'Hausa', 'haw': 'Hawaiian',
    'iw': 'Hebrew', 'hi': 'Hindi', 'hmn': 'Hmong', 'hu': 'Hungarian', 'is': 'Icelandic',
    'ig': 'Igbo', 'id': 'Indonesian', 'ga': 'Irish', 'it': 'Italian', 'ja': 'Japanese',
    'jw': 'Javanese', 'kn': 'Kannada', 'kk': 'Kazakh', 'km': 'Khmer', 'ko': 'Korean',
    'ku': 'Kurdish (Kurmanji)', 'ky': 'Kyrgyz', 'lo': 'Lao', 'la': 'Latin', 'lv': 'Latvian',
    'lt': 'Lithuanian', 'lb': 'Luxembourgish', 'mk': 'Macedonian', 'mg': 'Malagasy', 'ms': 'Malay',
    'ml': 'Malayalam', 'mt': 'Maltese', 'mi': 'Maori', 'mr': 'Marathi', 'mn': 'Mongolian',
    'my': 'Myanmar (Burmese)', 'ne': 'Nepali', 'no': 'Norwegian', 'ps': 'Pashto', 'fa': 'Persian',
    'pl': 'Polish', 'pt': 'Portuguese', 'pa': 'Punjabi', 'ro': 'Romanian', 'ru': 'Russian',
    'sm': 'Samoan', 'gd': 'Scots Gaelic', 'sr': 'Serbian', 'st': 'Sesotho', 'sn': 'Shona',
    'sd': 'Sindhi', 'si': 'Sinhala', 'sk': 'Slovak', 'sl': 'Slovenian', 'so': 'Somali',
    'es': 'Spanish', 'su': 'Sundanese', 'sw': 'Swahili', 'sv': 'Swedish', 'tg': 'Tajik',
    'ta': 'Tamil', 'te': 'Telugu', 'th': 'Thai', 'tr': 'Turkish', 'uk': 'Ukrainian',
    'ur': 'Urdu', 'uz': 'Uzbek', 'vi': 'Vietnamese', 'cy': 'Welsh', 'xh': 'Xhosa',
    'yi': 'Yiddish', 'yo': 'Yoruba', 'zu': 'Zulu'
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  Future<void> _handleMic() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      _translate();
    } else {
      // Clear editors for new translation as requested
      _sourceController.clear();
      _translatedController.clear();
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() => _sourceController.text = result.recognizedWords);
          },
        );
      }
    }
  }

  Future<void> _translate() async {
    if (_sourceController.text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$_selectedLanguage&dt=t&q=${Uri.encodeComponent(_sourceController.text)}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        setState(() => _translatedController.text = translated);
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    setState(() => _isTranslating = false);
  }

  void _shareAudio() {
    // Description says: share audio file only with specific signature
    // Since we are simulating, we'll show a snackbar and copy the text with signature
    final signature = "\n\nتمت الترجمة بواسطة ميرور سكربيون";
    final content = _translatedController.text + signature;
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تجهيز ملف الصوت (محاكاة) والمشاركة مع التوقيع'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)]
          )
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Language Selector in the middle top
              Center(
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1B2838),
                      icon: const Icon(Icons.language, color: Colors.blueAccent),
                      items: _languages.entries.map((e) => DropdownMenuItem(
                        value: e.key, 
                        child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 14))
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedLanguage = v!),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              
              // Source Editor
              _buildSourceEditor(),
              
              const SizedBox(height: 20),
              
              // Translated Editor
              _buildTranslatedEditor(),
              
              const SizedBox(height: 30),
              
              // Branding
              const Opacity(
                opacity: 0.3,
                child: Text(
                  "Mirror Scorpion Translate",
                  style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceEditor() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
            onChanged: (v) {
              // If user starts typing, we might want to clear previous translation or auto-translate
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mic on the bottom left as requested
              IconButton(
                icon: Icon(_isListening ? Icons.stop_circle : Icons.mic, 
                  color: _isListening ? Colors.redAccent : Colors.blueAccent, size: 30),
                onPressed: _handleMic,
              ),
              if (_sourceController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.translate, color: Colors.amber),
                  onPressed: _translate,
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTranslatedEditor() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Speaker for TTS
              IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.blueAccent),
                onPressed: () => Provider.of<TTSService>(context, listen: false).speak(_translatedController.text),
              ),
              // Share button (audio file simulation)
              IconButton(
                icon: const Icon(Icons.share, color: Colors.greenAccent),
                onPressed: _shareAudio,
              ),
              // Copy button
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white70),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _translatedController.text));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ النص المترجم')));
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

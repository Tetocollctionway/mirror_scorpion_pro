import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';

class DialogueTranslationScreen extends StatefulWidget {
  const DialogueTranslationScreen({super.key});

  @override
  State<DialogueTranslationScreen> createState() => _DialogueTranslationScreenState();
}

class _DialogueTranslationScreenState extends State<DialogueTranslationScreen> {
  final TextEditingController _upperController = TextEditingController();
  final TextEditingController _lowerController = TextEditingController();
  late stt.SpeechToText _speechToText;

  String _rightLang = 'ar';
  String _leftLang = 'en';
  bool _isListening = false;
  bool _isTranslating = false;

  final Map<String, String> _languages = {
    'af': 'Afrikaans', 'sq': 'Albanian', 'am': 'Amharic', 'ar': 'العربية',
    'hy': 'Armenian', 'az': 'Azerbaijani', 'eu': 'Basque', 'be': 'Belarusian',
    'bn': 'Bengali', 'bs': 'Bosnian', 'bg': 'Bulgarian', 'ca': 'Catalan',
    'zh': '中文', 'hr': 'Croatian', 'cs': 'Czech', 'da': 'Danish',
    'nl': 'Dutch', 'en': 'English', 'et': 'Estonian', 'fi': 'Finnish',
    'fr': 'Français', 'ka': 'Georgian', 'de': 'Deutsch', 'el': 'Greek',
    'gu': 'Gujarati', 'hi': 'Hindi', 'hu': 'Hungarian', 'is': 'Icelandic',
    'id': 'Indonesian', 'ga': 'Irish', 'it': 'Italiano', 'ja': '日本語',
    'kn': 'Kannada', 'kk': 'Kazakh', 'ko': '한국어', 'ku': 'Kurdish',
    'lv': 'Latvian', 'lt': 'Lithuanian', 'mk': 'Macedonian', 'ms': 'Malay',
    'ml': 'Malayalam', 'mt': 'Maltese', 'mr': 'Marathi', 'mn': 'Mongolian',
    'ne': 'Nepali', 'no': 'Norwegian', 'ps': 'Pashto', 'fa': 'Persian',
    'pl': 'Polish', 'pt': 'Português', 'pa': 'Punjabi', 'ro': 'Romanian',
    'ru': 'Русский', 'sr': 'Serbian', 'sk': 'Slovak', 'sl': 'Slovenian',
    'so': 'Somali', 'es': 'Español', 'sw': 'Swahili', 'sv': 'Swedish',
    'ta': 'Tamil', 'te': 'Telugu', 'th': 'Thai', 'tr': 'Türkçe',
    'uk': 'Ukrainian', 'ur': 'Urdu', 'uz': 'Uzbek', 'vi': 'Vietnamese',
    'cy': 'Welsh', 'xh': 'Xhosa', 'yi': 'Yiddish', 'yo': 'Yoruba', 'zu': 'Zulu',
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  @override
  void dispose() {
    _upperController.dispose();
    _lowerController.dispose();
    super.dispose();
  }

  Future<void> _handleMic() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      _translate();
    } else {
      // Clear both when starting new translation as requested
      _upperController.clear();
      _lowerController.clear();
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() => _upperController.text = result.recognizedWords);
            if (result.finalResult) {
              setState(() => _isListening = false);
              _translate();
            }
          },
          localeId: _rightLang,
        );
      }
    }
  }

  Future<void> _translate() async {
    if (_upperController.text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$_rightLang&tl=$_leftLang&dt=t&q=${Uri.encodeComponent(_upperController.text)}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        setState(() => _lowerController.text = translated);
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    setState(() => _isTranslating = false);
  }

  void _swapLanguages() {
    setState(() {
      final temp = _rightLang;
      _rightLang = _leftLang;
      _leftLang = temp;
      _upperController.clear();
      _lowerController.clear();
    });
  }

  void _speakTranslation() {
    if (_lowerController.text.isNotEmpty) {
      Provider.of<TTSService>(context, listen: false)
          .speak(_lowerController.text, language: _leftLang);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حوار مترجم',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Upper Editor (source - uses right button language)
                Expanded(
                  flex: 4,
                  child: _buildEditor(
                    controller: _upperController,
                    hint: 'الكلام الملتقط من المايك يظهر هنا...',
                    isSource: true,
                  ),
                ),

                const SizedBox(height: 10),

                // Language selectors + mic + swap
                _buildControlsRow(),

                const SizedBox(height: 10),

                // Lower Editor (translated - uses left button language)
                Expanded(
                  flex: 4,
                  child: _buildEditor(
                    controller: _lowerController,
                    hint: 'الترجمة تظهر هنا...',
                    isSource: false,
                  ),
                ),

                const SizedBox(height: 12),

                // Branding
                Opacity(
                  opacity: 0.3,
                  child: Text(
                    "Mirror Scorpion Dialogue",
                    style: TextStyle(
                        color: Colors.white, letterSpacing: 2, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor({
    required TextEditingController controller,
    required String hint,
    required bool isSource,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              readOnly: !isSource,
              style: const TextStyle(color: Colors.white, fontSize: 22),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),
          if (!isSource)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isTranslating)
                  const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.blueAccent, strokeWidth: 2),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.volume_up,
                      color: Colors.blueAccent, size: 28),
                  onPressed: _speakTranslation,
                  tooltip: 'نطق الترجمة',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildControlsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right language button (source)
          Expanded(
            child: _buildLangButton(_rightLang, (v) {
              setState(() => _rightLang = v!);
            }),
          ),

          // Swap
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: Colors.amber, size: 28),
            onPressed: _swapLanguages,
            tooltip: 'تبديل اللغات',
          ),

          // Mic
          GestureDetector(
            onTap: _handleMic,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isListening ? Colors.redAccent : Colors.blueAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : Colors.blue)
                        .withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white, size: 28,
              ),
            ),
          ),

          // Left language button (target)
          Expanded(
            child: _buildLangButton(_leftLang, (v) {
              setState(() => _leftLang = v!);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1B2838),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
          items: _languages.entries.map((e) {
            return DropdownMenuItem(
              value: e.key,
              child: Text(e.value,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

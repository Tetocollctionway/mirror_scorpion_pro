import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/theme/app_theme.dart';
import '../../services/ai_service.dart';
import '../../services/tts_service.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> with WidgetsBindingObserver {
  // ── Text Controllers ──
  final TextEditingController _upperController = TextEditingController();
  final TextEditingController _lowerController = TextEditingController();
  final FocusNode _upperFocusNode = FocusNode();

  // ── Speech ──
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // ── Language state ──
  // IMPORTANT: The UPPER editor ALWAYS uses the language in the RIGHT button.
  // The LOWER editor uses the language in the LEFT button.
  String _rightLanguage = 'en';  // Source language (right button)
  String _leftLanguage = 'ar';   // Target language (left button)

  bool _isTranslating = false;

  // ── Animation for mic pulse ──
  bool _micPressed = false;

  // ── 100 languages ──
  static const List<Map<String, String>> _languages = [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'it', 'name': 'Italiano'},
    {'code': 'pt', 'name': 'Português'},
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'zh', 'name': '中文'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'ko', 'name': '한국어'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'ur', 'name': 'اردو'},
    {'code': 'fa', 'name': 'فارسی'},
    {'code': 'hi', 'name': 'हिन्दी'},
    {'code': 'bn', 'name': 'বাংলা'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
    {'code': 'ms', 'name': 'Bahasa Melayu'},
    {'code': 'sw', 'name': 'Kiswahili'},
    {'code': 'ha', 'name': 'Hausa'},
    {'code': 'ta', 'name': 'தமிழ்'},
    {'code': 'te', 'name': 'తెలుగు'},
    {'code': 'th', 'name': 'ไทย'},
    {'code': 'vi', 'name': 'Tiếng Việt'},
    {'code': 'nl', 'name': 'Nederlands'},
    {'code': 'pl', 'name': 'Polski'},
    {'code': 'uk', 'name': 'Українська'},
    {'code': 'el', 'name': 'Ελληνικά'},
    {'code': 'he', 'name': 'עברית'},
    {'code': 'ku', 'name': 'Kurdî'},
    {'code': 'am', 'name': 'አማርኛ'},
    {'code': 'ps', 'name': 'پښتو'},
    {'code': 'sd', 'name': 'سنڌي'},
    {'code': 'ckb', 'name': 'کوردیی ناوەندی'},
    {'code': 'bal', 'name': 'بلوچی'},
    {'code': 'lrc', 'name': 'لری'},
    {'code': 'acm', 'name': 'عراقي'},
    {'code': 'apc', 'name': 'شامي'},
    {'code': 'ayn', 'name': 'صنعاني'},
    {'code': 'acq', 'name': 'خليجي'},
    {'code': 'esu', 'name': 'Yup\'ik'},
    {'code': 'yua', 'name': 'Yucatec Maya'},
    {'code': 'quc', 'name': 'K\'iche\''},
    {'code': 'nah', 'name': 'Nāhuatl'},
    {'code': 'arn', 'name': 'Mapudungun'},
    {'code': 'ayr', 'name': 'Aymara'},
    {'code': 'qu', 'name': 'Quechua'},
    {'code': 'gn', 'name': 'Guarani'},
    {'code': 'sr', 'name': 'Српски'},
    {'code': 'hr', 'name': 'Hrvatski'},
    {'code': 'bs', 'name': 'Bosanski'},
    {'code': 'mk', 'name': 'Македонски'},
    {'code': 'sq', 'name': 'Shqip'},
    {'code': 'hy', 'name': 'Հայերեն'},
    {'code': 'ka', 'name': 'ქართული'},
    {'code': 'ro', 'name': 'Română'},
    {'code': 'bg', 'name': 'Български'},
    {'code': 'cs', 'name': 'Čeština'},
    {'code': 'sk', 'name': 'Slovenčina'},
    {'code': 'sl', 'name': 'Slovenščina'},
    {'code': 'hu', 'name': 'Magyar'},
    {'code': 'et', 'name': 'Eesti'},
    {'code': 'lv', 'name': 'Latviešu'},
    {'code': 'lt', 'name': 'Lietuvių'},
    {'code': 'fi', 'name': 'Suomi'},
    {'code': 'sv', 'name': 'Svenska'},
    {'code': 'no', 'name': 'Norsk'},
    {'code': 'da', 'name': 'Dansk'},
    {'code': 'is', 'name': 'Íslenska'},
    {'code': 'ga', 'name': 'Gaeilge'},
    {'code': 'cy', 'name': 'Cymraeg'},
    {'code': 'gd', 'name': 'Gàidhlig'},
    {'code': 'mt', 'name': 'Malti'},
    {'code': 'af', 'name': 'Afrikaans'},
    {'code': 'xh', 'name': 'isiXhosa'},
    {'code': 'zu', 'name': 'isiZulu'},
    {'code': 'st', 'name': 'Sesotho'},
    {'code': 'tn', 'name': 'Setswana'},
    {'code': 'ts', 'name': 'Xitsonga'},
    {'code': 'ss', 'name': 'SiSwati'},
    {'code': 've', 'name': 'Tshivenḓa'},
    {'code': 'nr', 'name': 'isiNdebele'},
    {'code': 'ny', 'name': 'Chichewa'},
    {'code': 'mg', 'name': 'Malagasy'},
    {'code': 'wo', 'name': 'Wolof'},
    {'code': 'yo', 'name': 'Yorùbá'},
    {'code': 'ig', 'name': 'Igbo'},
    {'code': 'om', 'name': 'Oromoo'},
    {'code': 'so', 'name': 'Soomaali'},
    {'code': 'rw', 'name': 'Kinyarwanda'},
    {'code': 'rn', 'name': 'Ikirundi'},
    {'code': 'sn', 'name': 'chiShona'},
    {'code': 'sg', 'name': 'Sängö'},
    {'code': 'lg', 'name': 'Luganda'},
    {'code': 'ti', 'name': 'ትግርኛ'},
    {'code': 'dz', 'name': 'རྫོང་ཁ'},
    {'code': 'my', 'name': 'မြန်မာဘာသာ'},
    {'code': 'km', 'name': 'ភាសាខ្មែរ'},
    {'code': 'lo', 'name': 'ລາວ'},
    {'code': 'si', 'name': 'සිංහල'},
    {'code': 'ne', 'name': 'नेपाली'},
    {'code': 'ml', 'name': 'മലയാളം'},
    {'code': 'gu', 'name': 'ગુજરાતી'},
    {'code': 'pa', 'name': 'ਪੰਜਾਬੀ'},
    {'code': 'or', 'name': 'ଓଡ଼ିଆ'},
    {'code': 'mr', 'name': 'मराठी'},
    {'code': 'as', 'name': 'অসমীয়া'},
    {'code': 'ks', 'name': 'कॉशुर'},
    {'code': 'sa', 'name': 'संस्कृतम्'},
    {'code': 'bo', 'name': 'བོད་སྐད'},
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // Keyboard tap → clear both editors
    _upperFocusNode.addListener(() {
      if (_upperFocusNode.hasFocus) {
        _clearEditors();
      }
    });
  }

  @override
  void dispose() {
    _upperController.dispose();
    _lowerController.dispose();
    _upperFocusNode.dispose();
    _speech.stop();
    super.dispose();
  }

  String _getLangName(String code) {
    for (final l in _languages) {
      if (l['code'] == code) return l['name']!;
    }
    return code;
  }

  void _clearEditors() {
    _upperController.clear();
    _lowerController.clear();
  }

  // ── Mic: press-and-hold ──
  Future<void> _startListening() async {
    _clearEditors();

    final available = await _speech.initialize(
      onError: (e) => debugPrint('Speech error: $e'),
      onStatus: (s) {
        if (s == 'done') {
          setState(() => _isListening = false);
          // Auto-translate after speech ends
          if (_upperController.text.trim().isNotEmpty) {
            _performTranslation();
          }
        }
      },
    );

    if (available) {
      setState(() => _isListening = true);

      // ✅ The UPPER editor always uses the RIGHT language for speech input
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _upperController.text = result.recognizedWords;
          });
        },
        localeId: _rightLanguage,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  // ── Translation: upper (source) → lower (target) ──
  Future<void> _performTranslation() async {
    if (_upperController.text.trim().isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final ai = Provider.of<AIService>(context, listen: false);
      // Upper editor uses RIGHT language (source).
      // Lower editor uses LEFT language (target).
      final translated = await ai.translate(
        text: _upperController.text,
        fromLanguage: _rightLanguage,
        toLanguage: _leftLanguage,
      );

      setState(() {
        _lowerController.text = translated;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() => _isTranslating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ في الترجمة')),
      );
    }
  }

  // ── Speaker for lower (translation) ──
  Future<void> _speakTranslation() async {
    if (_lowerController.text.isEmpty) return;
    final tts = Provider.of<TTSService>(context, listen: false);
    await tts.speak(_lowerController.text, language: _leftLanguage);
  }

  // ── Copy translation ──
  void _copyTranslation() {
    if (_lowerController.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _lowerController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الترجمة'), duration: Duration(seconds: 2)),
    );
  }

  // ── Swap languages (right ↔ left) ──
  void _swapLanguages() {
    setState(() {
      final temp = _rightLanguage;
      _rightLanguage = _leftLanguage;
      _leftLanguage = temp;

      // Swap text as well
      final tempText = _upperController.text;
      _upperController.text = _lowerController.text;
      _lowerController.text = tempText;
    });
  }

  bool _isRtl(String code) {
    return ['ar', 'fa', 'ur', 'he', 'ku', 'ps', 'sd', 'ckb', 'bal', 'lrc', 'acm', 'apc', 'ayn', 'acq']
        .contains(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حوار مترجم'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _swapLanguages,
            tooltip: 'تبديل اللغات',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── LANGUAGE BAR ────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LEFT button – TARGET language (lower editor uses this)
                  Expanded(
                    child: _buildLangButton(
                      code: _leftLanguage,
                      label: 'إلى',
                      color: Theme.of(context).colorScheme.tertiary,
                      onChanged: (v) => setState(() => _leftLanguage = v),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // SWAP arrow
                  GestureDetector(
                    onTap: _swapLanguages,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // RIGHT button – SOURCE language (upper editor always uses this)
                  Expanded(
                    child: _buildLangButton(
                      code: _rightLanguage,
                      label: 'من',
                      color: Theme.of(context).colorScheme.primary,
                      onChanged: (v) => setState(() => _rightLanguage = v),
                    ),
                  ),
                ],
              ),
            ),

            // ── UPPER EDITOR (source — listens only to RIGHT language) ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label showing which language this editor uses
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getLangName(_rightLanguage),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: TextField(
                            controller: _upperController,
                            focusNode: _upperFocusNode,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            textDirection: _isRtl(_rightLanguage) ? TextDirection.rtl : TextDirection.ltr,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'المتحدث...',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            onChanged: (_) => _performTranslation(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── MIC + SWAP row (between editors) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── MIC BUTTON (large, press-and-hold) ──
                  GestureDetector(
                    onTapDown: (_) => _startListening(),
                    onTapUp: (_) => _stopListening(),
                    onTapCancel: _stopListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? Colors.red.withOpacity(0.15)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── LOWER EDITOR (translation result) ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ترجمة (${_getLangName(_leftLanguage)})',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: _isTranslating
                              ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                              : TextField(
                                  controller: _lowerController,
                                  maxLines: null,
                                  expands: true,
                                  readOnly: true,
                                  textDirection: _isRtl(_leftLanguage) ? TextDirection.rtl : TextDirection.ltr,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'الترجمة...',
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                ),
                        ),

                        // ── BOTTOM ACTIONS (speaker only, per spec) ──
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Speaker
                              GestureDetector(
                                onTap: _speakTranslation,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.volume_up, size: 20, color: Theme.of(context).colorScheme.tertiary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Copy
                              GestureDetector(
                                onTap: _copyTranslation,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.copy, size: 20, color: Theme.of(context).colorScheme.tertiary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Reusable language dropdown button ──
  Widget _buildLangButton({
    required String code,
    required String label,
    required Color color,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: code,
          isExpanded: true,
          icon: Icon(Icons.language, size: 18, color: color),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
          items: _languages.map((l) {
            return DropdownMenuItem(value: l['code'], child: Text(l['name']!, overflow: TextOverflow.ellipsis));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

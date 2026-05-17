import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_mlkit_digital_ink/google_mlkit_digital_ink.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../services/ai_service.dart';
import '../../services/tts_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> with TickerProviderStateMixin {
  // Text Controllers
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final FocusNode _sourceFocusNode = FocusNode();

  // Language state
  String _sourceLanguage = 'en';
  String _targetLanguage = 'ar';
  bool _isRecording = false;
  bool _isTranslating = false;
  
  // Speech to Text
  late stt.SpeechToText _speech;
  
  // Digital Ink (handwriting)
  final DigitalInkRecognizer _inkRecognizer = DigitalInkRecognizer();

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Language list (100 languages)
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
    
    // Pulse animation for mic
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen for keyboard/mic to clear
    _sourceFocusNode.addListener(() {
      if (_sourceFocusNode.hasFocus) {
        _clearAll();
      }
    });
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    _sourceFocusNode.dispose();
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  String _getLanguageName(String code) {
    for (final lang in _languages) {
      if (lang['code'] == code) return lang['name']!;
    }
    return code;
  }

  void _clearAll() {
    _sourceController.clear();
    _targetController.clear();
  }

  Future<void> _startListening() async {
    _clearAll();
    
    bool available = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isRecording = false);
        }
      },
    );

    if (available) {
      setState(() => _isRecording = true);
      
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _sourceController.text = result.recognizedWords;
          });
        },
        localeId: _sourceLanguage,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isRecording = false);
    
    // Automatically start translation
    if (_sourceController.text.isNotEmpty) {
      _performTranslation();
    }
  }

  Future<void> _performTranslation() async {
    if (_sourceController.text.isEmpty) return;
    
    setState(() => _isTranslating = true);
    
    try {
      final aiService = Provider.of<AIService>(context, listen: false);
      final translated = await aiService.translate(
        text: _sourceController.text,
        fromLanguage: _sourceLanguage,
        toLanguage: _targetLanguage,
      );
      
      setState(() {
        _targetController.text = translated;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() => _isTranslating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ في الترجمة')),
      );
    }
  }

  Future<void> _speakTranslation() async {
    if (_targetController.text.isEmpty) return;
    
    final ttsService = Provider.of<TTSService>(context, listen: false);
    await ttsService.speak(
      _targetController.text,
      language: _targetLanguage,
    );
  }

  Future<void> _shareAudio() async {
    if (_targetController.text.isEmpty) return;
    
    // Share audio file with app signature
    final text = '$_targetController.text\n\nتمت الترجمة بواسطة Mirror Scription';
    
    // Use share_plus to share
    await Share.share(text, subject: 'Mirror Scription Translation');
  }

  void _copyTranslation() {
    if (_targetController.text.isEmpty) return;
    
    Clipboard.setData(ClipboardData(text: _targetController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الترجمة'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
      
      final tempText = _sourceController.text;
      _sourceController.text = _targetController.text;
      _targetController.text = tempText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترجمة نصية'),
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
            // ---------- LANGUAGE SELECTOR ----------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Source language selector
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sourceLanguage,
                          isExpanded: true,
                          icon: const Icon(Icons.language, size: 20),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          items: _languages.map((lang) {
                            return DropdownMenuItem(
                              value: lang['code'],
                              child: Text(
                                lang['name']!,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _sourceLanguage = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // Swap button
                  GestureDetector(
                    onTap: _swapLanguages,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  
                  // Target language selector
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _targetLanguage,
                          isExpanded: true,
                          icon: const Icon(Icons.language, size: 20),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          items: _languages.map((lang) {
                            return DropdownMenuItem(
                              value: lang['code'],
                              child: Text(
                                lang['name']!,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _targetLanguage = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------- SOURCE TEXT EDITOR ----------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.translate,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getLanguageName(_sourceLanguage),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: TextField(
                            controller: _sourceController,
                            focusNode: _sourceFocusNode,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            textDirection: _isArabic(_sourceLanguage)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'اكتب أو تكلم...',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onChanged: (_) => _performTranslation(),
                          ),
                        ),
                        
                        // MIC BUTTON at bottom left
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: GestureDetector(
                            onTapDown: (_) => _startListening(),
                            onTapUp: (_) => _stopListening(),
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _isRecording ? _pulseAnimation.value : 1.0,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _isRecording
                                          ? Colors.red.withOpacity(0.15)
                                          : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      _isRecording ? Icons.mic : Icons.mic_none,
                                      color: _isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ---------- TRANSLATION RESULT EDITOR ----------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.g_translate,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ترجمة (${_getLanguageName(_targetLanguage)})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _isTranslating
                              ? const Center(child: CircularProgressIndicator())
                              : TextField(
                                  controller: _targetController,
                                  maxLines: null,
                                  expands: true,
                                  readOnly: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  textDirection: _isArabic(_targetLanguage)
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'الترجمة ستظهر هنا...',
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                        ),

                        // ---------- BOTTOM ACTIONS ----------
                        Align(
                          alignment: Alignment.bottomRight,
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
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.volume_up,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Share
                              GestureDetector(
                                onTap: _shareAudio,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.share,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
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
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.copy,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
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
            
            // Spacing for bottom safe area
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  bool _isArabic(String lang) {
    return ['ar', 'fa', 'ur', 'he', 'ku', 'ps', 'sd', 'ckb', 'bal', 'lrc', 'acm', 'apc', 'ayn', 'acq'].contains(lang);
  }
}

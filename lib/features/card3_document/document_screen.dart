import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../core/theme/app_theme.dart';
import '../../services/ai_service.dart';
import '../../services/tts_service.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> with TickerProviderStateMixin {
  // ── Tabs ──
  late TabController _tabController;

  // ── Image state ──
  File? _selectedImage;

  // ── OCR state ──
  String _extractedText = '';
  String _translatedText = '';
  bool _isProcessing = false;
  bool _isTranslating = false;

  // ── Language ──
  String _sourceLanguage = 'auto';
  String _targetLanguage = 'ar';

  // ── Camera preview ──
  bool _cameraActive = false;
  bool _capturedFromCamera = false;

  // ── 100 languages (same list as Card 2) ──
  static const List<Map<String, String>> _languages = [
    {'code': 'auto', 'name': 'كشف تلقائي'},
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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _cameraActive = _tabController.index == 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getLangName(String code) {
    for (final l in _languages) {
      if (l['code'] == code) return l['name']!;
    }
    return code;
  }

  // ── Tab 1: Pick document from file system ──
  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _capturedFromCamera = false;
        _extractedText = '';
        _translatedText = '';
      });
      await _performOCR();
    }
  }

  // ── Tab 2: Camera capture ──
  Future<void> _captureFromCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _capturedFromCamera = true;
        _extractedText = '';
        _translatedText = '';
      });
      await _performOCR();
    }
  }

  // ── Tab 3: Pick from gallery ──
  Future<void> _pickFromGallery() async {
    await _pickDocument(); // Same logic
  }

  // ── OCR processing ──
  Future<void> _performOCR() async {
    if (_selectedImage == null) return;

    setState(() => _isProcessing = true);

    try {
      final inputImage = InputImage.fromFile(_selectedImage!);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText result = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      setState(() {
        _extractedText = result.text;
        _isProcessing = false;
      });

      if (_extractedText.trim().isNotEmpty) {
        await _translateExtracted();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل التعرف على النص. حاول مرة أخرى.')),
        );
      }
    }
  }

  // ── Translation ──
  Future<void> _translateExtracted() async {
    if (_extractedText.trim().isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final ai = Provider.of<AIService>(context, listen: false);
      final source = _sourceLanguage == 'auto' ? 'en' : _sourceLanguage;
      final translated = await ai.translate(
        text: _extractedText,
        fromLanguage: source,
        toLanguage: _targetLanguage,
      );

      setState(() {
        _translatedText = translated;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() => _isTranslating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ في الترجمة')),
        );
      }
    }
  }

  // ── Speaker ──
  Future<void> _speakTranslation() async {
    if (_translatedText.isEmpty) return;
    final tts = Provider.of<TTSService>(context, listen: false);
    await tts.speak(_translatedText, language: _targetLanguage);
  }

  // ── Copy ──
  void _copyTranslation() {
    if (_translatedText.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الترجمة'), duration: Duration(seconds: 2)),
    );
  }

  // ── Copy extracted text ──
  void _copyExtracted() {
    if (_extractedText.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ النص المستخرج'), duration: Duration(seconds: 2)),
    );
  }

  bool _isRtl(String code) {
    return ['ar', 'fa', 'ur', 'he', 'ku', 'ps', 'sd', 'ckb', 'bal', 'lrc', 'acm', 'apc', 'ayn', 'acq']
        .contains(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترجمة المستندات'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.description), text: 'مستند'),
            Tab(icon: Icon(Icons.camera_alt), text: 'كاميرا'),
            Tab(icon: Icon(Icons.photo_library), text: 'معرض'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDocumentTab(),
          _buildCameraTab(),
          _buildGalleryTab(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  TAB 1: Document (Pick from file system)
  // ═══════════════════════════════════════════════
  Widget _buildDocumentTab() {
    return _buildContentArea(
      floatingAction: FloatingActionButton.extended(
        onPressed: _pickDocument,
        icon: const Icon(Icons.folder_open),
        label: const Text('اختيار ملف'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  TAB 2: Camera (Live capture)
  // ═══════════════════════════════════════════════
  Widget _buildCameraTab() {
    return _buildContentArea(
      floatingAction: FloatingActionButton.extended(
        onPressed: _captureFromCamera,
        icon: const Icon(Icons.camera),
        label: const Text('التقاط صورة'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  TAB 3: Gallery
  // ═══════════════════════════════════════════════
  Widget _buildGalleryTab() {
    return _buildContentArea(
      floatingAction: FloatingActionButton.extended(
        onPressed: _pickFromGallery,
        icon: const Icon(Icons.photo_library),
        label: const Text('اختيار من المعرض'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Colors.white,
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Shared content area
  // ═══════════════════════════════════════════════
  Widget _buildContentArea({required Widget floatingAction}) {
    return Stack(
      children: [
        Column(
          children: [
            // ── Language Selectors ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Source language
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sourceLanguage,
                          isExpanded: true,
                          icon: const Icon(Icons.language, size: 18),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          items: _languages.map((l) {
                            return DropdownMenuItem(
                              value: l['code'],
                              child: Text(l['name']!, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _sourceLanguage = v);
                              if (_extractedText.isNotEmpty) _translateExtracted();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
                  ),
                  // Target language
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _targetLanguage,
                          isExpanded: true,
                          icon: const Icon(Icons.language, size: 18),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          items: _languages
                              .where((l) => l['code'] != 'auto')
                              .map((l) {
                            return DropdownMenuItem(
                              value: l['code'],
                              child: Text(l['name']!, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _targetLanguage = v);
                              if (_extractedText.isNotEmpty) _translateExtracted();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Image preview ──
            if (_selectedImage != null)
              Container(
                height: 160,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            // ── Extracted text ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.text_fields, size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'النص المستخرج',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const Spacer(),
                            if (_extractedText.isNotEmpty)
                              GestureDetector(
                                onTap: _copyExtracted,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.copy, size: 16),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: _isProcessing
                              ? const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5)),
                                      SizedBox(height: 8),
                                      Text('جاري التعرف على النص...', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Text(
                                    _extractedText.isEmpty ? 'اختر صورة لاستخراج النص منها' : _extractedText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _extractedText.isEmpty ? Colors.grey : null,
                                    ),
                                    textDirection: _extractedText.isEmpty ? TextDirection.rtl : null,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Translation result ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.translate, size: 16, color: Theme.of(context).colorScheme.tertiary),
                            const SizedBox(width: 6),
                            Text(
                              'الترجمة إلى ${_getLangName(_targetLanguage)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_translatedText.isNotEmpty)
                                  GestureDetector(
                                    onTap: _speakTranslation,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.volume_up, size: 16),
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                if (_translatedText.isNotEmpty)
                                  GestureDetector(
                                    onTap: _copyTranslation,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.copy, size: 16),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: _isTranslating
                              ? const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                                      SizedBox(height: 8),
                                      Text('جاري الترجمة...', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Text(
                                    _translatedText.isEmpty ? 'الترجمة ستظهر هنا' : _translatedText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _translatedText.isEmpty ? Colors.grey : null,
                                    ),
                                    textDirection: _isRtl(_targetLanguage) ? TextDirection.rtl : TextDirection.ltr,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80), // space for FAB
          ],
        ),

        // ── Floating Action Button (positioned per tab) ──
        Positioned(
          bottom: 16,
          right: 16,
          child: floatingAction,
        ),
      ],
    );
  }
}

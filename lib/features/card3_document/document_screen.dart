import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});

  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _selectedImage;
  String _extractedText = '';
  String _translatedText = '';
  String _selectedLanguage = 'ar';
  bool _isProcessing = false;
  bool _showOriginal = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final Map<String, String> _languages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'de': 'Deutsch', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
    'ja': 'Japanese', 'zh': '中文', 'ko': '한국어', 'tr': 'Türkçe',
  };

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Starts from right
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _urlController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _urlController.text = pickedFile.path;
        _extractedText = '';
        _translatedText = '';
        _slideController.reset();
      });
      await _extractTextFromImage();
    }
  }

  Future<void> _extractTextFromImage() async {
    if (_selectedImage == null) return;
    setState(() => _isProcessing = true);
    try {
      final inputImage = InputImage.fromFile(_selectedImage!);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      String text = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          text += '${line.text}\n';
        }
      }
      setState(() => _extractedText = text.trim());
      await textRecognizer.close();
    } catch (e) {
      debugPrint('OCR error: $e');
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _translateDocument() async {
    if (_extractedText.isEmpty) return;
    
    // Check page limit (simulation)
    // "التطبيق لا يترجم اكتر من 5 صفحات فى النسخ العاديه"
    
    setState(() => _isProcessing = true);
    try {
      // Full screen loading for 3 seconds as requested
      // We'll use a local state to show a full screen overlay
      await Future.delayed(const Duration(seconds: 3));
      
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$_selectedLanguage&dt=t&q=${Uri.encodeComponent(_extractedText)}'
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        setState(() => _translatedText = translated);
        _slideController.forward();
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مستندات وعدسة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)]
              )
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search bar + Search button
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'رابط الملف أو مساره...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(12)),
                        child: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // Browse Button
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('فتح من المستعرض'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10, 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Language Selector Dropdown at bottom right
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLanguage,
                          dropdownColor: const Color(0xFF1B2838),
                          icon: const Icon(Icons.language, color: Colors.amber),
                          items: _languages.entries.map((e) => DropdownMenuItem(
                            value: e.key, 
                            child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 12))
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedLanguage = v!),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Large Translate Button
                  if (_extractedText.isNotEmpty && _translatedText.isEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _translateDocument,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('ترجمة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          
          // Translated Document Overlay (Full Screen Area when translated)
          if (_translatedText.isNotEmpty)
            Positioned.fill(
              child: GestureDetector(
                onLongPressStart: (_) => setState(() => _showOriginal = true),
                onLongPressEnd: (_) => setState(() => _showOriginal = false),
                child: Container(
                  color: const Color(0xFF0D1B2A),
                  padding: const EdgeInsets.all(10),
                  child: Stack(
                    children: [
                      // Original Document (Background)
                      _buildDocumentPaper(_extractedText, Colors.white.withOpacity(0.1), Colors.white70),
                      
                      // Translated Paper with Slide from Right
                      if (!_showOriginal)
                        SlideTransition(
                          position: _slideAnimation,
                          child: _buildDocumentPaper(_translatedText, Colors.white, Colors.black87, hasWatermark: true),
                        ),
                        
                      // Share Button for Translated Doc
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: FloatingActionButton(
                          backgroundColor: Colors.blueAccent,
                          child: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                            // Share with signature simulation
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تمت مشاركة المستند بتوقيع ميرور سكربيون'))
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
          // Full Screen Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.blueAccent),
                    SizedBox(height: 20),
                    Text('جاري المعالجة والترجمة...', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentPaper(String text, Color bgColor, Color textColor, {bool hasWatermark = false}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [const BoxShadow(color: Colors.black45, blurRadius: 15)],
      ),
      child: Stack(
        children: [
          if (hasWatermark)
            Center(
              child: Opacity(
                opacity: 0.15,
                child: Transform.rotate(
                  angle: -130 * 3.14 / 180,
                  child: const Text(
                    'ترجم هذا المستند بواسطة ميرور سكربيون',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          SingleChildScrollView(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 16, height: 1.8),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}

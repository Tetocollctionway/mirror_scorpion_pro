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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
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
    setState(() => _isProcessing = true);
    try {
      // Show loading for 3 seconds as requested
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
        title: const Text('مستندات وعدسة', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.amber),
            onSelected: (v) => setState(() => _selectedLanguage = v),
            itemBuilder: (context) => _languages.entries.map((e) => PopupMenuItem(value: e.key, child: Text(e.value))).toList(),
          ),
        ],
      ),
      body: Container(
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'رابط الملف أو مساره...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.blue),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.folder_open),
                label: const Text('فتح من المستعرض'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white),
              ),
              const SizedBox(height: 20),
              if (_extractedText.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _translateDocument,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    child: _isProcessing 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('ترجمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              const SizedBox(height: 20),
              if (_translatedText.isNotEmpty)
                Expanded(
                  child: GestureDetector(
                    onLongPressStart: (_) => setState(() => _showOriginal = true),
                    onLongPressEnd: (_) => setState(() => _showOriginal = false),
                    child: Stack(
                      children: [
                        // Original Document
                        _buildDocumentPaper(_extractedText, Colors.white10, Colors.white70),
                        // Translated Paper with Slide
                        if (!_showOriginal)
                          SlideTransition(
                            position: _slideAnimation,
                            child: _buildDocumentPaper(_translatedText, Colors.white, Colors.black87, hasWatermark: true),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentPaper(String text, Color bgColor, Color textColor, {bool hasWatermark = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)],
      ),
      child: Stack(
        children: [
          if (hasWatermark)
            Center(
              child: Transform.rotate(
                angle: -130 * 3.14 / 180,
                child: Text(
                  'ترجم هذا المستند بواسطة ميرور سكربيون',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.1),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          SingleChildScrollView(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 14, height: 1.6),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}

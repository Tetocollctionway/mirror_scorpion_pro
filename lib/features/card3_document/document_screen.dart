import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  bool _showTranslation = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final Map<String, String> _languages = {
    'ar': 'العربية',
    'en': 'English',
    'fr': 'Français',
    'es': 'Español',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'ja': 'Japanese',
    'zh': '中文',
    'ko': '한국어',
    'tr': 'Türkçe',
  };

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _urlController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _extractedText = '';
          _translatedText = '';
          _showTranslation = false;
        });
        await _extractTextFromImage();
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  Future<void> _extractTextFromImage() async {
    if (_selectedImage == null) return;

    setState(() => _isProcessing = true);

    try {
      final inputImage = InputImage.fromFile(_selectedImage!);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String extractedText = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText += '${line.text}\n';
        }
      }

      setState(() {
        _extractedText = extractedText.trim();
      });

      await textRecognizer.close();
    } catch (e) {
      debugPrint('OCR error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في استخراج النص: $e')),
        );
      }
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _translateDocument() async {
    if (_extractedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار صورة أولاً')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Limit to 5 pages in free version (simulate by limiting text length)
      final textToTranslate = _extractedText.length > 5000 
        ? _extractedText.substring(0, 5000) 
        : _extractedText;

      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$_selectedLanguage&dt=t&q=${Uri.encodeComponent(textToTranslate)}'
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        
        setState(() {
          _translatedText = translated;
          _isProcessing = false;
          _showTranslation = false;
        });

        // Animate the paper slide
        await _slideController.forward();
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الترجمة: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مستندات وعدسة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1B2838),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: _languages.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLanguage = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Image picker section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختر صورة المستند',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    // Selected image preview
                    if (_selectedImage != null)
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.solid),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 40, color: Colors.white.withOpacity(0.3)),
                              const SizedBox(height: 8),
                              Text(
                                'لم تختر صورة بعد',
                                style: TextStyle(color: Colors.white.withOpacity(0.3)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('فتح المعرض'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Extracted text section
              if (_extractedText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'النص المستخرج',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _extractedText,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Translate button
              if (_extractedText.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _translateDocument,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'ترجمة المستند',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                  ),
                ),
              const SizedBox(height: 20),

              // Translated document view (full screen)
              if (_translatedText.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() => _showTranslation = false);
                    },
                    onLongPressEnd: (_) {
                      setState(() => _showTranslation = true);
                    },
                    child: Stack(
                      children: [
                        // Original document
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _extractedText,
                              style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                            ),
                          ),
                        ),
                        // Translated paper slide effect
                        if (!_showTranslation)
                          SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Translated text
                                  SingleChildScrollView(
                                    child: Text(
                                      _translatedText,
                                      style: const TextStyle(color: Colors.black87, fontSize: 12, height: 1.5),
                                    ),
                                  ),
                                  // Transparent signature (130 degrees)
                                  Positioned(
                                    bottom: 20,
                                    right: 10,
                                    child: Transform.rotate(
                                      angle: 130 * 3.14 / 180,
                                      child: Text(
                                        'Mirror Scorpion',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.08),
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
}

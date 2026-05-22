import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});

  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  late final TextRecognizer _textRecognizer;
  
  String _sourceLang = 'en';
  String _targetLang = 'ar';
  bool _isLoading = false;
  bool _isTranslating = false;
  String? _translatedText;
  File? _selectedImage;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'}, {'code': 'ar', 'name': 'Arabic'},
    {'code': 'bn', 'name': 'Bengali'}, {'code': 'si', 'name': 'Sinhala'},
    {'code': 'fr', 'name': 'French'}, {'code': 'es', 'name': 'Spanish'},
    {'code': 'de', 'name': 'German'}, {'code': 'tr', 'name': 'Turkish'},
    {'code': 'ur', 'name': 'Urdu'}, {'code': 'fa', 'name': 'Persian'},
    {'code': 'id', 'name': 'Indonesian'}, {'code': 'hi', 'name': 'Hindi'},
  ];

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer();
  }

  @override
  void dispose() {
    _textController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
        await _extractTextFromImage();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _extractTextFromImage() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final inputImage = InputImage.fromFile(_selectedImage!);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      setState(() {
        _textController.text = recognizedText.text;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error extracting text: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error extracting text: $e')),
        );
      }
    }
  }

  Future<void> translateText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=$_sourceLang&tl=$_targetLang&dt=t&q=${Uri.encodeComponent(text)}');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        
        setState(() {
          _translatedText = translated;
          _isTranslating = false;
        });

        if (mounted) {
          _showTranslationDialog(translated);
        }
      } else {
        setState(() => _isTranslating = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Translation failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      setState(() => _isTranslating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().substring(0, 50)}...')),
        );
      }
    }
  }

  void _showTranslationDialog(String translated) {
    final isRtl = _targetLang == 'ar' || _targetLang == 'ur' || _targetLang == 'fa';
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Translation Result'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Original:', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_textController.text, style: const TextStyle(color: Colors.white70, height: 1.5)),
              ),
              const SizedBox(height: 16),
              Container(height: 1, color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text('Translation:', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  translated,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 16, height: 1.5),
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                ),
              ),
              const SizedBox(height: 16),
              Text('Translated by Mirror Scorpion', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: translated));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Translation copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Translation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language selectors
                Row(
                  children: [
                    Expanded(child: _buildLangDropdown(_sourceLang, (v) => setState(() => _sourceLang = v))),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, color: Colors.white38, size: 20)),
                    Expanded(child: _buildLangDropdown(_targetLang, (v) => setState(() => _targetLang = v))),
                  ],
                ),
                const SizedBox(height: 20),

                // Image picker section
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.03),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_selectedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
                        )
                      else
                        Icon(Icons.image_search, size: 64, color: Colors.orange.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Pick Image from Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.withOpacity(0.2),
                          foregroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Text input section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Paste or type document text here...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Translate button
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _textController.text.trim().isEmpty || _isTranslating ? null : translateText,
                    icon: _isTranslating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.translate),
                    label: Text(_isTranslating ? 'Translating...' : 'Translate Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Info section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to use:',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Pick an image from your gallery or paste text\n'
                        '2. Select source and target languages\n'
                        '3. Tap "Translate Document" to get the translation\n'
                        '4. Copy or share the translated text',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Mirror Scription - Document Translation', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.2))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangDropdown(String value, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1B2838),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: _languages.map((l) => DropdownMenuItem(value: l['code'], child: Text(l['name']!))).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

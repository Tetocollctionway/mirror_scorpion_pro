import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DocumentLensScreen extends StatefulWidget {
  const DocumentLensScreen({super.key});

  @override
  State<DocumentLensScreen> createState() => _DocumentLensScreenState();
}

class _DocumentLensScreenState extends State<DocumentLensScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTranslating = false;
  String _selectedLanguage = 'ar';
  
  List<Map<String, dynamic>> _translatedBlocks = [];

  final Map<String, String> _languages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'de': 'Deutsch', 'it': 'Italiano', 'tr': 'Türkçe', 'ru': 'Русский',
  };

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.high);
      await _controller!.initialize();
      if (mounted) setState(() => _isInitialized = true);
    }
  }

  Future<void> _captureAndTranslate() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    setState(() => _isTranslating = true);
    try {
      final XFile image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin); // Use latin for initial OCR, can be expanded to Devanagari etc. if needed
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      List<Map<String, dynamic>> results = [];
      
      for (TextBlock block in recognizedText.blocks) {
        final text = block.text;
        final translatedText = await _translateText(text);
        results.add({
          'rect': block.boundingBox,
          'text': translatedText,
          'original': text,
        });
      }
      
      setState(() {
        _translatedBlocks = results;
        _isTranslating = false;
      });
      
      await textRecognizer.close();
    } catch (e) {
      debugPrint('Lens Error: $e');
      setState(() => _isTranslating = false);
    }
  }

  Future<String> _translateText(String text) async {
    try {
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$_selectedLanguage&dt=t&q=${Uri.encodeComponent(text)}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data[0] as List).map((e) => e[0] as String).join();
      }
    } catch (e) {}
    return text;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          
          if (_translatedBlocks.isNotEmpty)
            ..._translatedBlocks.map((block) {
              final rect = block['rect'] as Rect;
              return Positioned(
                left: rect.left,
                top: rect.top,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    block['text'],
                    style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),

          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      dropdownColor: Colors.black87,
                      items: _languages.entries.map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value, style: const TextStyle(color: Colors.white)),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedLanguage = v!),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.flash_on, color: Colors.white), onPressed: () {}),
              ],
            ),
          ),
          
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text('عدسة ميرور سكربيون', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _isTranslating ? null : _captureAndTranslate,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: _isTranslating 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Container(width: 50, height: 50, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('ترجمة فورية بدون بحث ويب', style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

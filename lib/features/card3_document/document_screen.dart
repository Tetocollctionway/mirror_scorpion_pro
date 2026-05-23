import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});

  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  late final TextRecognizer _textRecognizer;
  WebViewController? _webViewController;
  
  String _sourceLang = 'en';
  String _targetLang = 'ar';
  bool _isLoading = false;
  bool _isFullScreen = false;
  bool _showOriginal = false;
  File? _selectedImage;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'}, {'code': 'ar', 'name': 'Arabic'},
    {'code': 'fr', 'name': 'French'}, {'code': 'es', 'name': 'Spanish'},
    {'code': 'de', 'name': 'German'}, {'code': 'tr', 'name': 'Turkish'},
  ];

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _textController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  void _loadUrl() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(url.startsWith('http') ? url : 'https://$url'));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: _isFullScreen ? null : AppBar(
        title: const Text('ترجمة المستندات والروابط', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isFullScreen ? _buildFullScreenView() : _buildNormalView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
        backgroundColor: Colors.orange,
        child: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white),
      ),
    );
  }

  Widget _buildNormalView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // URL Input Section
          _buildSectionTitle('رابط إنترنت (Web Link)'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'أدخل رابط الموقع هنا...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _loadUrl,
                icon: const Icon(Icons.language, color: Colors.orange),
                style: IconButton.styleFrom(backgroundColor: Colors.orange.withOpacity(0.1)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Web View Preview (Small)
          if (_webViewController != null)
            Container(
              height: 200,
              decoration: BoxDecoration(border: Border.all(color: Colors.orange.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: WebViewWidget(controller: _webViewController!),
              ),
            ),
          const SizedBox(height: 20),

          // Document Info
          _buildSectionTitle('المسار التلقائي للمستندات'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.folder_open, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'المسار: /storage/emulated/0/MirrorDocuments/',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Features List
          _buildFeatureItem(Icons.touch_app, 'ميزة اللمس لإظهار النص الأصلي نشطة'),
          _buildFeatureItem(Icons.verified, 'توقيع شفاف Mirror Scorpion (130°)'),
          _buildFeatureItem(Icons.hd, 'دعم دقة Full Screen للترجمة'),
        ],
      ),
    );
  }

  Widget _buildFullScreenView() {
    return Stack(
      children: [
        // Background Web/Doc Content
        if (_webViewController != null)
          WebViewWidget(controller: _webViewController!)
        else
          const Center(child: Text('لا يوجد محتوى لعرضه', style: TextStyle(color: Colors.white))),

        // Overlay Translation / Original
        if (_showOriginal)
          Container(color: Colors.black.withOpacity(0.4), child: const Center(child: Text('عرض النص الأصلي...', style: TextStyle(color: Colors.white, fontSize: 20))))
        else
          Positioned.fill(
            child: GestureDetector(
              onLongPressStart: (_) => setState(() => _showOriginal = true),
              onLongPressEnd: (_) => setState(() => _showOriginal = false),
              child: Container(color: Colors.transparent),
            ),
          ),

        // Transparent Signature
        Center(
          child: Transform.rotate(
            angle: 130 * 3.14 / 180,
            child: Text(
              'Mirror Scorpion',
              style: TextStyle(color: Colors.white.withOpacity(0.05), fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Back Button
        Positioned(
          top: 40,
          left: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
            onPressed: () => setState(() => _isFullScreen = false),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}

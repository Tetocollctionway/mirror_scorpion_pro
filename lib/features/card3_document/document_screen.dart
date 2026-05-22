import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});

  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  final TextEditingController _textController = TextEditingController();
  String _sourceLang = 'en';
  String _targetLang = 'ar';
  bool _isLoading = false;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'}, {'code': 'ar', 'name': 'Arabic'},
    {'code': 'bn', 'name': 'Bengali'}, {'code': 'si', 'name': 'Sinhala'},
    {'code': 'fr', 'name': 'French'}, {'code': 'es', 'name': 'Spanish'},
    {'code': 'de', 'name': 'German'}, {'code': 'tr', 'name': 'Turkish'},
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> translateText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=$_sourceLang&tl=$_targetLang&dt=t&q=${Uri.encodeComponent(text)}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        _showResultDialog(translated);
      }
    } catch (_) {}

    setState(() => _isLoading = false);
  }

  void _showResultDialog(String translated) {
    final isRtl = _targetLang == 'ar' || _targetLang == 'ur' || _targetLang == 'fa';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Original:', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          const SizedBox(height: 4),
          Text(_textController.text, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text('Translation:', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          const SizedBox(height: 4),
          Text(translated, style: const TextStyle(color: Colors.greenAccent, fontSize: 16), textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Translation'), backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)])),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: _buildLangDropdown(_sourceLang, (v) => setState(() => _sourceLang = v))),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, color: Colors.white38, size: 20)),
                  Expanded(child: _buildLangDropdown(_targetLang, (v) => setState(() => _targetLang = v))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.withOpacity(0.3))),
                child: TextField(
                  controller: _textController,
                  maxLines: 8,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Paste or type document text here...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton.icon(
                  onPressed: _textController.text.trim().isEmpty || _isLoading ? null : translateText,
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.translate),
                  label: Text(_isLoading ? 'Translating...' : 'Translate Document'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ),
            const Spacer(),
            Text('Mirror Scription - Document Translation', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.2))),
            const SizedBox(height: 8),
          ],
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
          value: value, isExpanded: true, dropdownColor: const Color(0xFF1B2838),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: _languages.map((l) => DropdownMenuItem(value: l['code'], child: Text(l['name']!))).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

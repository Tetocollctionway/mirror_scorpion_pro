import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';

class DialogueTranslationScreen extends StatefulWidget {
  const DialogueTranslationScreen({super.key});

  @override
  State<DialogueTranslationScreen> createState() => _DialogueTranslationScreenState();
}

class _DialogueTranslationScreenState extends State<DialogueTranslationScreen> {
  final TextEditingController _upperController = TextEditingController();
  final TextEditingController _lowerController = TextEditingController();
  late stt.SpeechToText _speechToText;
  
  String _rightLang = 'en'; // Right button
  String _leftLang = 'ar';  // Left button
  bool _isListening = false;
  bool _isTranslating = false;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'}, {'code': 'ar', 'name': 'العربية'},
    {'code': 'fr', 'name': 'Français'}, {'code': 'es', 'name': 'Español'},
    {'code': 'de', 'name': 'Deutsch'}, {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'ur', 'name': 'اردو'}, {'code': 'fa', 'name': 'فارسی'},
    {'code': 'hi', 'name': 'हिन्दी'}, {'code': 'ru', 'name': 'Русский'},
  ];

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _speechToText.initialize();
  }

  Future<void> _handleMic() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      _translate();
    } else {
      _upperController.clear();
      _lowerController.clear();
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() => _upperController.text = result.recognizedWords);
          },
          localeId: _rightLang,
        );
      }
    }
  }

  Future<void> _translate() async {
    if (_upperController.text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=$_rightLang&tl=$_leftLang&dt=t&q=${Uri.encodeComponent(_upperController.text)}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        setState(() => _lowerController.text = translated);
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    setState(() => _isTranslating = false);
  }

  void _swap() {
    setState(() {
      final temp = _rightLang;
      _rightLang = _leftLang;
      _leftLang = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حوار مترجم', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
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
              // Upper Editor (Enlarged for visibility)
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: _upperController,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'الكلام الملتقط يظهر هنا...',
                      hintStyle: TextStyle(color: Colors.white24),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Controls Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _langBtn(_leftLang, (v) => setState(() => _leftLang = v!)),
                  IconButton(icon: const Icon(Icons.swap_horiz, color: Colors.amber), onPressed: _swap),
                  GestureDetector(
                    onTap: _handleMic,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: _isListening ? Colors.red : Colors.blueAccent,
                      child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 30),
                    ),
                  ),
                  _langBtn(_rightLang, (v) => setState(() => _rightLang = v!)),
                ],
              ),
              const SizedBox(height: 16),
              // Lower Editor (Translation)
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _lowerController,
                        maxLines: null,
                        readOnly: true,
                        style: const TextStyle(color: Colors.amber, fontSize: 18),
                        decoration: const InputDecoration(
                          hintText: 'الترجمة تظهر هنا...',
                          hintStyle: TextStyle(color: Colors.white24),
                          border: InputBorder.none,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.blue),
                          onPressed: () {
                            Provider.of<TTSService>(context, listen: false).speak(_lowerController.text);
                          },
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

  Widget _langBtn(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: const Color(0xFF1B2838),
        underline: const SizedBox(),
        items: _languages.map((l) => DropdownMenuItem(value: l['code'], child: Text(l['name']!, style: const TextStyle(color: Colors.white, fontSize: 12)))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

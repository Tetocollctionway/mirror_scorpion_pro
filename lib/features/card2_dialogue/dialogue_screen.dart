import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  
  String _rightLang = 'ar'; // Right button (Source)
  String _leftLang = 'en';  // Left button (Target)
  bool _isListening = false;
  bool _isTranslating = false;

  final List<Map<String, String>> _languages = [
    {'code': 'ar', 'name': 'العربية'}, {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'}, {'code': 'es', 'name': 'Español'},
    {'code': 'de', 'name': 'Deutsch'}, {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'ur', 'name': 'اردو'}, {'code': 'fa', 'name': 'فارسی'},
    {'code': 'hi', 'name': 'हिन्दी'}, {'code': 'ru', 'name': 'Русский'},
  ];

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  Future<void> _handleMic() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      _translate();
    } else {
      // Clear screen on new mic press as requested
      _upperController.clear();
      _lowerController.clear();
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        // Always uses the right button language for the upper editor
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
        title: const Text('حوار مترجم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
        centerTitle: true,
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
              // Upper Editor (Source)
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: _upperController,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    decoration: const InputDecoration(
                      hintText: 'تحدث ليتم التقاط الكلمات هنا...',
                      hintStyle: TextStyle(color: Colors.white24),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Controls Row: Left Lang | Swap | Mic | Right Lang
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left Lang Button (Target)
                  _langBtn(_leftLang, (v) => setState(() => _leftLang = v!)),
                  
                  // Swap Button
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, color: Colors.amber, size: 32),
                    onPressed: _swap,
                  ),
                  
                  // Mic Button (Good size)
                  GestureDetector(
                    onTap: _handleMic,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.redAccent : Colors.blueAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? Colors.red : Colors.blue).withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 35),
                    ),
                  ),
                  
                  // Right Lang Button (Source - Always used for input)
                  _langBtn(_rightLang, (v) => setState(() => _rightLang = v!)),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Lower Editor (Translation)
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _lowerController,
                        maxLines: null,
                        readOnly: true,
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          hintText: 'الترجمة ستظهر هنا...',
                          hintStyle: TextStyle(color: Colors.white24),
                          border: InputBorder.none,
                        ),
                      ),
                      // Speaker on bottom right
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.blueAccent, size: 30),
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1B2838),
          items: _languages.map((l) => DropdownMenuItem(
            value: l['code'], 
            child: Text(l['name']!, style: const TextStyle(color: Colors.white, fontSize: 14))
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

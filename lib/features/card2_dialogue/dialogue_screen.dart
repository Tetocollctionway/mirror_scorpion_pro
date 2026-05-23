import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class DialogueTranslationScreen extends StatefulWidget {
  const DialogueTranslationScreen({super.key});

  @override
  State<DialogueTranslationScreen> createState() => _DialogueTranslationScreenState();
}

class _DialogueTranslationScreenState extends State<DialogueTranslationScreen> {
  final List<_Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  
  String _sourceLang = 'en'; // Left button
  String _targetLang = 'ar'; // Right button
  bool _isTranslating = false;
  bool _isListening = false;

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
    _initializeSpeechAndTTS();
  }

  Future<void> _initializeSpeechAndTTS() async {
    _speechToText = stt.SpeechToText();
    _flutterTts = FlutterTts();
    
    await _speechToText.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );

    await _flutterTts.setLanguage(_targetLang);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _handleMicClick() async {
    if (_isListening) {
      await _stopListening();
    } else {
      // Description: Auto-clear text when clicking mic to start new recognition
      setState(() {
        _textController.clear();
      });
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_isListening && await _speechToText.initialize()) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _textController.text = result.recognizedWords;
          });
        },
        localeId: _sourceLang,
      );
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
    
    if (_textController.text.isNotEmpty) {
      await sendMessage();
    }
  }

  Future<void> sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true, lang: _sourceLang));
      _textController.clear();
      _isTranslating = true;
    });

    try {
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=$_sourceLang&tl=$_targetLang&dt=t&q=${Uri.encodeComponent(text)}');
      final response = await http.get(url);
      String translated = '';
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        translated = (data[0] as List).map((e) => e[0] as String).join();
      }
      setState(() {
        _messages.add(_Message(text: translated, isUser: false, lang: _targetLang, original: text));
        _isTranslating = false;
      });
    } catch (e) {
      setState(() => _isTranslating = false);
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
  }

  Future<void> _speakMessage(String text, String lang) async {
    try {
      await _flutterTts.setLanguage(lang);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترجمة حوارية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white70), 
            onPressed: () => setState(() => _messages.clear()),
            tooltip: 'مسح السجل',
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
        child: Column(
          children: [
            // Language selectors
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: _langDropdown('اللغة اليسرى', _sourceLang, (v) => setState(() => _sourceLang = v))),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _swapLanguages,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.swap_horiz, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _langDropdown('اللغة اليمنى', _targetLang, (v) => setState(() => _targetLang = v))),
                ],
              ),
            ),
            
            // Messages List
            Expanded(
              child: _messages.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.chat_bubble_outline, size: 80, color: Colors.white.withOpacity(0.05)),
                    const SizedBox(height: 16),
                    Text('ابدأ المحادثة...', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 18)),
                  ]))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTranslating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: Colors.white38)));
                      }
                      final msg = _messages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
            ),

            // Input Section (Upper Editor)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Description: Upper editor follows Right button language
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(color: Colors.white),
                              textAlign: _targetLang == 'ar' || _targetLang == 'ur' || _targetLang == 'fa' ? TextAlign.right : TextAlign.left,
                              decoration: InputDecoration(
                                hintText: 'اكتب هنا (تتبع اللغة اليمنى)...',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _handleMicClick,
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: _isListening ? Colors.red.withOpacity(0.8) : Colors.blueAccent.withOpacity(0.8),
                            child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: sendMessage,
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.green.withOpacity(0.8),
                            child: const Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_Message msg) {
    final isUser = msg.isUser;
    final isRTL = msg.lang == 'ar' || msg.lang == 'ur' || msg.lang == 'fa';
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.withOpacity(0.2) : Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          border: Border.all(color: (isUser ? Colors.blue : Colors.green).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isRTL) ...[
                  Flexible(child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5))),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20, color: Colors.white70),
                    onPressed: () => _speakMessage(msg.text, msg.lang),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20, color: Colors.white70),
                    onPressed: () => _speakMessage(msg.text, msg.lang),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: Text(msg.text, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5))),
                ],
              ],
            ),
            if (msg.original != null) ...[
              const SizedBox(height: 8),
              Divider(color: Colors.white.withOpacity(0.1), height: 1),
              const SizedBox(height: 8),
              Text(msg.original!, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _langDropdown(String label, String value, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05), 
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value, 
              isExpanded: true, 
              dropdownColor: const Color(0xFF1B2838),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: _languages.map((l) => DropdownMenuItem(value: l['code'], child: Text('${l['name']}'))).toList(),
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ),
        ),
      ],
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final String lang;
  final String? original;
  _Message({required this.text, required this.isUser, required this.lang, this.original});
}

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
  
  String _sourceLang = 'en';
  String _targetLang = 'ar';
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
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
  }

  Future<void> _speakMessage(String text) async {
    try {
      await _flutterTts.setLanguage(_targetLang);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dialogue Translation'),
        backgroundColor: Colors.transparent, 
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.delete_sweep), onPressed: () => setState(() => _messages.clear())),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)])),
        child: Column(
          children: [
            // Language selectors with swap button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: _langDropdown('Source', _sourceLang, (v) => setState(() => _sourceLang = v))),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _swapLanguages,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.swap_horiz, color: Colors.white38, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _langDropdown('Target', _targetLang, (v) => setState(() => _targetLang = v))),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: _messages.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 16),
                    Text('Start a conversation...', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                    Text('Type a message or use microphone', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12)),
                  ]))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTranslating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                      }
                      final msg = _messages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
            ),
            // Input
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onSubmitted: (_) => sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.white38),
                          onPressed: _isListening ? _stopListening : _startListening,
                          tooltip: _isListening ? 'Stop listening' : 'Start listening',
                        ),
                        IconButton(
                          icon: Icon(Icons.send_rounded, color: Colors.green.shade300),
                          onPressed: sendMessage,
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
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.withOpacity(0.2) : Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(18),
          ),
          border: Border.all(color: (isUser ? Colors.blue : Colors.green).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(msg.text, style: TextStyle(color: isUser ? Colors.blue.shade100 : Colors.green.shade100, fontSize: 15, height: 1.4)),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _speakMessage(msg.text),
                  child: Icon(Icons.volume_up, size: 16, color: isUser ? Colors.blue.shade100 : Colors.green.shade100),
                ),
              ],
            ),
            if (msg.original != null) ...[
              const SizedBox(height: 6),
              Container(height: 1, color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 6),
              Text(msg.original!, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 4),
            Text(msg.lang.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _langDropdown(String label, String value, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true, dropdownColor: const Color(0xFF1B2838),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          items: _languages.map((l) => DropdownMenuItem(value: l['code'], child: Text('${l['name']}'))).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
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

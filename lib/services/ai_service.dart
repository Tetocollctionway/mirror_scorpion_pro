import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class AIService extends ChangeNotifier {
  bool _isLoading = false;
  String? _lastResponse;
  bool _isPremium = false;
  
  // Context tracking for inspiration
  final List<String> _userStoryInterests = [];
  DateTime? _lastInspirationTime;
  int _inspirationCount = 0;

  bool get isLoading => _isLoading;
  String? get lastResponse => _lastResponse;
  bool get isPremium => _isPremium;
  List<String> get userStoryInterests => List.unmodifiable(_userStoryInterests);
  bool get canSendInspiration {
    if (_lastInspirationTime == null) return true;
    return DateTime.now().difference(_lastInspirationTime!).inHours >= 3;
  }

  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  // ---- Translation (Cards 1, 2, 3) ----
  Future<String> translate({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Primary: Google ML Kit (offline)
      // Secondary: Online API fallback
      final response = await http.post(
        Uri.parse('https://translation.googleapis.com/language/translate/v2'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': fromLanguage,
          'target': toLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _lastResponse = data['data']['translations'][0]['translatedText'];
      } else {
        // Fallback: local mock (for development)
        _lastResponse = '[${toLanguage.toUpperCase()}] $text';
      }
    } catch (e) {
      // Offline fallback
      _lastResponse = text;
      debugPrint('Translation error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return _lastResponse ?? text;
  }

  // ---- Inspiration (Card 4) ----
  String generateInspiration({
    required String userMood,
    List<String>? recentStories,
  }) {
    final random = Random();
    
    final inspirations = {
      'sad': [
        '﴿إِنَّ مَعَ الْعُسْرِ يُسْرًا﴾ - الشرح:٦',
        '﴿وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ﴾ - الطلاق:٣',
        '﴿لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا﴾ - التوبة:٤٠',
        'كل انكسار هو تمهيد لانطلاقة أعظم',
        'الماضي ليس للمحو، بل للتعلّم',
      ],
      'happy': [
        '﴿وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ﴾ - الضحى:١١',
        'الحمد لله الذي بنعمته تتم الصالحات',
        'الفرح نعمة، والشكر يحفظها',
      ],
      'anxious': [
        '﴿وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ﴾',
        '﴿فَإِذَا عَزَمْتَ فَتَوَكَّلْ عَلَى اللَّهِ﴾',
        'اجعل همك في لحظتك هذه فقط',
      ],
      'motivated': [
        '﴿فَاسْتَقِمْ كَمَا أُمِرْتَ﴾',
        'لا تتوقف، الطريق لا يزال أمامك',
        'العمل هو جوهر الحياة',
      ],
    };

    final moodList = inspirations[userMood] ?? inspirations['sad']!;
    final result = moodList[random.nextInt(moodList.length)];
    
    _inspirationCount++;
    _lastInspirationTime = DateTime.now();
    
    return result;
  }

  // Track user story interest for better inspiration
  void trackStoryInterest(String storyTitle) {
    _userStoryInterests.add(storyTitle);
    if (_userStoryInterests.length > 10) {
      _userStoryInterests.removeAt(0);
    }
  }

  // ---- Video Generation (Card 4 - Stories) ----
  Future<String> generateStoryVideo(String storyText) async {
    if (!_isPremium && _inspirationCount >= 1) {
      throw Exception('النسخة المجانية: فيديو واحد يومياً');
    }

    // API call to AI video generation service
    // This would integrate with services like RunwayML, Pika, or similar
    try {
      final response = await http.post(
        Uri.parse('https://api.runwayml.com/v1/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY',
        },
        body: jsonEncode({
          'prompt': storyText,
          'duration': 30,
          'style': 'cinematic',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['video_url'];
      }
    } catch (e) {
      debugPrint('Video generation error: $e');
    }

    return '';
  }

  // ---- Voice Cloning (Card 4 - 5th Voice) ----
  Future<String> cloneVoice(String audioFilePath) async {
    // Advanced AI voice cloning - 5th voice uses premium model
    try {
      final response = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/voice-cloning'),
        headers: {
          'Content-Type': 'application/json',
          'xi-api-key': 'YOUR_API_KEY',
        },
        body: jsonEncode({
          'audio_file': audioFilePath,
          'voice_name': 'Mirror Voice 5',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['voice_id'];
      }
    } catch (e) {
      debugPrint('Voice cloning error: $e');
    }

    return '';
  }
}

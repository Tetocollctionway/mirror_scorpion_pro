import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// AIService - Provides AI-powered inspiration and spiritual support
/// Uses OpenAI API for generating personalized messages based on user mood/context
class AIService {
  static const String _apiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _modelName = 'gpt-3.5-turbo';
  
  // For demo purposes, we'll use local inspirational messages
  // In production, replace with actual API calls
  
  static final List<String> _inspirationalMessages = [
    'تذكّر أن كل تحدٍ هو فرصة لتصبح أقوى وأحكم. 🌟',
    'الصبر مفتاح الفرج، والدعاء سلاح المؤمن. 💪',
    'لا تستسلم للأحزان، فالفجر يأتي بعد أطول ليل. 🌅',
    'أنت أقوى مما تعتقد، وقادر على تحقيق أحلامك. ✨',
    'كل خطوة صغيرة نحو الأمام هي انتصار حقيقي. 🚀',
    'الحياة اختبار، والصبر هو المفتاح. 🔑',
    'تعلم من أخطائك، ولا تستسلم أبداً. 📚',
    'أنت تستحق السعادة والنجاح. 🎯',
    'الله معك في كل خطوة. 🤲',
    'هذا اليوم هو فرصة جديدة للبدء من جديد. 🌈',
  ];

  static final List<String> _motivationalQuotes = [
    '"الحياة ليست عن الانتظار حتى تمر العاصفة، بل عن تعلم الرقص تحت المطر." - فيرا',
    '"النجاح لا يأتي من الحظ، بل من العمل الجاد والإصرار." - توماس إديسون',
    '"كل ما تحتاجه هو الإيمان والعزيمة." - محمد علي',
    '"لا تخافوا من الفشل، خافوا من عدم المحاولة." - جاك ما',
    '"الحياة جميلة عندما تركز على الأشياء الصغيرة." - جون رسكين',
    '"أنت لست وحدك في هذا الطريق." - أنت',
    '"الأمل هو أقوى سلاح لدينا." - نيلسون مانديلا',
    '"كل يوم جديد هو فرصة جديدة." - رالف مارستون',
  ];

  static final List<String> _comfortMessages = [
    'أنت لست وحدك في هذا الشعور. الكثيرون يمرون بما تمر به. 🤝',
    'هذا الشعور مؤقت، وسيمر. تحلى بالصبر. ⏳',
    'تذكّر أن الله لا يضع عليك أكثر مما تستطيع تحمله. 🙏',
    'احرص على الاعتناء بنفسك أولاً. 💚',
    'لا تتردد في طلب المساعدة من الآخرين. 🤲',
    'أنت أقوى مما تعتقد، وستتجاوز هذا. 💪',
    'خذ نفساً عميقاً وركز على اللحظة الحالية. 🧘',
    'هذه اللحظة الصعبة ستمر، وستكون أقوى بعدها. 🌟',
  ];

  static final List<String> _celebrationMessages = [
    'مبروك! أنت تستحق هذا النجاح! 🎉',
    'ما أجمل هذا الشعور! استمتع بلحظتك. 🌟',
    'أنت فعلاً رائع! تابع هذا الطريق. 🚀',
    'فخور بك! استمر في العطاء. 💪',
    'هذا هو بداية أشياء عظيمة. 🎯',
    'احتفل بإنجازاتك، مهما كانت صغيرة. 🎊',
    'أنت تثبت أنك قادر على تحقيق أحلامك. ✨',
    'هذا النجاح يستحق أن تفخر به. 👑',
  ];

  /// Generate inspiration based on user mood/context
  static Future<String> generateInspiration({
    required String userMood,
    required String context,
    bool isPremium = false,
  }) async {
    try {
      // Analyze mood and return appropriate message
      String message = '';
      if (userMood.isEmpty) {
        message = _inspirationalMessages[DateTime.now().microsecond % _inspirationalMessages.length];
      } else if (_isSadMood(userMood)) {
        message = _comfortMessages[DateTime.now().microsecond % _comfortMessages.length];
      } else if (_isHappyMood(userMood)) {
        message = _celebrationMessages[DateTime.now().microsecond % _celebrationMessages.length];
      } else {
        message = _motivationalQuotes[DateTime.now().microsecond % _motivationalQuotes.length];
      }

      // In a real Manus-enhanced app, we would use LLM to make it more personal
      return "بناءً على شعورك: $message\n\nتذكر أن ميرور سكربيون معك في رحلة البناء المستمر. ✨";
    } catch (e) {
      debugPrint('Error generating inspiration: $e');
      return 'تذكّر أن الله معك دائماً. 🤲';
    }
  }

  /// Generate an image prompt based on the inspiration message
  static String generateImagePrompt(String message) {
    // Manus-style prompt engineering
    return "Islamic spiritual art, $message, cinematic lighting, ethereal atmosphere, calligraphy elements, 8k resolution, serene landscape background, golden hour";
  }

  /// Simulate Manus Image Generation
  static Future<String> generateManusImage(String prompt) async {
    // In a real app, this would call a DALL-E or Midjourney API
    // For now, we return a high-quality placeholder image based on the prompt
    await Future.delayed(const Duration(seconds: 2)); // Simulate generation time
    return "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80";
  }

  /// Get spiritual support message
  static Future<String> getSpiritualSupport({
    required String userState,
    bool isPremium = false,
  }) async {
    try {
      if (_isSadMood(userState)) {
        return 'يا رب، أنت تعلم ما في قلبي. ساعدني وقويني. 🤲';
      } else if (_isStressedMood(userState)) {
        return 'توكلت على الله، وهو حسبي. 🙏';
      } else {
        return 'الحمد لله على كل نعمه. 🌟';
      }
    } catch (e) {
      debugPrint('Error getting spiritual support: $e');
      return 'استعن بالله ولا تعجز. 💪';
    }
  }

  /// Generate daily wisdom notification
  static Future<String> generateDailyWisdom() async {
    try {
      final random = DateTime.now().microsecond;
      final allMessages = [
        ..._inspirationalMessages,
        ..._motivationalQuotes,
        ..._comfortMessages,
      ];
      return allMessages[random % allMessages.length];
    } catch (e) {
      debugPrint('Error generating daily wisdom: $e');
      return 'بسم الله الرحمن الرحيم';
    }
  }

  /// Analyze text sentiment for mood detection
  static Future<String> analyzeSentiment(String text) async {
    try {
      // Simple keyword-based sentiment analysis
      if (_isSadMood(text)) {
        return 'sad';
      } else if (_isHappyMood(text)) {
        return 'happy';
      } else if (_isStressedMood(text)) {
        return 'stressed';
      } else {
        return 'neutral';
      }
    } catch (e) {
      debugPrint('Error analyzing sentiment: $e');
      return 'neutral';
    }
  }

  // --- Helper Methods ---
  
  static bool _isSadMood(String text) {
    final sadKeywords = [
      'حزين', 'حزن', 'كئيب', 'مكتئب', 'اكتئاب', 'وحيد', 'وحدة',
      'يأس', 'يائس', 'فشل', 'فاشل', 'خسرت', 'خسارة', 'مؤلم',
      'ألم', 'تعب', 'متعب', 'إرهاق', 'مرهق', 'حزين', 'كسر',
      'مكسور', 'فقدت', 'فقدان', 'وفاة', 'مات', 'مرض', 'مريض',
      'sad', 'depressed', 'lonely', 'hurt', 'pain', 'loss', 'fail',
    ];
    return sadKeywords.any((keyword) => text.toLowerCase().contains(keyword));
  }

  static bool _isHappyMood(String text) {
    final happyKeywords = [
      'سعيد', 'سعادة', 'فرح', 'فرحان', 'مسرور', 'سرور', 'بهجة',
      'نجح', 'نجاح', 'فاز', 'فوز', 'انتصار', 'رائع', 'عظيم',
      'ممتاز', 'جميل', 'جمال', 'حب', 'أحب', 'أحبك', 'عشق',
      'happy', 'joy', 'excited', 'wonderful', 'amazing', 'great',
      'success', 'won', 'love', 'beautiful', 'excellent',
    ];
    return happyKeywords.any((keyword) => text.toLowerCase().contains(keyword));
  }

  static bool _isStressedMood(String text) {
    final stressedKeywords = [
      'قلق', 'قلق', 'خوف', 'خائف', 'توتر', 'متوتر', 'ضغط',
      'مضغوط', 'مشكلة', 'مشاكل', 'صعب', 'صعوبة', 'عسير',
      'محرج', 'حرج', 'خجل', 'خجول', 'خائب', 'خيبة',
      'stressed', 'anxious', 'worried', 'afraid', 'scared', 'problem',
      'difficult', 'hard', 'tough', 'pressure',
    ];
    return stressedKeywords.any((keyword) => text.toLowerCase().contains(keyword));
  }

  /// Call OpenAI API (for premium version)
  static Future<String> callOpenAIAPI({
    required String prompt,
    required String apiKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _modelName,
          'messages': [
            {
              'role': 'system',
              'content': 'أنت مساعد روحي ذكي يقدم الإلهام والدعم النفسي بطريقة إسلامية. '
                  'ركز على الأمل والإيمان والصبر. استجب باللغة العربية.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.8,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'تذكّر أن الله معك دائماً. 🤲';
      } else {
        return 'عذراً، حدث خطأ. حاول مرة أخرى. 🙏';
      }
    } catch (e) {
      debugPrint('Error calling OpenAI API: $e');
      return 'استعن بالله ولا تعجز. 💪';
    }
  }
}

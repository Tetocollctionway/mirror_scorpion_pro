import 'package:flutter/foundation.dart';

class CreativityService extends ChangeNotifier {
  // Forbidden categories and their keywords
  static const Map<String, List<String>> _forbiddenKeywords = {
    'تنمر': ['غبي', 'فاشل', 'قبيح', 'ضعيف', 'تافه', 'سخيف', 'أحمق', 'حقير', 'دنيء'],
    'كراهية': ['عرق', 'دين', 'لون', 'طائفة', 'مذهب', 'كافر', 'ملحد', 'عدو', 'اقتل', 'أبد'],
    'تلامس/جنس': ['لمس', 'تلامس', 'جسد', 'عري', 'جنس', 'قبلة', 'حضن', 'فراش', 'شهوة'],
    'بذاءة': ['بذيء', 'لعن', 'شتم', 'سب', 'قذف', 'خنزير', 'كلب', 'حمار'],
    'سخرية مفرطة': ['أضحوكة', 'مهزلة', 'مسخرة', 'فضيحة', 'عار', 'ذل', 'هوان'],
  };

  static String checkAndProcessContent(String text) {
    if (text.trim().isEmpty) {
      return "⚠️ الرجاء كتابة شيء ما في ركن الإبداع.";
    }

    String lowerText = text.toLowerCase();
    List<String> violations = [];

    _forbiddenKeywords.forEach((category, keywords) {
      for (var keyword in keywords) {
        if (lowerText.contains(keyword)) {
          violations.add(category);
          break;
        }
      }
    });

    if (violations.isNotEmpty) {
      String violationMsg = violations.join(' و ');
      return "⚠️ ميرور: عذراً، لا يمكن قبول هذا المحتوى بسبب وجود ( $violationMsg ). نحن نشجع الإبداع النظيف والراقي.";
    }

    // Additional AI-like checks can be added here
    if (_hasExcessiveMockery(lowerText)) {
      return "⚠️ ميرور: السخرية المفرطة المتدنية مرفوضة. حاول جعل أسلوبك أكثر رقياً.";
    }

    return "✅ تم قبول إبداعك في ميرور! سيتم عرضه بعد المراجعة النهائية.";
  }

  static bool _hasExcessiveMockery(String text) {
    // Simple logic for excessive mockery detection
    int mockeryCount = 0;
    List<String> mockeryWords = ['هههه', 'مسخرة', 'نكتة', 'يضحك', 'غبي'];
    for (var word in mockeryWords) {
      if (text.contains(word)) mockeryCount++;
    }
    return mockeryCount > 5; // Example threshold
  }
}

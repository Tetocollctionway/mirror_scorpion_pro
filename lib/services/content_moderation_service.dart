import 'package:flutter/foundation.dart';

class ContentModerationService extends ChangeNotifier {
  // Forbidden words and patterns
  static const List<String> _forbiddenWords = [
    // Hate speech - عنصرية وكراهية (عرق، دين، نوع)
    'كافر', 'ملحد', 'مرتد', 'وثني', 'مشرك', 'يهودي', 'نصراني', 'شيعي', 'سني', 'وهابي',
    'عنصري', 'حقير', 'عبيد', 'بربري', 'متخلف', 'إرهابي', 'نجس', 'رافضي', 'ناصبي',
    
    // Bullying - تنمر وتجريح
    'غبي', 'أحمق', 'ضعيف', 'فاشل', 'وسخ', 'قذر', 'كسول', 'خاسر', 'مسكين', 'تافه',
    'بشع', 'سمين', 'قزم', 'معاق', 'أهبل', 'مغفل', 'فضيحة', 'عار', 'ذليل',
    
    // Sexual content & Innuendo - محتوى جنسي وتلميحات
    'جنس', 'عري', 'فاحش', 'بذيء', 'خليع', 'ماجن', 'فسق', 'زنا', 'لواط', 'ميول',
    'نهد', 'فرج', 'قضيب', 'شهوة', 'إغراء', 'قبلة', 'حضن', 'سرير', 'علاقة',
    
    // Profanity - كلمات بذيئة وسب
    'لعن', 'شتم', 'سب', 'قذف', 'خنزير', 'حمار', 'كلب', 'جحش', 'بهيمة', 'تفو',
    'يلعن', 'نيك', 'شرموط', 'قحبة', 'عرص', 'خول', 'منيوك', 'كس', 'زب',
    
    // Excessive mockery - سخرية مفرطة متدنية
    'أضحوكة', 'سخيف', 'مهزلة', 'مسخرة', 'فضيحة', 'حقارة', 'دناءة', 'سخرية',
    'استهزاء', 'تطاول', 'تقليل', 'تحقير', 'هزؤ', 'نكتة', 'مضحك',
  ];

  static const List<String> _suspiciousPatterns = [
    // Racial discrimination patterns
    r'عرق.*دون',
    r'جنس.*أفضل',
    r'لون.*أسوأ',
    r'أصل.*حقير',
    
    // Sexual innuendo patterns
    r'جسد.*عاري',
    r'ملابس.*قليلة',
    r'حركة.*إغواء',
    r'لمس.*محرم',
    
    // Extreme mockery patterns
    r'يستحق.*الموت',
    r'يستحق.*التعذيب',
    r'يستحق.*الإهانة',
  ];

  // Moderation result
  class ModerationResult {
    final bool isApproved;
    final String message;
    final List<String> violatedRules;
    final double riskScore; // 0.0 to 1.0

    ModerationResult({
      required this.isApproved,
      required this.message,
      required this.violatedRules,
      required this.riskScore,
    });
  }

  /// Check content for violations
  Future<ModerationResult> checkContent(String content) async {
    final violations = <String>[];
    double riskScore = 0.0;

    // Check for forbidden words
    for (final word in _forbiddenWords) {
      if (_containsWord(content, word)) {
        violations.add('Forbidden word detected: $word');
        riskScore += 0.15;
      }
    }

    // Check for suspicious patterns
    for (final pattern in _suspiciousPatterns) {
      if (_matchesPattern(content, pattern)) {
        violations.add('Suspicious pattern detected');
        riskScore += 0.20;
      }
    }

    // Check for hate speech indicators
    if (_containsHateSpeech(content)) {
      violations.add('Hate speech indicators detected');
      riskScore += 0.25;
    }

    // Check for bullying indicators
    if (_containsBullyingContent(content)) {
      violations.add('Bullying content detected');
      riskScore += 0.20;
    }

    // Check for excessive negativity
    if (_containsExcessiveNegativity(content)) {
      violations.add('Excessive negativity detected');
      riskScore += 0.10;
    }

    // Normalize risk score
    riskScore = (riskScore / 1.0).clamp(0.0, 1.0);

    final isApproved = violations.isEmpty && riskScore < 0.3;
    final message = isApproved
        ? 'Content approved for publication'
        : 'Content contains violations and requires review';

    return ModerationResult(
      isApproved: isApproved,
      message: message,
      violatedRules: violations,
      riskScore: riskScore,
    );
  }

  /// Check if content contains a specific word (case-insensitive)
  bool _containsWord(String content, String word) {
    final regex = RegExp(r'\b' + word + r'\b', caseSensitive: false);
    return regex.hasMatch(content);
  }

  /// Check if content matches a pattern
  bool _matchesPattern(String content, String pattern) {
    try {
      final regex = RegExp(pattern, caseSensitive: false);
      return regex.hasMatch(content);
    } catch (e) {
      return false;
    }
  }

  /// Detect hate speech
  bool _containsHateSpeech(String content) {
    final hateSpeechIndicators = [
      'كل.*يجب.*يموت',
      'جميع.*يستحقون.*العذاب',
      'العرق.*أفضل',
      'الدين.*أسوأ',
      'الجنس.*أدنى',
      'يجب.*نقتل',
      'يجب.*نبيد',
    ];

    for (final indicator in hateSpeechIndicators) {
      if (_matchesPattern(content, indicator)) {
        return true;
      }
    }
    return false;
  }

  /// Detect bullying content
  bool _containsBullyingContent(String content) {
    final bullyingIndicators = [
      'أنت.*غبي',
      'أنت.*أحمق',
      'أنت.*فاشل',
      'أنت.*وسخ',
      'يجب.*تموت',
      'يجب.*تختفي',
      'أنت.*كسول',
      'أنت.*ضعيف',
    ];

    for (final indicator in bullyingIndicators) {
      if (_matchesPattern(content, indicator)) {
        return true;
      }
    }
    return false;
  }

  /// Detect excessive negativity
  bool _containsExcessiveNegativity(String content) {
    final negativeWords = [
      'أسوأ', 'فظيع', 'مرعب', 'مكروه', 'بغيض',
      'كريه', 'مقزز', 'شنيع', 'فاحش', 'ممقوت'
    ];

    int negativeCount = 0;
    for (final word in negativeWords) {
      if (_containsWord(content, word)) {
        negativeCount++;
      }
    }

    // If more than 30% of content is negative words
    return negativeCount > (content.split(' ').length * 0.3);
  }

  /// Get content safety score
  Future<double> getSafetyScore(String content) async {
    final result = await checkContent(content);
    return 1.0 - result.riskScore; // Convert to safety score (higher is better)
  }

  /// Filter content - remove or replace forbidden words
  String filterContent(String content) {
    String filtered = content;

    for (final word in _forbiddenWords) {
      final regex = RegExp(r'\b' + word + r'\b', caseSensitive: false);
      filtered = filtered.replaceAll(regex, '***');
    }

    return filtered;
  }

  /// Get detailed moderation report
  Future<Map<String, dynamic>> getModerationReport(String content) async {
    final result = await checkContent(content);

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'content_length': content.length,
      'is_approved': result.isApproved,
      'risk_score': result.riskScore,
      'safety_score': 1.0 - result.riskScore,
      'violations': result.violatedRules,
      'message': result.message,
      'recommendations': _getRecommendations(result),
    };
  }

  /// Get recommendations based on violations
  List<String> _getRecommendations(ModerationResult result) {
    final recommendations = <String>[];

    if (result.violatedRules.isEmpty) {
      recommendations.add('Content is safe for publication');
      return recommendations;
    }

    for (final violation in result.violatedRules) {
      if (violation.contains('Forbidden word')) {
        recommendations.add('Remove or replace forbidden words');
      } else if (violation.contains('Hate speech')) {
        recommendations.add('Remove hate speech content');
      } else if (violation.contains('Bullying')) {
        recommendations.add('Remove bullying and insulting language');
      } else if (violation.contains('Suspicious pattern')) {
        recommendations.add('Review and revise suspicious content');
      } else if (violation.contains('Negativity')) {
        recommendations.add('Reduce excessive negative language');
      }
    }

    if (result.riskScore > 0.7) {
      recommendations.add('This content requires manual review by moderators');
    }

    return recommendations;
  }

  /// Batch check multiple contents
  Future<Map<String, ModerationResult>> batchCheckContent(
    List<String> contents,
  ) async {
    final results = <String, ModerationResult>{};

    for (int i = 0; i < contents.length; i++) {
      results['content_$i'] = await checkContent(contents[i]);
    }

    return results;
  }
}

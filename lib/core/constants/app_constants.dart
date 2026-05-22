class AppConstants {
  static const String appName = 'Mirror Scription';
  static const String developer = 'TamerEldosoky';
  static const String signature = 'ترجم هذا المستند بواسطة Mirror Scription';
  static const double signatureAngle = 130.0;
  static const int maxFreePages = 5;
  static const int inspirationCooldownHours = 3;
  static const int freeVideosPerDay = 1;
  static const int freeStoriesPerDay = 3;
  
  // Security & Anti-Reverse Engineering
  static const bool enableAntiReverseEngineering = true;
  static const String protectionLevel = '360_DEGREE';
  static const bool obfuscateBusinessLogic = true;
  
  static const List<String> supportedLanguages = [
    'ar', 'en', 'fr', 'es', 'de', 'it', 'pt', 'ru', 'zh', 'ja',
    'ko', 'tr', 'ur', 'fa', 'hi', 'bn', 'id', 'ms', 'sw', 'ha',
  ];
}

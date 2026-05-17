class IslamicStory {
  final String id;
  // خريطة شايلة العناوين: {'ar': 'عنوان', 'en': 'Title', 'tr': 'Başlık'}
  final Map<String, String> titles;
  // خريطة شايلة نصوص القصة كاملة لكل لغة
  final Map<String, String> contents;
  // خريطة شايلة الدروس المستفادة
  final Map<String, String> morals;
  final String source;
  final bool isProphetsStory;

  const IslamicStory({
    required this.id,
    required this.titles,
    required this.contents,
    required this.morals,
    required this.source,
    this.isProphetsStory = false,
  });

  // بيجيب النص بناءً على رمز اللغة، ولو مش موجود يرجع الإنجليزي كافتراضي
  String getTitle(String langCode) => titles[langCode] ?? titles['en'] ?? '';
  String getContent(String langCode) => contents[langCode] ?? contents['en'] ?? '';
  String getMoral(String langCode) => morals[langCode] ?? morals['en'] ?? '';

  factory IslamicStory.fromJson(Map<String, dynamic> json) {
    return IslamicStory(
      id: json['id'] as String,
      titles: Map<String, String>.from(json['titles']),
      contents: Map<String, String>.from(json['contents']),
      morals: Map<String, String>.from(json['morals']),
      source: json['source'] as String,
      isProphetsStory: json['isProphetsStory'] as bool? ?? false,
    );
  }
}

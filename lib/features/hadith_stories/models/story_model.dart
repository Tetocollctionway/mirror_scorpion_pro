class IslamicStory {
  final int id;
  final Map<String, String> titles;
  final Map<String, String> contents;
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

  // Direct getters for compatibility
  String get titleAr => titles['ar'] ?? '';
  String get titleEn => titles['en'] ?? titles['ar'] ?? '';
  String get storyAr => contents['ar'] ?? '';
  String get storyEn => contents['en'] ?? contents['ar'] ?? '';
  String get moralAr => morals['ar'] ?? '';
  String get moralEn => morals['en'] ?? morals['ar'] ?? '';

  String getTitle(String langCode) => titles[langCode] ?? titles['en'] ?? '';
  String getContent(String langCode) => contents[langCode] ?? contents['en'] ?? '';
  String getMoral(String langCode) => morals[langCode] ?? morals['en'] ?? '';

  factory IslamicStory.fromJson(Map<String, dynamic> json) {
    return IslamicStory(
      id: json['id'] as int,
      titles: Map<String, String>.from(json['titles'] as Map),
      contents: Map<String, String>.from(json['contents'] as Map),
      morals: Map<String, String>.from(json['morals'] as Map),
      source: json['source'] as String,
      isProphetsStory: json['isProphetsStory'] as bool? ?? false,
    );
  }
}

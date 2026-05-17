import '../models/story_model.dart';
import '../data/stories_data.dart';

class StoryService {
  // جلب كل القصص
  static List<IslamicStory> getAllStories() {
    return StoriesData.stories;
  }

  // جلب قصص الأنبياء فقط
  static List<IslamicStory> getProphetStories() {
    return StoriesData.stories.where((s) => s.isProphetsStory).toList();
  }

  // البحث عن قصة معينة باللغة المختارة
  static IslamicStory getStoryById(String id) {
    return StoriesData.stories.firstWhere((s) => s.id == id);
  }

  // ميزة ميرور: ترجمة القصة "طيران" لو اللغة مش موجودة
  // ملاحظة: هنا بنربط مع محرك ترجمة ميرور (سيتصل لاحقاً بـ MirrorTranslationEngine)
  static Future<String> getOrTranslateContent(IslamicStory story, String targetLang) async {
    if (story.contents.containsKey(targetLang)) {
      return story.contents[targetLang]!;
    } else {
      // هنا بننادي على محرك الترجمة الخاص بك (Mirror Engine)
      // كمثال حالياً بنرجع الإنجليزي لحين ربط الـ API الخاص بالترجمة
      return "Translation to $targetLang coming soon from Mirror Engine: ${story.contents['en']}";
    }
  }
}

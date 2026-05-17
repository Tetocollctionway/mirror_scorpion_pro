import 'dart:async';

class DatabaseService {
  // هنا بنجهز الخزنة لحفظ كلماتك وترجماتك
  
  Future<void> saveTranslation(String original, String translated) async {
    // كود الحفظ في قاعدة البيانات
    print("تم حفظ النص في ذاكرة ميرور: $original -> $translated");
  }

  Future<List<Map<String, String>>> getHistory() async {
    // كود استرجاع تاريخك (اللي كتبناه قبل كدة)
    return [
      {"original": "مرحباً", "translated": "Hello"},
      {"original": "كيف حالك", "translated": "How are you?"}
    ];
  }
}

// --- Integrated Content ---
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class DatabaseService extends ChangeNotifier {
  List<Map<String, dynamic>> _hadiths = [];
  List<Map<String, dynamic>> _quranStories = [];
  List<Map<String, dynamic>> _prophetStories = [];
  List<Map<String, dynamic>> _womenStories = [];
  List<Map<String, dynamic>> _animalStories = [];
  List<Map<String, dynamic>> _humanStories = [];
  List<Map<String, dynamic>> _nationsStories = [];
  
  bool _isLoaded = false;

  List<Map<String, dynamic>> get hadiths => _hadiths;
  List<Map<String, dynamic>> get quranStories => _quranStories;
  List<Map<String, dynamic>> get prophetStories => _prophetStories;
  List<Map<String, dynamic>> get womenStories => _womenStories;
  List<Map<String, dynamic>> get animalStories => _animalStories;
  List<Map<String, dynamic>> get humanStories => _humanStories;
  List<Map<String, dynamic>> get nationsStories => _nationsStories;
  bool get isLoaded => _isLoaded;

  Future<void> loadAllData() async {
    try {
      final hadithsJson = await rootBundle.loadString('assets/data/hadiths.json');
      final storiesJson = await rootBundle.loadString('assets/data/stories.json');
      
      final hadithsData = jsonDecode(hadithsJson);
      final storiesData = jsonDecode(storiesJson);

      _hadiths = List<Map<String, dynamic>>.from(hadithsData['hadiths'] ?? []);
      _quranStories = List<Map<String, dynamic>>.from(storiesData['quran'] ?? []);
      _prophetStories = List<Map<String, dynamic>>.from(storiesData['prophets'] ?? []);
      _womenStories = List<Map<String, dynamic>>.from(storiesData['women'] ?? []);
      _animalStories = List<Map<String, dynamic>>.from(storiesData['animals'] ?? []);
      _humanStories = List<Map<String, dynamic>>.from(storiesData['humans'] ?? []);
      _nationsStories = List<Map<String, dynamic>>.from(storiesData['nations'] ?? []);
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Database loading error: $e');
    }
  }

  // Get random hadith
  Map<String, dynamic> getRandomHadith() {
    if (_hadiths.isEmpty) {
      return {
        'text': 'عن عمر بن الخطاب رضي الله عنه قال: سمعت رسول الله صلى الله عليه وسلم يقول: "إنما الأعمال بالنيات"',
        'source': 'رواه البخاري ومسلم',
        'explanation': 'معنى الحديث: أن قيمة العمل تكون بنية صاحبه',
      };
    }
    final random = Random();
    return _hadiths[random.nextInt(_hadiths.length)];
  }

  // Get random story from specific category
  Map<String, dynamic> getRandomStory(String category) {
    final random = Random();
    List<Map<String, dynamic>> stories;
    
    switch (category) {
      case 'quran':
        stories = _quranStories;
        break;
      case 'prophets':
        stories = _prophetStories;
        break;
      case 'women':
        stories = _womenStories;
        break;
      case 'animals':
        stories = _animalStories;
        break;
      case 'humans':
        stories = _humanStories;
        break;
      case 'nations':
        stories = _nationsStories;
        break;
      default:
        stories = _quranStories;
    }

    if (stories.isEmpty) {
      return {'title': 'قصة', 'text': 'يوجد قصة هنا', 'category': category};
    }
    return stories[random.nextInt(stories.length)];
  }
}

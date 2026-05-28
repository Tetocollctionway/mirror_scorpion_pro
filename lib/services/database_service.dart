import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class DatabaseService extends ChangeNotifier {
  // --- Translation History ---
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() {
    return _instance;
  }
  
  DatabaseService._internal();

  // --- Content Storage ---
  List<Map<String, dynamic>> _hadiths = [];
  List<Map<String, dynamic>> _quranStories = [];
  List<Map<String, dynamic>> _prophetStories = [];
  List<Map<String, dynamic>> _womenStories = [];
  List<Map<String, dynamic>> _animalStories = [];
  List<Map<String, dynamic>> _humanStories = [];
  List<Map<String, dynamic>> _nationsStories = [];
  List<Map<String, String>> _translationHistory = [];
  
  bool _isLoaded = false;

  // --- Getters ---
  List<Map<String, dynamic>> get hadiths => _hadiths;
  List<Map<String, dynamic>> get quranStories => _quranStories;
  List<Map<String, dynamic>> get prophetStories => _prophetStories;
  List<Map<String, dynamic>> get womenStories => _womenStories;
  List<Map<String, dynamic>> get animalStories => _animalStories;
  List<Map<String, dynamic>> get humanStories => _humanStories;
  List<Map<String, dynamic>> get nationsStories => _nationsStories;
  List<Map<String, String>> get translationHistory => _translationHistory;
  bool get isLoaded => _isLoaded;

  // --- Load All Data ---
  Future<void> loadAllData() async {
    try {
      // Load Hadith Qudsi as primary hadith source
      final hadithsJson = await rootBundle.loadString('assets/data/hadith_qudsi.json');
      final storiesJson = await rootBundle.loadString('assets/data/quran_stories.json');
      
      final hadithsData = jsonDecode(hadithsJson);
      final storiesData = jsonDecode(storiesJson);

      // Hadith Qudsi is a top-level array
      _hadiths = (hadithsData as List).map((e) => {
        'text': e['text_ar'],
        'source': e['source'],
        'explanation': e['explanation_ar'],
        'narrator': 'حديث قدسي'
      }).toList();

      _quranStories = List<Map<String, dynamic>>.from(storiesData['quran'] ?? []);
      _prophetStories = List<Map<String, dynamic>>.from(storiesData['prophets'] ?? []);
      _womenStories = List<Map<String, dynamic>>.from(storiesData['women'] ?? []);
      _animalStories = List<Map<String, dynamic>>.from(storiesData['animals'] ?? []);
      _humanStories = List<Map<String, dynamic>>.from(storiesData['humans'] ?? []);
      _nationsStories = List<Map<String, dynamic>>.from(storiesData['nations'] ?? []);
      
      // Ensure we catch any extra categories
      storiesData.forEach((key, value) {
        if (value is List && !['quran', 'prophets', 'women', 'animals', 'humans', 'nations'].contains(key)) {
          // You could add them to a general list or handle specifically
        }
      });
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Database loading error: $e');
    }
  }

  // --- Translation History Management ---
  Future<void> saveTranslation(String original, String translated, {String? sourceLang, String? targetLang}) async {
    _translationHistory.insert(0, {
      'original': original,
      'translated': translated,
      'sourceLang': sourceLang ?? 'unknown',
      'targetLang': targetLang ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 100 translations
    if (_translationHistory.length > 100) {
      _translationHistory.removeLast();
    }
    notifyListeners();
  }

  Future<List<Map<String, String>>> getHistory() async {
    return _translationHistory;
  }

  // --- Random Content Getters ---
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

  // --- Load JSON Helper (for compatibility) ---
  Future<Map<String, dynamic>> loadJson(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      return jsonDecode(jsonString);
    } catch (e) {
      debugPrint('Error loading JSON from $assetPath: $e');
      return {};
    }
  }
}

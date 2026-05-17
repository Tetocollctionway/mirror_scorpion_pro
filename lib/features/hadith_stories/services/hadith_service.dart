import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/hadith_model.dart';

class HadithService {
  static const String _baseUrl = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions';

  static Future<Hadith> getRandomHadith(HadithCollection collection, {bool includeArabic = true}) async {
    final randomNumber = _getRandomHadithNumber(collection.totalHadith);
    return getHadithByNumber(collection, randomNumber, includeArabic: includeArabic);
  }

  static int _getRandomHadithNumber(int max) {
    final now = DateTime.now();
    final seed = now.millisecondsSinceEpoch;
    return (seed % max) + 1;
  }

  static Future<Hadith> getHadithByNumber(HadithCollection collection, int number, {bool includeArabic = true}) async {
    try {
      // Fetch English hadith
      final engUrl = '$_baseUrl/eng-${collection.apiPrefix}/$number.min.json';
      final engResponse = await http.get(Uri.parse(engUrl));

      if (engResponse.statusCode != 200) {
        throw Exception('Failed to load hadith: ${engResponse.statusCode}');
      }

      final Map<String, dynamic> engData = json.decode(engResponse.body);
      final engHadith = engData['hadiths'] is List && (engData['hadiths'] as List).isNotEmpty
          ? (engData['hadiths'] as List).first as Map<String, dynamic>
          : <String, dynamic>{};

      String? arabicText;
      if (includeArabic) {
        try {
          final arUrl = '$_baseUrl/ara-${collection.apiPrefix}/$number.min.json';
          final arResponse = await http.get(Uri.parse(arUrl));
          if (arResponse.statusCode == 200) {
            final Map<String, dynamic> arData = json.decode(arResponse.body);
            final arHadith = arData['hadiths'] is List && (arData['hadiths'] as List).isNotEmpty
                ? (arData['hadiths'] as List).first as Map<String, dynamic>
                : <String, dynamic>{};
            arabicText = arHadith['text'] as String?;
          }
        } catch (_) {
          // Arabic text not available
        }
      }

      final section = engData['metadata']?['section'] is Map
          ? (engData['metadata']!['section'] as Map<String, dynamic>).values.first as String?
          : null;

      return Hadith.fromJson(
        engHadith,
        bookName: collection.displayNameEn,
        textAr: arabicText,
        section: section,
      );
    } catch (e) {
      debugPrint('HadithService error: $e');
      rethrow;
    }
  }

  static List<HadithCollection> getAvailableCollections() {
    return HadithCollection.collections;
  }
}

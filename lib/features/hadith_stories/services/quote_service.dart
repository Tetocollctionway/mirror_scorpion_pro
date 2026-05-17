import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class Quote {
  final String text;
  final String author;

  const Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['q'] as String? ?? json['quote'] as String? ?? json['text'] as String? ?? '',
      author: json['a'] as String? ?? json['author'] as String? ?? 'Unknown',
    );
  }
}

class IslamicQuote {
  final String textAr;
  final String textEn;
  final String? attribution;

  const IslamicQuote({
    required this.textAr,
    required this.textEn,
    this.attribution,
  });
}

class QuoteService {
  static const String _zenQuotesUrl = 'https://zenquotes.io/api/random';

  static Future<Quote> getRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(_zenQuotesUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return Quote.fromJson(data.first as Map<String, dynamic>);
        }
      }
      throw Exception('Failed to load quote');
    } catch (e) {
      debugPrint('QuoteService error: $e');
      rethrow;
    }
  }

  static List<IslamicQuote> getLocalIslamicQuotes() {
    return _islamicQuotes;
  }

  static IslamicQuote getRandomIslamicQuote() {
    final now = DateTime.now();
    final seed = now.millisecondsSinceEpoch;
    return _islamicQuotes[seed % _islamicQuotes.length];
  }

  static const List<IslamicQuote> _islamicQuotes = [
    IslamicQuote(
      textAr: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      textEn: 'Indeed, with hardship comes ease.',
      attribution: 'Quran 94:6',
    ),
    IslamicQuote(
      textAr: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      textEn: 'And whoever relies upon Allah, then He is sufficient for him.',
      attribution: 'Quran 65:3',
    ),
    IslamicQuote(
      textAr: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      textEn: 'For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease.',
      attribution: 'Quran 94:5-6',
    ),
    IslamicQuote(
      textAr: 'رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا',
      textEn: 'Our Lord, do not impose blame upon us if we have forgotten or erred.',
      attribution: 'Quran 2:286',
    ),
    IslamicQuote(
      textAr: 'أَحْسِنُوا إِنَّ اللَّهَ يُحِبُّ الْمُحْسِنِينَ',
      textEn: 'Do good; indeed, Allah loves the doers of good.',
      attribution: 'Quran 2:195',
    ),
    IslamicQuote(
      textAr: 'وَتَوَاصَوْا بِالصَّبْرِ وَتَوَاصَوْا بِالْمَرْحَمَةِ',
      textEn: 'And encourage one another to patience and encourage one another to compassion.',
      attribution: 'Quran 90:17',
    ),
    IslamicQuote(
      textAr: 'خَيْرُ النَّاسِ أَنْفَعُهُمْ لِلنَّاسِ',
      textEn: 'The best of people are those who are most beneficial to others.',
      attribution: 'Hadith — Al-Mu\'jam al-Awsat',
    ),
    IslamicQuote(
      textAr: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      textEn: 'Whoever believes in Allah and the Last Day, let him speak good or remain silent.',
      attribution: 'Hadith — Sahih al-Bukhari, Muslim',
    ),
    IslamicQuote(
      textAr: 'الْيَأْسُ مِمَّا فِي أَيْدِي النَّاسِ هُوَ الْغِنَى',
      textEn: 'True wealth is not having many possessions, but being content with what you have.',
      attribution: 'Hadith — Sahih al-Bukhari',
    ),
    IslamicQuote(
      textAr: 'أَحَبُّ الْأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ',
      textEn: 'The most beloved of deeds to Allah is the most consistent, even if it is small.',
      attribution: 'Hadith — Sahih al-Bukhari, Muslim',
    ),
    IslamicQuote(
      textAr: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
      textEn: 'My Lord, expand for me my breast and ease for me my task.',
      attribution: 'Quran 20:25-26',
    ),
    IslamicQuote(
      textAr: 'وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ ۖ إِنَّهُ لَا يَيْأَسُ مِن رَّوْحِ اللَّهِ إِلَّا الْقَوْمُ الْكَافِرُونَ',
      textEn: 'And despair not of relief from Allah. Indeed, no one despairs of relief from Allah except the disbelieving people.',
      attribution: 'Quran 12:87',
    ),
    IslamicQuote(
      textAr: 'إِنَّ اللَّهَ لَا يُغَيِّرُ مَا بِقَوْمٍ حَتَّى يُغَيِّرُوا مَا بِأَنفُسِهِمْ',
      textEn: 'Indeed, Allah will not change the condition of a people until they change what is in themselves.',
      attribution: 'Quran 13:11',
    ),
    IslamicQuote(
      textAr: 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ، وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا، وَخَالِقِ النَّاسَ بِخُلُقٍ حَسَنٍ',
      textEn: 'Fear Allah wherever you are, follow a bad deed with a good deed and it will erase it, and behave with good character towards people.',
      attribution: 'Hadith — Sunan At-Tirmidhi',
    ),
    IslamicQuote(
      textAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      textEn: 'O Allah, I ask You for pardon and well-being in this world and the Hereafter.',
      attribution: 'Hadith — Sunan Ibn Majah',
    ),
  ];
}

class Hadith {
  final int hadithNumber;
  final String text;
  final String? textAr;
  final String bookName;
  final int bookNumber;
  final String? grade;
  final String? section;

  const Hadith({
    required this.hadithNumber,
    required this.text,
    this.textAr,
    required this.bookName,
    required this.bookNumber,
    this.grade,
    this.section,
  });

  factory Hadith.fromJson(Map<String, dynamic> json, {String? bookName, String? textAr, String? section}) {
    return Hadith(
      hadithNumber: json['hadithnumber'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      textAr: textAr,
      bookName: bookName ?? json['book'] as String? ?? 'Unknown',
      bookNumber: json['reference']?['book'] as int? ?? 0,
      grade: json['grades'] is List && (json['grades'] as List).isNotEmpty
          ? (json['grades'] as List).map((g) => "${g['grade']}: ${g['name']}").join(', ')
          : null,
      section: section,
    );
  }
}

class HadithCollection {
  final String name;
  final String displayNameEn;
  final String displayNameAr;
  final String apiPrefix;
  final int totalHadith;
  final bool hasSections;

  const HadithCollection({
    required this.name,
    required this.displayNameEn,
    required this.displayNameAr,
    required this.apiPrefix,
    required this.totalHadith,
    this.hasSections = false,
  });

  static const List<HadithCollection> collections = [
    HadithCollection(
      name: 'bukhari',
      displayNameEn: 'Sahih al-Bukhari',
      displayNameAr: 'صحيح البخاري',
      apiPrefix: 'bukhari',
      totalHadith: 7558,
      hasSections: true,
    ),
    HadithCollection(
      name: 'muslim',
      displayNameEn: 'Sahih Muslim',
      displayNameAr: 'صحيح مسلم',
      apiPrefix: 'muslim',
      totalHadith: 5362,
      hasSections: true,
    ),
    HadithCollection(
      name: 'abudawud',
      displayNameEn: 'Sunan Abi Dawud',
      displayNameAr: 'سنن أبي داود',
      apiPrefix: 'abudawud',
      totalHadith: 5274,
      hasSections: true,
    ),
    HadithCollection(
      name: 'tirmidhi',
      displayNameEn: 'Jami\' at-Tirmidhi',
      displayNameAr: 'جامع الترمذي',
      apiPrefix: 'tirmidhi',
      totalHadith: 3956,
      hasSections: true,
    ),
    HadithCollection(
      name: 'nasai',
      displayNameEn: 'Sunan an-Nasai',
      displayNameAr: 'سنن النسائي',
      apiPrefix: 'nasai',
      totalHadith: 5762,
      hasSections: true,
    ),
    HadithCollection(
      name: 'ibnmajah',
      displayNameEn: 'Sunan Ibn Majah',
      displayNameAr: 'سنن ابن ماجه',
      apiPrefix: 'ibnmajah',
      totalHadith: 4341,
      hasSections: true,
    ),
  ];
}

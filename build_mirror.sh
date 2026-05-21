echo "بدء بناء مشروع Mirror..."

# 1. تحديث الـ main.dart
cat << 'EOD' > lib/main.dart
import 'package:flutter/material.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card2_dialogue/dialogue_screen.dart';
import 'features/card3_document/document_screen.dart';
import 'features/hadith_stories/hadith_stories_screen.dart';
import 'features/home_screen.dart';

void main() => runApp(const MaterialApp(home: HomeScreen(), routes: {
  '/translate': (context) => const TextTranslationScreen(),
  '/dialogue': (context) => const DialogueTranslationScreen(),
  '/document': (context) => const DocumentTranslationScreen(),
  '/stories': (context) => const HadithStoriesScreen(),
}));
EOD

echo "تم تحديث main.dart بنجاح."
echo "مشروعك الآن جاهز للعمل بالكروت الثلاثة."

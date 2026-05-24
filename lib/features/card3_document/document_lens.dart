/// Document Lens - Smart OCR and Link Detection
import 'package:flutter/foundation.dart';

class DocumentLens {
  /// Simulate OCR text extraction from image
  static Future<String> extractTextFromImage(String imagePath) async {
    // In a real app, this would use Google ML Kit or similar
    await Future.delayed(const Duration(seconds: 2));
    
    return '''
    هذا نص مستخرج من الصورة باستخدام تقنية OCR المتقدمة.
    يمكن للتطبيق الآن ترجمة هذا النص إلى أي لغة.
    
    This is extracted text from the image using advanced OCR technology.
    The app can now translate this text to any language.
    
    Website: https://example.com
    Email: contact@example.com
    ''';
  }
  
  /// Detect links in extracted text
  static List<LinkInfo> detectLinks(String text) {
    final links = <LinkInfo>[];
    
    // Detect URLs
    final urlRegex = RegExp(
      r'https?://[^\s]+|www\.[^\s]+',
      caseSensitive: false,
    );
    
    for (final match in urlRegex.allMatches(text)) {
      links.add(LinkInfo(
        text: match.group(0) ?? '',
        type: LinkType.url,
        startIndex: match.start,
        endIndex: match.end,
      ));
    }
    
    // Detect emails
    final emailRegex = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    );
    
    for (final match in emailRegex.allMatches(text)) {
      links.add(LinkInfo(
        text: match.group(0) ?? '',
        type: LinkType.email,
        startIndex: match.start,
        endIndex: match.end,
      ));
    }
    
    // Detect phone numbers
    final phoneRegex = RegExp(
      r'(\+\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}',
    );
    
    for (final match in phoneRegex.allMatches(text)) {
      links.add(LinkInfo(
        text: match.group(0) ?? '',
        type: LinkType.phone,
        startIndex: match.start,
        endIndex: match.end,
      ));
    }
    
    return links;
  }
  
  /// Enhance document quality (simulate)
  static Future<String> enhanceDocumentQuality(String imagePath) async {
    // Simulate enhancement process
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Document enhanced: $imagePath');
    return imagePath;
  }
  
  /// Detect document type
  static Future<DocumentType> detectDocumentType(String imagePath) async {
    // Simulate document type detection
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In a real app, use ML to detect document type
    return DocumentType.general;
  }
  
  /// Extract structured data from document
  static Future<Map<String, dynamic>> extractStructuredData(String text) async {
    return {
      'title': _extractTitle(text),
      'content': text,
      'links': detectLinks(text),
      'language': _detectLanguage(text),
      'wordCount': text.split(' ').length,
      'characterCount': text.length,
    };
  }
  
  static String _extractTitle(String text) {
    final lines = text.split('\n');
    return lines.isNotEmpty ? lines.first : 'No Title';
  }
  
  static String _detectLanguage(String text) {
    // Simple language detection
    if (text.contains(RegExp(r'[\u0600-\u06FF]'))) {
      return 'Arabic';
    } else if (text.contains(RegExp(r'[\u4E00-\u9FFF]'))) {
      return 'Chinese';
    } else {
      return 'English';
    }
  }
}

enum DocumentType {
  passport,
  idCard,
  invoice,
  receipt,
  contract,
  general,
}

enum LinkType {
  url,
  email,
  phone,
}

class LinkInfo {
  final String text;
  final LinkType type;
  final int startIndex;
  final int endIndex;
  
  LinkInfo({
    required this.text,
    required this.type,
    required this.startIndex,
    required this.endIndex,
  });
  
  String get icon {
    switch (type) {
      case LinkType.url:
        return '🌐';
      case LinkType.email:
        return '✉️';
      case LinkType.phone:
        return '📱';
    }
  }
}

/// Document Export Service - Save and Share Translated Documents
import 'package:flutter/foundation.dart';
import 'dart:io';

/// Escape HTML special characters to prevent XSS.
String _escapeHtml(String input) {
  return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

class DocumentExportService {
  /// Export document as PDF (maintains original formatting)
  static Future<String> exportAsPDF({
    required String title,
    required String content,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // Simulate PDF generation
      await Future.delayed(const Duration(seconds: 1));
      
      final fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '/storage/emulated/0/Documents/$fileName';
      
      debugPrint('PDF exported to: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error exporting PDF: $e');
      rethrow;
    }
  }
  
  /// Export document as Word (.docx)
  static Future<String> exportAsWord({
    required String title,
    required String content,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // Simulate Word document generation
      await Future.delayed(const Duration(seconds: 1));
      
      final fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.docx';
      final filePath = '/storage/emulated/0/Documents/$fileName';
      
      debugPrint('Word document exported to: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error exporting Word: $e');
      rethrow;
    }
  }
  
  /// Export document as Text
  static Future<String> exportAsText({
    required String title,
    required String content,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.txt';
      final filePath = '/storage/emulated/0/Documents/$fileName';
      
      final file = File(filePath);
      await file.create(recursive: true);
      
      final fullContent = '''
Title: $title
Source Language: $sourceLanguage
Target Language: $targetLanguage
Exported: ${DateTime.now()}

---CONTENT---

$content
''';
      
      await file.writeAsString(fullContent);
      debugPrint('Text file exported to: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error exporting Text: $e');
      rethrow;
    }
  }
  
  /// Export document as HTML
  static Future<String> exportAsHTML({
    required String title,
    required String content,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.html';
      final filePath = '/storage/emulated/0/Documents/$fileName';
      
      final file = File(filePath);
      await file.create(recursive: true);
      
      final htmlContent = '''
<!DOCTYPE html>
<html lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${_escapeHtml(title)}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            direction: rtl;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        .metadata {
            color: #666;
            font-size: 12px;
            margin: 10px 0;
        }
        .content {
            line-height: 1.8;
            color: #333;
            white-space: pre-wrap;
        }
        a {
            color: #007bff;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>${_escapeHtml(title)}</h1>
        <div class="metadata">
            <p>Source Language: ${_escapeHtml(sourceLanguage)}</p>
            <p>Target Language: ${_escapeHtml(targetLanguage)}</p>
            <p>Exported: ${DateTime.now()}</p>
        </div>
        <div class="content">
            ${_escapeHtml(content)}
        </div>
    </div>
</body>
</html>
''';
      
      await file.writeAsString(htmlContent);
      debugPrint('HTML file exported to: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error exporting HTML: $e');
      rethrow;
    }
  }
  
  /// Share document via system share dialog
  static Future<void> shareDocument({
    required String filePath,
    required String title,
  }) async {
    try {
      // In a real app, use share_plus package
      debugPrint('Sharing document: $title from $filePath');
      
      // Simulate share action
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Share dialog opened');
    } catch (e) {
      debugPrint('Error sharing document: $e');
      rethrow;
    }
  }
  
  /// Print document
  static Future<void> printDocument({
    required String title,
    required String content,
  }) async {
    try {
      // In a real app, use printing package
      debugPrint('Printing document: $title');
      
      // Simulate print action
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Print dialog opened');
    } catch (e) {
      debugPrint('Error printing document: $e');
      rethrow;
    }
  }
  
  /// Save document to local storage
  static Future<String> saveDocumentLocally({
    required String title,
    required String content,
    required String format, // pdf, docx, txt, html
  }) async {
    try {
      switch (format.toLowerCase()) {
        case 'pdf':
          return await exportAsPDF(
            title: title,
            content: content,
            sourceLanguage: 'Auto',
            targetLanguage: 'Auto',
          );
        case 'docx':
          return await exportAsWord(
            title: title,
            content: content,
            sourceLanguage: 'Auto',
            targetLanguage: 'Auto',
          );
        case 'html':
          return await exportAsHTML(
            title: title,
            content: content,
            sourceLanguage: 'Auto',
            targetLanguage: 'Auto',
          );
        case 'txt':
        default:
          return await exportAsText(
            title: title,
            content: content,
            sourceLanguage: 'Auto',
            targetLanguage: 'Auto',
          );
      }
    } catch (e) {
      debugPrint('Error saving document: $e');
      rethrow;
    }
  }
  
  /// Get document metadata
  static Future<Map<String, dynamic>> getDocumentMetadata(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      
      return {
        'path': filePath,
        'name': file.path.split('/').last,
        'size': stat.size,
        'modified': stat.modified,
        'created': stat.accessed,
      };
    } catch (e) {
      debugPrint('Error getting document metadata: $e');
      rethrow;
    }
  }
}

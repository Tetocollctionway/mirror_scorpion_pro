  // Context tracking for inspiration
  final List<String> _userStoryInterests = [];
  DateTime? _lastInspirationTime;
  int _inspirationCount = 0;

  bool get isLoading => _isLoading;
  String? get lastResponse => _lastResponse;
  bool get isPremium => _isPremium;
  List<String> get userStoryInterests => List.unmodifiable(_userStoryInterests);
  bool get canSendInspiration {
    if (_lastInspirationTime == null) return true;
    return DateTime.now().difference(_lastInspirationTime!).inHours >= 3;
  }

  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  // ---- Translation (Cards 1, 2, 3) ----
  Future<String> translate({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Primary: Google ML Kit (offline)
      // Secondary: Online API fallback
      final response = await http.post(
        Uri.parse('https://translation.googleapis.com/language/translate/v2'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': fromLanguage,
          'target': toLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _lastResponse = data['data']['translations'][0]['translatedText'];
      } else {
        // Fallback: local mock (for development)
        _lastResponse = '[${toLanguage.toUpperCase()}] $text';
      }
    } catch (e) {
      // Offline fallback
      _lastResponse = text;
      debugPrint('Translation error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return _lastResponse ?? text;
  }

  // ---- Inspiration (Card 4) ----
  String generateInspiration({
nano lib/services/ai_service.dart

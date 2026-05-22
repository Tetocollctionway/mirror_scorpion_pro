import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'content_moderation_service.dart';
import 'dart:convert';

class CreativityService extends ChangeNotifier {
  late SharedPreferences _prefs;
  final ContentModerationService _moderationService = ContentModerationService();
  
  List<UserStory> _userStories = [];
  List<UserStory> get userStories => _userStories;

  List<UserStory> _approvedStories = [];
  List<UserStory> get approvedStories => _approvedStories;

  CreativityService() {
    _initializeService();
  }

  Future<void> _initializeService() async {
    _prefs = await SharedPreferences.getInstance();
    _loadStories();
  }

  /// User Story Model
  class UserStory {
    final String id;
    final String title;
    final String content;
    final String category; // 'story', 'poem', 'wisdom', 'inspiration'
    final DateTime createdAt;
    final bool isApproved;
    final double safetyScore;
    final List<String> violations;
    final String? audioUrl;
    final String? videoUrl;
    final int views;
    final int likes;
    final String authorName;

    UserStory({
      required this.id,
      required this.title,
      required this.content,
      required this.category,
      required this.createdAt,
      this.isApproved = false,
      this.safetyScore = 0.0,
      this.violations = const [],
      this.audioUrl,
      this.videoUrl,
      this.views = 0,
      this.likes = 0,
      this.authorName = 'Anonymous',
    });

    Map<String, dynamic> toJson() => {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isApproved': isApproved,
      'safetyScore': safetyScore,
      'violations': violations,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'views': views,
      'likes': likes,
      'authorName': authorName,
    };

    factory UserStory.fromJson(Map<String, dynamic> json) => UserStory(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      isApproved: json['isApproved'] ?? false,
      safetyScore: json['safetyScore'] ?? 0.0,
      violations: List<String>.from(json['violations'] ?? []),
      audioUrl: json['audioUrl'],
      videoUrl: json['videoUrl'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      authorName: json['authorName'] ?? 'Anonymous',
    );
  }

  /// Create a new user story
  Future<UserStory> createStory({
    required String title,
    required String content,
    required String category,
    required String authorName,
  }) async {
    // ميرور: فحص صارم للمحتوى قبل التحويل أو النشر
    final result = await _moderationService.checkContent(content);
    final safetyScore = 1.0 - result.riskScore;

    // ميرور: تطبيق شروط "ركن الإبداع" الصارمة
    // منع: تنمر، تلامس، كراهية (عرق/دين/نوع)، كلمات بذيئة، تلميحات جنسية، سخرية مفرطة متدنية
    final bool passesMirrorRules = result.isApproved && 
                                  !content.contains('تلامس') && 
                                  !content.contains('لمس') &&
                                  result.riskScore < 0.25;

    final story = UserStory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      category: category,
      createdAt: DateTime.now(),
      isApproved: passesMirrorRules,
      safetyScore: safetyScore,
      violations: result.violatedRules,
      authorName: authorName,
    );

    _userStories.add(story);
    if (result.isApproved) {
      _approvedStories.add(story);
    }

    await _saveStories();
    notifyListeners();

    return story;
  }

  /// Generate audio for approved story
  Future<String?> generateAudio(
    String storyId, {
    required String voiceType, // 'voice_1_female', 'voice_2_male', etc.
  }) async {
    final story = _userStories.firstWhere(
      (s) => s.id == storyId,
      orElse: () => throw Exception('Story not found'),
    );

    // Only generate audio for approved stories
    if (!story.isApproved) {
      throw Exception('Cannot generate audio for unapproved story');
    }

    // Simulate audio generation
    // In real app, this would call a TTS service
    final audioUrl = 'https://audio.mirror-scorpion.app/story_${storyId}_$voiceType.mp3';

    // Update story with audio URL
    final index = _userStories.indexWhere((s) => s.id == storyId);
    _userStories[index] = UserStory(
      id: story.id,
      title: story.title,
      content: story.content,
      category: story.category,
      createdAt: story.createdAt,
      isApproved: story.isApproved,
      safetyScore: story.safetyScore,
      violations: story.violations,
      audioUrl: audioUrl,
      videoUrl: story.videoUrl,
      views: story.views,
      likes: story.likes,
      authorName: story.authorName,
    );

    await _saveStories();
    notifyListeners();

    return audioUrl;
  }

  /// Generate video for approved story
  Future<String?> generateVideo(
    String storyId, {
    required String style, // 'animated', 'cinematic', 'minimalist'
  }) async {
    final story = _userStories.firstWhere(
      (s) => s.id == storyId,
      orElse: () => throw Exception('Story not found'),
    );

    // Only generate video for approved stories
    if (!story.isApproved) {
      throw Exception('Cannot generate video for unapproved story');
    }

    // Simulate video generation
    // In real app, this would call a video generation service
    final videoUrl = 'https://video.mirror-scorpion.app/story_${storyId}_$style.mp4';

    // Update story with video URL
    final index = _userStories.indexWhere((s) => s.id == storyId);
    _userStories[index] = UserStory(
      id: story.id,
      title: story.title,
      content: story.content,
      category: story.category,
      createdAt: story.createdAt,
      isApproved: story.isApproved,
      safetyScore: story.safetyScore,
      violations: story.violations,
      audioUrl: story.audioUrl,
      videoUrl: videoUrl,
      views: story.views,
      likes: story.likes,
      authorName: story.authorName,
    );

    await _saveStories();
    notifyListeners();

    return videoUrl;
  }

  /// Clone user voice for story narration
  Future<String?> cloneUserVoice(
    String storyId, {
    required String voiceSampleUrl,
  }) async {
    final story = _userStories.firstWhere(
      (s) => s.id == storyId,
      orElse: () => throw Exception('Story not found'),
    );

    // Only clone voice for approved stories
    if (!story.isApproved) {
      throw Exception('Cannot clone voice for unapproved story');
    }

    // Simulate voice cloning
    // In real app, this would call a voice cloning service
    final clonedAudioUrl = 'https://audio.mirror-scorpion.app/story_${storyId}_cloned.mp3';

    return clonedAudioUrl;
  }

  /// Get moderation status for a story
  Future<Map<String, dynamic>> getModerationStatus(String storyId) async {
    final story = _userStories.firstWhere(
      (s) => s.id == storyId,
      orElse: () => throw Exception('Story not found'),
    );

    return {
      'id': storyId,
      'is_approved': story.isApproved,
      'safety_score': story.safetyScore,
      'violations': story.violations,
      'can_generate_audio': story.isApproved,
      'can_generate_video': story.isApproved,
      'can_clone_voice': story.isApproved,
      'status': story.isApproved ? 'approved' : 'pending_review',
    };
  }

  /// Get detailed moderation report
  Future<Map<String, dynamic>> getDetailedReport(String storyId) async {
    final story = _userStories.firstWhere(
      (s) => s.id == storyId,
      orElse: () => throw Exception('Story not found'),
    );

    return await _moderationService.getModerationReport(story.content);
  }

  /// Like a story
  Future<void> likeStory(String storyId) async {
    final index = _userStories.indexWhere((s) => s.id == storyId);
    if (index != -1) {
      final story = _userStories[index];
      _userStories[index] = UserStory(
        id: story.id,
        title: story.title,
        content: story.content,
        category: story.category,
        createdAt: story.createdAt,
        isApproved: story.isApproved,
        safetyScore: story.safetyScore,
        violations: story.violations,
        audioUrl: story.audioUrl,
        videoUrl: story.videoUrl,
        views: story.views,
        likes: story.likes + 1,
        authorName: story.authorName,
      );
      await _saveStories();
      notifyListeners();
    }
  }

  /// Increment view count
  Future<void> incrementViews(String storyId) async {
    final index = _userStories.indexWhere((s) => s.id == storyId);
    if (index != -1) {
      final story = _userStories[index];
      _userStories[index] = UserStory(
        id: story.id,
        title: story.title,
        content: story.content,
        category: story.category,
        createdAt: story.createdAt,
        isApproved: story.isApproved,
        safetyScore: story.safetyScore,
        violations: story.violations,
        audioUrl: story.audioUrl,
        videoUrl: story.videoUrl,
        views: story.views + 1,
        likes: story.likes,
        authorName: story.authorName,
      );
      await _saveStories();
      notifyListeners();
    }
  }

  /// Delete a story
  Future<void> deleteStory(String storyId) async {
    _userStories.removeWhere((s) => s.id == storyId);
    _approvedStories.removeWhere((s) => s.id == storyId);
    await _saveStories();
    notifyListeners();
  }

  /// Get stories by category
  List<UserStory> getStoriesByCategory(String category) {
    return _userStories.where((s) => s.category == category).toList();
  }

  /// Get approved stories only
  List<UserStory> getApprovedStories() {
    return _approvedStories;
  }

  /// Search stories
  List<UserStory> searchStories(String query) {
    return _userStories
        .where((s) =>
            s.title.toLowerCase().contains(query.toLowerCase()) ||
            s.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Save stories to local storage
  Future<void> _saveStories() async {
    final json = jsonEncode(_userStories.map((s) => s.toJson()).toList());
    await _prefs.setString('user_stories', json);
  }

  /// Load stories from local storage
  Future<void> _loadStories() async {
    final json = _prefs.getString('user_stories');
    if (json != null) {
      final list = jsonDecode(json) as List;
      _userStories = list.map((item) => UserStory.fromJson(item)).toList();
      _approvedStories = _userStories.where((s) => s.isApproved).toList();
      notifyListeners();
    }
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'total_stories': _userStories.length,
      'approved_stories': _approvedStories.length,
      'pending_stories': _userStories.length - _approvedStories.length,
      'total_views': _userStories.fold<int>(0, (sum, s) => sum + s.views),
      'total_likes': _userStories.fold<int>(0, (sum, s) => sum + s.likes),
      'average_safety_score': _userStories.isEmpty
          ? 0.0
          : _userStories.fold<double>(0, (sum, s) => sum + s.safetyScore) /
              _userStories.length,
      'stories_by_category': {
        'story': _userStories.where((s) => s.category == 'story').length,
        'poem': _userStories.where((s) => s.category == 'poem').length,
        'wisdom': _userStories.where((s) => s.category == 'wisdom').length,
        'inspiration': _userStories.where((s) => s.category == 'inspiration').length,
      },
    };
  }
}

import 'package:flutter/material.dart';
import 'premium_verification_service.dart';

/// Feature Access Control - Manages Premium Features
class FeatureAccessControl {
  static final FeatureAccessControl _instance = FeatureAccessControl._internal();
  
  factory FeatureAccessControl() => _instance;
  FeatureAccessControl._internal();
  
  late PremiumVerificationService _premiumService;
  
  // Premium features list
  static const Map<String, String> premiumFeatures = {
    'chess_game': 'لعبة الشطرنج',
    'rubik_cube_enhanced': 'مكعب روبيك المحسّن',
    'document_lens': 'عدسة المستندات الذكية',
    'document_export': 'تصدير المستندات',
    'floating_bubble': 'الفقاعة العائمة',
    'advanced_ai_translation': 'الترجمة الذكية المتقدمة',
    'voice_cloning': 'استنساخ الصوت',
    'video_generation': 'توليد الفيديو',
  };
  
  void initialize(PremiumVerificationService premiumService) {
    _premiumService = premiumService;
  }
  
  /// Check if feature is premium
  bool isPremiumFeature(String featureId) {
    return premiumFeatures.containsKey(featureId);
  }
  
  /// Check if user can access feature
  Future<bool> canAccessFeature(String featureId) async {
    if (!isPremiumFeature(featureId)) {
      return true; // Free feature
    }
    
    return await _premiumService.canAccessFeature(featureId);
  }
  
  /// Check if feature can be shared
  Future<bool> canShareFeature(String featureId) async {
    if (!isPremiumFeature(featureId)) {
      return true; // Free features can be shared
    }
    
    return false; // Premium features cannot be shared
  }
  
  /// Show premium required dialog
  static void showPremiumRequiredDialog(
    BuildContext context,
    String featureId,
  ) {
    final featureName = premiumFeatures[featureId] ?? 'هذه الميزة';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text(
          '🔒 ميزة مميزة',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '$featureName متاحة فقط في النسخة البرو.\n\nقم بالترقية للاستمتاع بجميع الميزات!',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to premium page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: const Text('ترقية الآن', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  /// Show sharing blocked dialog
  static void showSharingBlockedDialog(
    BuildContext context,
    String featureId,
  ) {
    final featureName = premiumFeatures[featureId] ?? 'هذه الميزة';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text(
          '🚫 لا يمكن المشاركة',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '$featureName متاحة فقط للمستخدم الحالي ولا يمكن مشاركتها.\n\nهذا لحماية حقوق الملكية الفكرية.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
  
  /// Get feature description
  String getFeatureDescription(String featureId) {
    switch (featureId) {
      case 'chess_game':
        return 'لعبة شطرنج احترافية مع محرك ذكي';
      case 'rubik_cube_enhanced':
        return 'مكعب روبيك محسّن مع رسومات 3D';
      case 'document_lens':
        return 'عدسة ذكية لمسح وترجمة المستندات';
      case 'document_export':
        return 'تصدير المستندات بصيغ متعددة';
      case 'floating_bubble':
        return 'فقاعة عائمة للترجمة الفورية';
      case 'advanced_ai_translation':
        return 'ترجمة ذكية متقدمة مع AI';
      case 'voice_cloning':
        return 'استنساخ الصوت بجودة عالية';
      case 'video_generation':
        return 'توليد فيديو سينمائي';
      default:
        return 'ميزة مميزة';
    }
  }
  
  /// Validate feature access before execution
  Future<bool> validateAndExecuteFeature(
    BuildContext context,
    String featureId,
    VoidCallback onExecute,
  ) async {
    if (!isPremiumFeature(featureId)) {
      onExecute();
      return true;
    }
    
    final canAccess = await canAccessFeature(featureId);
    if (!canAccess) {
      showPremiumRequiredDialog(context, featureId);
      return false;
    }
    
    onExecute();
    return true;
  }
  
  /// Validate before sharing
  Future<bool> validateAndShareFeature(
    BuildContext context,
    String featureId,
    VoidCallback onShare,
  ) async {
    final canShare = await canShareFeature(featureId);
    if (!canShare) {
      showSharingBlockedDialog(context, featureId);
      return false;
    }
    
    onShare();
    return true;
  }
}

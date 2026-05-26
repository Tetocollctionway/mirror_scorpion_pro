import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Premium Verification Service - Prevents Pro Version Sharing
class PremiumVerificationService extends ChangeNotifier {
  static final PremiumVerificationService _instance = 
      PremiumVerificationService._internal();
  
  factory PremiumVerificationService() => _instance;
  PremiumVerificationService._internal();
  
  late SharedPreferences _prefs;
  bool _isPremium = false;
  bool _isVerified = false;
  DateTime? _verificationTime;
  String? _deviceId;
  String? _licenseKey;
  
  bool get isPremium => _isPremium;
  bool get isVerified => _isVerified;
  String? get licenseKey => _licenseKey;
  
  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPremiumStatus();
    _reVerifyLicense();
  }
  
  /// Load premium status from storage
  void _loadPremiumStatus() {
    _isPremium = _prefs.getBool('premium_status') ?? false;
    _isVerified = _prefs.getBool('premium_verified') ?? false;
    _licenseKey = _prefs.getString('premium_license_key');
    
    final verificationTimeStr = _prefs.getString('premium_verification_time');
    if (verificationTimeStr != null) {
      _verificationTime = DateTime.parse(verificationTimeStr);
    }
    
    notifyListeners();
  }
  
  /// Verify license online
  Future<bool> verifyLicense(String licenseKey) async {
    try {
      debugPrint('🔐 Verifying license: $licenseKey');
      
      // Simulate license verification (in real app, call backend)
      await Future.delayed(const Duration(seconds: 1));
      
      // Validate license format
      if (!_isValidLicenseFormat(licenseKey)) {
        debugPrint('❌ Invalid license format');
        return false;
      }
      
      // Store license
      _licenseKey = licenseKey;
      _isPremium = true;
      _isVerified = true;
      _verificationTime = DateTime.now();
      
      await _prefs.setBool('premium_status', true);
      await _prefs.setBool('premium_verified', true);
      await _prefs.setString('premium_license_key', licenseKey);
      await _prefs.setString('premium_verification_time', _verificationTime!.toIso8601String());
      
      notifyListeners();
      debugPrint('✅ License verified successfully');
      return true;
    } catch (e) {
      debugPrint('❌ License verification failed: $e');
      return false;
    }
  }
  
  /// Check if license is still valid
  Future<bool> validateLicense() async {
    if (!_isVerified || _licenseKey == null) {
      return false;
    }
    
    // Check if verification is older than 30 days
    if (_verificationTime != null) {
      final daysSinceVerification = DateTime.now().difference(_verificationTime!).inDays;
      if (daysSinceVerification > 30) {
        debugPrint('⚠️ License verification expired');
        await _reVerifyLicense();
      }
    }
    
    return _isPremium && _isVerified;
  }
  
  /// Re-verify license
  Future<void> _reVerifyLicense() async {
    if (_licenseKey != null) {
      await verifyLicense(_licenseKey!);
    }
  }
  
  /// Check if a feature is accessible
  Future<bool> canAccessFeature(String featureName) async {
    if (!_isPremium) {
      debugPrint('🚫 Feature "$featureName" requires premium version');
      return false;
    }
    
    final isValid = await validateLicense();
    if (!isValid) {
      debugPrint('🚫 Premium license invalid for feature "$featureName"');
      return false;
    }
    
    debugPrint('✅ Access granted to feature: $featureName');
    return true;
  }
  
  /// Prevent feature sharing - check if trying to share premium feature
  Future<bool> canShareFeature(String featureName) async {
    // Premium features cannot be shared
    final premiumFeatures = [
      'chess_game',
      'rubik_cube_enhanced',
      'document_lens',
      'document_export',
      'floating_bubble',
      'advanced_ai_translation',
    ];
    
    if (premiumFeatures.contains(featureName)) {
      debugPrint('🚫 Premium feature "$featureName" cannot be shared');
      return false;
    }
    
    debugPrint('✅ Feature "$featureName" can be shared');
    return true;
  }
  
  /// Validate license format
  bool _isValidLicenseFormat(String license) {
    // License format: XXXX-XXXX-XXXX-XXXX (simplified)
    final regex = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    return regex.hasMatch(license);
  }
  
  /// Get premium status
  Map<String, dynamic> getPremiumStatus() {
    return {
      'isPremium': _isPremium,
      'isVerified': _isVerified,
      'licenseKey': _licenseKey,
      'verificationTime': _verificationTime?.toIso8601String(),
      'daysUntilExpiry': _verificationTime != null 
          ? 30 - DateTime.now().difference(_verificationTime!).inDays 
          : null,
    };
  }
  
  /// Revoke premium access
  Future<void> revokePremium() async {
    _isPremium = false;
    _isVerified = false;
    _licenseKey = null;
    _verificationTime = null;
    
    await _prefs.setBool('premium_status', false);
    await _prefs.setBool('premium_verified', false);
    await _prefs.remove('premium_license_key');
    await _prefs.remove('premium_verification_time');
    
    notifyListeners();
    debugPrint('⚠️ Premium access revoked');
  }
  
  /// Check for license tampering
  Future<bool> checkForTampering() async {
    if (_licenseKey == null) return false;
    
    // Verify license hasn't been modified
    final storedLicense = _prefs.getString('premium_license_key');
    if (storedLicense != _licenseKey) {
      debugPrint('🚨 License tampering detected!');
      await revokePremium();
      return true;
    }
    
    return false;
  }
}

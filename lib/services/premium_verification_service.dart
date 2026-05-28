import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

/// Premium Verification Service - Advanced Security & Device Binding
class PremiumVerificationService extends ChangeNotifier {
  static final PremiumVerificationService _instance = 
      PremiumVerificationService._internal();
  
  factory PremiumVerificationService() => _instance;
  PremiumVerificationService._internal();
  
  late SharedPreferences _prefs;
  bool _isPremium = false;
  String? _licenseKey;
  String? _deviceId;
  
  bool get isPremium => _isPremium;
  String? get licenseKey => _licenseKey;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _deviceId = await _getOrCreateDeviceId();
    _isPremium = _prefs.getBool('isPremium') ?? false;
    _licenseKey = _prefs.getString('premium_license_key');
    notifyListeners();
  }

  /// Get or create a unique encrypted device ID
  Future<String> _getOrCreateDeviceId() async {
    String? id = _prefs.getString('device_id_encrypted');
    if (id == null) {
      // In real app, use device_info_plus, here we simulate a stable unique ID
      String rawId = "MS-${Random().nextInt(999999)}-${DateTime.now().millisecondsSinceEpoch}";
      id = _encryptId(rawId);
      await _prefs.setString('device_id_encrypted', id);
    }
    return id;
  }

  String get encryptedDeviceId => _deviceId ?? "";

  /// Advanced XOR-based encryption for ID with device binding
  String _encryptId(String input) {
    final key = "MIRROR_SCORPION_SECURE_2026";
    List<int> bytes = utf8.encode(input);
    List<int> keyBytes = utf8.encode(key);
    List<int> result = [];
    for (int i = 0; i < bytes.length; i++) {
      // More complex XOR with position-based shifting
      int shift = (i * 7) % 256;
      result.add((bytes[i] ^ keyBytes[i % keyBytes.length] ^ shift) % 256);
    }
    return base64.encode(result);
  }

  /// Verify license with device ID binding and random shuffling
  Future<bool> activatePremium(String activationCode) async {
    try {
      String code = activationCode.trim();
      if (code.isEmpty) return false;

      String expectedCode = generateActivationCode(_deviceId!);
      
      if (code == expectedCode) {
        _isPremium = true;
        _licenseKey = code;
        await _prefs.setBool('isPremium', true);
        await _prefs.setString('premium_license_key', code);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Secure Generator logic for activation codes
  String generateActivationCode(String deviceId) {
    // 1. Combine with a secret salt
    final salt = "MIRROR_SCORPION_V1_SALT_9922";
    String combined = "$deviceId$salt";
    
    // 2. Initial encryption
    List<int> bytes = utf8.encode(combined);
    List<int> encrypted = [];
    for (int i = 0; i < bytes.length; i++) {
      encrypted.add(bytes[i] ^ (i % 255));
    }
    
    // 3. Shuffle logic for "random" appearance
    List<int> shuffled = List.from(encrypted);
    if (shuffled.length > 10) {
      // Swap some positions based on deviceId length
      int swapPos = deviceId.length % (shuffled.length - 1);
      int temp = shuffled[0];
      shuffled[0] = shuffled[swapPos];
      shuffled[swapPos] = temp;
    }
    
    // 4. Final encoding
    return "MS-PRO-${base64.encode(shuffled.reversed.toList()).replaceAll('=', '')}";
  }

  Future<void> revokePremium() async {
    _isPremium = false;
    _licenseKey = null;
    await _prefs.setBool('isPremium', false);
    await _prefs.remove('premium_license_key');
    notifyListeners();
  }
}

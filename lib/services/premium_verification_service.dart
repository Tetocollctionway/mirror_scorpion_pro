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

  /// Simple XOR-based encryption for ID (as requested "mushafar")
  String _encryptId(String input) {
    final key = "MIRROR_SCORPION_2026";
    List<int> bytes = utf8.encode(input);
    List<int> keyBytes = utf8.encode(key);
    List<int> result = [];
    for (int i = 0; i < bytes.length; i++) {
      result.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return base64.encode(result);
  }

  /// Verify license with device ID binding
  Future<bool> activatePremium(String activationCode) async {
    try {
      // Logic: Activation code is valid if it contains the encrypted device ID pattern
      // In this simulation, we check if the code matches our generated logic
      String expectedCode = generateActivationCode(_deviceId!);
      
      if (activationCode.trim() == expectedCode) {
        _isPremium = true;
        _licenseKey = activationCode;
        await _prefs.setBool('isPremium', true);
        await _prefs.setString('premium_license_key', activationCode);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Generator logic (used by the "Key Generator" part of the request)
  String generateActivationCode(String deviceId) {
    // Encrypt the deviceId again with a salt and shuffle
    final salt = "PREMIUM_SALT";
    String combined = "$deviceId$salt";
    List<int> bytes = utf8.encode(combined);
    // Reverse and base64
    return base64.encode(bytes.reversed.toList());
  }

  Future<void> revokePremium() async {
    _isPremium = false;
    _licenseKey = null;
    await _prefs.setBool('isPremium', false);
    await _prefs.remove('premium_license_key');
    notifyListeners();
  }
}

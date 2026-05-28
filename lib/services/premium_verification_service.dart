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
  DateTime? _expiryDate;
  
  bool get isPremium {
    if (!_isPremium) return false;
    if (_expiryDate != null && DateTime.now().isAfter(_expiryDate!)) {
      _revokeExpiredPremium();
      return false;
    }
    return true;
  }

  String? get licenseKey => _licenseKey;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _deviceId = await _getOrCreateDeviceId();
    _isPremium = _prefs.getBool('isPremium') ?? false;
    _licenseKey = _prefs.getString('premium_license_key');
    
    String? expiryStr = _prefs.getString('premium_expiry_date');
    if (expiryStr != null) {
      _expiryDate = DateTime.tryParse(expiryStr);
    }
    
    notifyListeners();
  }

  /// Get or create a unique encrypted device ID
  Future<String> _getOrCreateDeviceId() async {
    String? id = _prefs.getString('device_id_encrypted');
    if (id == null) {
      final secureRandom = Random.secure();
      String rawId = "MS-${secureRandom.nextInt(999999)}-${DateTime.now().millisecondsSinceEpoch}";
      id = _encryptId(rawId);
      await _prefs.setString('device_id_encrypted', id);
    }
    return id;
  }

  String get encryptedDeviceId => _deviceId ?? "";

  static const String _encryptionKey = String.fromEnvironment(
    'MIRROR_ENCRYPTION_KEY',
    defaultValue: 'CHANGE_ME_IN_PRODUCTION',
  );

  /// XOR-based encryption for ID with device binding
  String _encryptId(String input) {
    assert(_encryptionKey != 'CHANGE_ME_IN_PRODUCTION',
        'Set --dart-define=MIRROR_ENCRYPTION_KEY for production builds');
    List<int> bytes = utf8.encode(input);
    List<int> keyBytes = utf8.encode(_encryptionKey);
    List<int> result = [];
    for (int i = 0; i < bytes.length; i++) {
      int shift = (i * 7) % 256;
      result.add((bytes[i] ^ keyBytes[i % keyBytes.length] ^ shift) % 256);
    }
    return base64.encode(result);
  }

  /// Verify license with device ID binding and expiry check
  Future<bool> activatePremium(String activationCode) async {
    try {
      String code = activationCode.trim();
      if (code.isEmpty) return false;

      // Decrypt and verify
      final decoded = _decodeAndVerify(code, _deviceId!);
      if (decoded != null) {
        _isPremium = true;
        _licenseKey = code;
        _expiryDate = decoded;
        
        await _prefs.setBool('isPremium', true);
        await _prefs.setString('premium_license_key', code);
        await _prefs.setString('premium_expiry_date', _expiryDate!.toIso8601String());
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static const String _licenseSalt = String.fromEnvironment(
    'MIRROR_LICENSE_SALT',
    defaultValue: 'CHANGE_ME_SALT_IN_PRODUCTION',
  );

  /// Decode and verify activation code
  DateTime? _decodeAndVerify(String code, String deviceId) {
    try {
      if (!code.startsWith("MS-PRO-")) return null;
      String encodedPart = code.substring(7);
      
      // 1. Reverse and decode
      List<int> bytes = base64.decode(encodedPart).reversed.toList();
      
      // 2. Un-shuffle
      if (bytes.length > 10) {
        int swapPos = deviceId.length % (bytes.length - 1);
        int temp = bytes[0];
        bytes[0] = bytes[swapPos];
        bytes[swapPos] = temp;
      }
      
      // 3. Decrypt
      List<int> decrypted = [];
      for (int i = 0; i < bytes.length; i++) {
        decrypted.add(bytes[i] ^ (i % 255));
      }
      
      String decodedStr = utf8.decode(decrypted);
      
      if (!decodedStr.startsWith(deviceId) || !decodedStr.contains(_licenseSalt)) return null;
      
      // 4. Extract expiry
      String expiryPart = decodedStr.split(_licenseSalt).last;
      int days = int.tryParse(expiryPart) ?? 0;
      if (days == 0) return null; // Invalid duration
      
      return DateTime.now().add(Duration(days: days));
    } catch (e) {
      return null;
    }
  }

  /// Secure Generator logic for activation codes (For Developer App)
  String generateActivationCode(String deviceId, int durationDays) {
    String combined = "$deviceId$_licenseSalt$durationDays";
    
    List<int> bytes = utf8.encode(combined);
    List<int> encrypted = [];
    for (int i = 0; i < bytes.length; i++) {
      encrypted.add(bytes[i] ^ (i % 255));
    }
    
    List<int> shuffled = List.from(encrypted);
    if (shuffled.length > 10) {
      int swapPos = deviceId.length % (shuffled.length - 1);
      int temp = shuffled[0];
      shuffled[0] = shuffled[swapPos];
      shuffled[swapPos] = temp;
    }
    
    return "MS-PRO-${base64.encode(shuffled.reversed.toList()).replaceAll('=', '')}";
  }

  Future<void> _revokeExpiredPremium() async {
    _isPremium = false;
    _licenseKey = null;
    _expiryDate = null;
    await _prefs.setBool('isPremium', false);
    await _prefs.remove('premium_license_key');
    await _prefs.remove('premium_expiry_date');
    notifyListeners();
  }

  Future<void> revokePremium() async {
    await _revokeExpiredPremium();
  }
}

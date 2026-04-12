import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:digital_delta/data/local/db_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:otp/otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _dbHelper = DbHelper();

  // Keys for Shared Preferences
  static const String _keyLoggedIn = "isLoggedIn";
  static const String _keyUserMobile = "userMobile";
  static const String _keyRole = "userRole";

  // --- Session Management ---

  /// Internal helper to set session data
  Future<void> _setSession(String mobile, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyUserMobile, mobile);
    await prefs.setString(_keyRole, role);
  }

  /// Check if a user is currently logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  /// Logout and clear session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    String? mobile = prefs.getString(_keyUserMobile);
    
    await prefs.clear(); // Clears all login flags
    await logEvent("LOGOUT_SUCCESS_${mobile ?? 'unknown'}");
  }

  // M1.1: OTP Generation (TOTP)
  String generateOTP(String secret) {
    return OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      interval: 60, // 60-second window
      length: 6,
    );
  }


  // M1.2 & Registration
  Future<String?> registerUser(
    String user,
    String mobile,
    String pass,
    String role,
  ) async {
    // Generate Key Pair
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final publicKey = (await keyPair.extractPublicKey()).toString();
    final privateKey = await keyPair.extractPrivateKeyBytes();

    // OTP
    final otpSecret = OTP.randomSecret(); // Base32 string

    // Secure Storage
    await _storage.write(key: '${mobile}_otp_secret', value: otpSecret);
    await _storage.write(key: '${mobile}_pass', value: pass);
    await _storage.write(
      key: '${mobile}_priv_key',
      value: privateKey.toString(),
    );

    // Save to SQLite
    try {
      final db = await _dbHelper.db;
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await db.insert('users', {
        'id': id,
        'username': user,
        'mobile': mobile,
        'role': role,
        'public_key': publicKey,
      });

      await logEvent("REGISTER_SUCCESS_$user");
      await _setSession(mobile, role);
      return null;
    } catch (e) {
      // Check if the error is a Unique Constraint violation
      if (e.toString().contains('UNIQUE constraint failed')) {
        if (e.toString().contains('users.mobile')) {
          return "This mobile number is already registered.";
        }
      }
      return "An unexpected error occurred: $e";
    }
  }

  /// Call this when the final OTP/Password check passes
  Future<void> finalizeLogin(String mobile) async {
    final db = await _dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'mobile = ?',
      whereArgs: [mobile],
    );

    if (maps.isNotEmpty) {
      String role = maps.first['role'];
      await _setSession(mobile, role);
      await logEvent("LOGIN_FINALIZED_$mobile");
    }
  }

  Future<bool> verifyPassword(String mobile, String inputPass) async {
    final storedPass = await _storage.read(key: '${mobile}_pass');
    bool success = storedPass != null && storedPass == inputPass;
    await logEvent(
      success ? "PWD_CHECK_PASS_$mobile" : "PWD_CHECK_FAIL_$mobile",
    );
    return success;
  }

  Future<bool> verifyOTP(
    String mobile,
    String expected,
    String inputOtp,
  ) async {
    final secret = await _storage.read(key: '${mobile}_otp_secret');
    if (secret == null) return false;
    bool success = expected == inputOtp;
    await logEvent(success ? "OTP_SUCCESS_$mobile" : "OTP_FAIL_$mobile");
    return success;
  }

  // M1.4: Hash Chaining for Immutable Logs
  Future<void> logEvent(String event) async {
    final db = await _dbHelper.db;

    // Get the last log to find the previous hash
    final List<Map<String, dynamic>> lastLog = await db.query(
      'audit_logs',
      orderBy: 'id DESC',
      limit: 1,
    );

    String prevHash = lastLog.isEmpty ? "0" : lastLog.first['current_hash'];
    int ts = DateTime.now().millisecondsSinceEpoch;

    // Create current hash: SHA256(event + timestamp + prevHash)
    var bytes = utf8.encode("$event$ts$prevHash");
    String currentHash = sha256.convert(bytes).toString();

    await db.insert('audit_logs', {
      'event': event,
      'timestamp': ts,
      'prev_hash': prevHash,
      'current_hash': currentHash,
    });
  }
}

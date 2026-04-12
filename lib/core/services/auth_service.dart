import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:digital_delta/data/local/db_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:otp/otp.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _dbHelper = DbHelper();

  // M1.1: OTP Generation (TOTP)
  String generateOTP(String secret) {
    return OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      interval: 30,
      length: 6,
    );
  }

  // M1.2 & Registration
  Future<void> registerUser(String user, String pass, String role) async {
    // Generate Key Pair
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final publicKey = (await keyPair.extractPublicKey()).toString();
    final privateKey = await keyPair.extractPrivateKeyBytes();
    
    // OTP
    final otpSecret = OTP.randomSecret(); // Base32 string

    // Secure Storage
    await _storage.write(key: '${user}_otp_secret', value: otpSecret);
    await _storage.write(key: '${user}_pass', value: pass);
    await _storage.write(key: '${user}_priv_key', value: privateKey.toString());

    // Save to SQLite
    final db = await _dbHelper.db;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insert('users', {
      'id': id,
      'username': user,
      'role': role,
      'public_key': publicKey,
    });

    await logEvent("REGISTER_SUCCESS_$user");
  }

  Future<bool> verifyPassword(String user, String inputPass) async {
    final storedPass = await _storage.read(key: '${user}_pass');
    bool success = storedPass != null && storedPass == inputPass;
    await logEvent(success ? "PWD_CHECK_PASS_$user" : "PWD_CHECK_FAIL_$user");
    return success;
  }

  Future<bool> verifyOTP(String user, String inputOtp) async {
    final secret = await _storage.read(key: '${user}_otp_secret');
    if (secret == null) return false;

    // Generate local expected OTP (RFC 6238)
    String expected = generateOTP(secret);

    bool success = inputOtp == expected;
    await logEvent(success ? "OTP_SUCCESS_$user" : "OTP_FAIL_$user");
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

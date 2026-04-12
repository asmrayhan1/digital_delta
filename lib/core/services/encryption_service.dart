import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// End-to-End Encryption Service (M3.3)
///
/// Encrypts message payloads using X25519 key exchange + AES-GCM.
/// Relay nodes cannot read message contents — they only forward
/// the encrypted bytes.
class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static final _keyExchange = X25519();
  static final _cipher = AesGcm.with256bits();

  /// Generate a new X25519 key pair and store privately
  static Future<SimplePublicKey> generateAndStoreKeyPair(String userId) async {
    final keyPair = await _keyExchange.newKeyPair();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();

    // Store private key securely
    await _storage.write(
      key: '${userId}_x25519_priv',
      value: base64Encode(privateKeyBytes),
    );
    // Store public key
    await _storage.write(
      key: '${userId}_x25519_pub',
      value: base64Encode(publicKey.bytes),
    );

    return publicKey;
  }

  /// Get our public key bytes for sharing with peers
  static Future<Uint8List?> getPublicKeyBytes(String userId) async {
    final encoded = await _storage.read(key: '${userId}_x25519_pub');
    if (encoded == null) return null;
    return Uint8List.fromList(base64Decode(encoded));
  }

  /// Encrypt a plaintext message for a specific recipient
  /// Uses X25519 shared secret + AES-GCM
  static Future<Uint8List> encryptForRecipient(
    String plaintext,
    Uint8List recipientPublicKeyBytes,
    String senderUserId,
  ) async {
    // Load our private key
    final privKeyEncoded = await _storage.read(key: '${senderUserId}_x25519_priv');
    if (privKeyEncoded == null) throw Exception('No private key found');

    final privKeyBytes = base64Decode(privKeyEncoded);
    final ourKeyPair = await _keyExchange.newKeyPairFromSeed(privKeyBytes);

    // Derive shared secret via X25519
    final recipientPubKey = SimplePublicKey(
      recipientPublicKeyBytes,
      type: KeyPairType.x25519,
    );

    final sharedSecret = await _keyExchange.sharedSecretKey(
      keyPair: ourKeyPair,
      remotePublicKey: recipientPubKey,
    );

    // Use the shared secret as AES-GCM key
    final secretKeyBytes = await sharedSecret.extractBytes();
    final secretKey = SecretKey(secretKeyBytes);

    // Encrypt
    final plaintextBytes = utf8.encode(plaintext);
    final secretBox = await _cipher.encrypt(
      plaintextBytes,
      secretKey: secretKey,
    );

    // Pack: nonce (12) + ciphertext + mac (16)
    final result = Uint8List.fromList([
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);

    return result;
  }

  /// Decrypt a message encrypted for us
  static Future<String> decryptWithPrivateKey(
    Uint8List encryptedData,
    Uint8List senderPublicKeyBytes,
    String ourUserId,
  ) async {
    // Load our private key
    final privKeyEncoded = await _storage.read(key: '${ourUserId}_x25519_priv');
    if (privKeyEncoded == null) throw Exception('No private key found');

    final privKeyBytes = base64Decode(privKeyEncoded);
    final ourKeyPair = await _keyExchange.newKeyPairFromSeed(privKeyBytes);

    // Derive shared secret
    final senderPubKey = SimplePublicKey(
      senderPublicKeyBytes,
      type: KeyPairType.x25519,
    );

    final sharedSecret = await _keyExchange.sharedSecretKey(
      keyPair: ourKeyPair,
      remotePublicKey: senderPubKey,
    );

    final secretKeyBytes = await sharedSecret.extractBytes();
    final secretKey = SecretKey(secretKeyBytes);

    // Unpack: nonce (12) + ciphertext + mac (16)
    final nonce = encryptedData.sublist(0, 12);
    final mac = Mac(encryptedData.sublist(encryptedData.length - 16));
    final cipherText = encryptedData.sublist(12, encryptedData.length - 16);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: mac,
    );

    final decryptedBytes = await _cipher.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(decryptedBytes);
  }
}

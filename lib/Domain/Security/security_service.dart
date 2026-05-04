import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecurityService {
  static const String _privateKeyName = "chat_private_key_x25519";
  final _storage = const FlutterSecureStorage();
  final _algorithm = X25519();
  final _cipher = Chacha20.poly1305Aead();

  /// Generates a new X25519 key pair and stores the private key securely.
  /// Returns the base64 encoded public key.
  Future<String> getOrGenerateKeys() async {
    final existingPrivateKey = await _storage.read(key: _privateKeyName);

    if (existingPrivateKey != null) {
      final privateKeyBytes = base64.decode(existingPrivateKey);
      final keyPair = await _algorithm.newKeyPairFromSeed(privateKeyBytes);
      final publicKey = await keyPair.extractPublicKey();
      return base64.encode(publicKey.bytes);
    }

    // Generate new if not exists
    final keyPair = await _algorithm.newKeyPair();
    final privateKey = await keyPair.extract();
    final publicKey = await keyPair.extractPublicKey();

    await _storage.write(
      key: _privateKeyName,
      value: base64.encode(privateKey.bytes),
    );
    return base64.encode(publicKey.bytes);
  }

  /// Derives a shared secret between this user and another user.
  Future<SecretKey> _deriveSharedSecret(String otherPublicKeyBase64) async {
    final privateKeyBase64 = await _storage.read(key: _privateKeyName);
    if (privateKeyBase64 == null) throw Exception("Secret key not initialized");

    final ownKeyPair = await _algorithm.newKeyPairFromSeed(
      base64.decode(privateKeyBase64),
    );
    final otherPublicKey = SimplePublicKey(
      base64.decode(otherPublicKeyBase64),
      type: KeyPairType.x25519,
    );

    return await _algorithm.sharedSecretKey(
      keyPair: ownKeyPair,
      remotePublicKey: otherPublicKey,
    );
  }

  /// Encrypts a string using the recipient's public key.
  /// Returns a Map containing 'ciphertext' and 'nonce' as Base64.
  Future<Map<String, String>> encryptText({
    required String plainText,
    required String recipientPublicKey,
  }) async {
    final sharedSecret = await _deriveSharedSecret(recipientPublicKey);
    final nonce = _cipher.newNonce();

    final secretBox = await _cipher.encrypt(
      utf8.encode(plainText),
      secretKey: sharedSecret,
      nonce: nonce,
    );

    // CONCATENATE CipherText + MAC for integrity
    final combined = Uint8List.fromList([
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);

    return {
      'ciphertext': base64.encode(combined),
      'nonce': base64.encode(secretBox.nonce),
    };
  }

  /// Decrypts a ciphertext using the sender's public key.
  Future<String> decryptText({
    required String ciphertextBase64,
    required String nonceBase64,
    required String senderPublicKey,
  }) async {
    final sharedSecret = await _deriveSharedSecret(senderPublicKey);

    final combined = base64.decode(ciphertextBase64);
    if (combined.length < 16) {
      throw Exception("Invalid ciphertext: too short for MAC");
    }

    final macBytes = combined.sublist(combined.length - 16);
    final cipherTextOnly = combined.sublist(0, combined.length - 16);

    final secretBox = SecretBox(
      cipherTextOnly,
      nonce: base64.decode(nonceBase64),
      mac: Mac(macBytes),
    );

    final decryptedBytes = await _cipher.decrypt(
      secretBox,
      secretKey: sharedSecret,
    );

    return utf8.decode(decryptedBytes);
  }

  /// Encrypts raw bytes (for images).
  Future<Map<String, dynamic>> encryptBytes({
    required Uint8List bytes,
    required String recipientPublicKey,
  }) async {
    final sharedSecret = await _deriveSharedSecret(recipientPublicKey);
    final nonce = _cipher.newNonce();

    final secretBox = await _cipher.encrypt(
      bytes,
      secretKey: sharedSecret,
      nonce: nonce,
    );

    // CONCATENATE CipherText + MAC
    final combined = Uint8List.fromList([
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);

    return {'ciphertext': combined, 'nonce': base64.encode(secretBox.nonce)};
  }

  /// Decrypts raw bytes.
  Future<Uint8List> decryptBytes({
    required Uint8List encryptedBytes,
    required String nonceBase64,
    required String senderPublicKey,
  }) async {
    final sharedSecret = await _deriveSharedSecret(senderPublicKey);

    if (encryptedBytes.length < 16) {
      throw Exception("Invalid encrypted bytes: too short for MAC");
    }

    final macBytes = encryptedBytes.sublist(encryptedBytes.length - 16);
    final cipherTextOnly = encryptedBytes.sublist(
      0,
      encryptedBytes.length - 16,
    );

    final secretBox = SecretBox(
      cipherTextOnly,
      nonce: base64.decode(nonceBase64),
      mac: Mac(macBytes),
    );

    final decryptedBytes = await _cipher.decrypt(
      secretBox,
      secretKey: sharedSecret,
    );

    return Uint8List.fromList(decryptedBytes);
  }
}

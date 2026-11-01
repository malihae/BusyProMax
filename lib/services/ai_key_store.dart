import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the user's Hugging Face token out of preferences and source code.
///
/// The value is read only when a chat request is made. It is never displayed
/// again after saving and never written to logs.
class AiKeyStore {
  const AiKeyStore._();

  static const _storageKey = 'busypro.huggingFaceToken';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> read() async {
    try {
      final value = await _storage.read(key: _storageKey);
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return null;
      return trimmed;
    } catch (_) {
      // Secure storage can be unavailable in tests or on unsupported hosts.
      return null;
    }
  }

  static Future<void> write(String token) {
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Token cannot be empty.');
    }
    return _storage.write(key: _storageKey, value: trimmed);
  }

  static Future<void> clear() => _storage.delete(key: _storageKey);
}

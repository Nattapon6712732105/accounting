import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _key = 'auth_token';

  static String _displayKey(String userId) => 'display_name_$userId';

  static Future<void> save(String? token) async {
    if (token == null || token.isEmpty) {
      await _storage.delete(key: _key);
    } else {
      await _storage.write(key: _key, value: token);
    }
  }

  static Future<String?> read() => _storage.read(key: _key);

  static Future<void> clear() => _storage.delete(key: _key);

  static Future<void> saveDisplayName(String? name, String userId) async {
    final key = _displayKey(userId);
    if (name == null || name.isEmpty) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: name);
    }
  }

  static Future<String?> readDisplayName(String userId) =>
      _storage.read(key: _displayKey(userId));
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the parent's server session lives on the tablet (FEAT-13, ACC-05).
/// It holds the auth token and the account record, never the password.
abstract class TokenStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

/// [TokenStore] in Android's encrypted storage (Keystore-backed).
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const key = 'server_session';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: key);

  @override
  Future<void> write(String value) => _storage.write(key: key, value: value);

  @override
  Future<void> clear() => _storage.delete(key: key);
}

/// In-memory [TokenStore] for tests.
class MemoryTokenStore implements TokenStore {
  MemoryTokenStore([this.value]);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;

  @override
  Future<void> clear() async => value = null;
}

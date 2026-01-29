import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

abstract class StorageService {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<void> clearTokens();
}

@LazySingleton(as: StorageService)
class StorageServiceImpl implements StorageService {
  final FlutterSecureStorage _storage;

  StorageServiceImpl() : _storage = const FlutterSecureStorage();

  static const _keyAccessToken = 'ACCESS_TOKEN';
  static const _keyRefreshToken = 'REFRESH_TOKEN';

  @override
  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  @override
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  @override
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }
}
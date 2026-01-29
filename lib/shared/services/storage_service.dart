import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:travel_app/domain/services/i_storage_service.dart';

class StorageService implements IStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys để lưu dữ liệu
  static const _keyAccessToken = 'access_token';
  static const _keyEmail = 'user_email';
  static const _keyPassword = 'user_password';

  @override
  Future<void> saveCredentials({
    required String email,
    required String password,
    String? token,
  }) async {
    if (kIsWeb) return; // Bỏ qua nếu là Web
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
    if (token != null) {
      await _storage.write(key: _keyAccessToken, value: token);
    }
  }

  @override
  Future<Map<String, String?>> getCredentials() async {
    if (kIsWeb) {
      return {'email': null, 'password': null, 'token': null};
    }
    String? email = await _storage.read(key: _keyEmail);
    String? password = await _storage.read(key: _keyPassword);
    String? token = await _storage.read(key: _keyAccessToken);

    return {'email': email, 'password': password, 'token': token};
  }

  @override
  Future<void> clearCredentials() async {
    if (kIsWeb) return;
    await _storage.deleteAll();
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Dành cho web

class StorageService {
  // Tạo instance để dùng chung
  static final _storage = FlutterSecureStorage();

  // Key để lưu dữ liệu
  static const _keyAccessToken = 'access_token';
  static const _keyEmail = 'user_email';
  static const _keyPassword = 'user_password';

  // Lưu token
  static Future<void> saveCredentials({
    required String email,
    required String password,
    String? token,
  }) async {
    if (kIsWeb) return; // Bỏ qua nếu là Web
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(
      key: _keyPassword,
      value: password,
    ); // Hoàn thành mã hoá
    if (token != null) {
      await _storage.write(key: _keyAccessToken, value: token);
    }
  }

  // Lấy thông tin đã lưu
  static Future<Map<String, String?>> getCredentials() async {
    if (kIsWeb)
      return {'email': null, 'password': null, 'token': null}; // Dành cho web
    String? email = await _storage.read(key: _keyEmail);
    String? password = await _storage.read(key: _keyPassword);
    String? token = await _storage.read(key: _keyAccessToken);

    return {'email': email, 'password': password, 'token': token};
  }

  // Xoá thông tin khi logout hoặc không check remember me
  static Future<void> clearCredentials() async {
    if (kIsWeb) return; // Dành cho web
    await _storage.deleteAll();
  }
}

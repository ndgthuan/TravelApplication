// Interface cho Secure Storage service
// Dùng để lưu/đọc credentials an toàn
abstract class IStorageService {
  // Lưu thông tin đăng nhập
  Future<void> saveCredentials({
    required String email,
    required String password,
    String? token,
  });

  // Lấy thông tin đăng nhập đã lưu
  Future<Map<String, String?>> getCredentials();

  // Xóa tất cả thông tin đã lưu (dùng khi logout)
  Future<void> clearCredentials();
}

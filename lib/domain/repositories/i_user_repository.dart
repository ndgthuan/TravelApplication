// Mục đích của file này là lấy thông tin người dùng
// Bên cạnh đó file này có giúp edit info trong profile screen
// Đây còn được gọi là menu của gọi thông tin hay thay thế user
import '../models/user_model.dart';

abstract class IUserRepository {
  // Lấy thông tin của user hiện tại
  Future<UserModel?> getCurrentUser();

  // Cập nhất thông tin user
  Future<void> updateUser(Map<String, dynamic> data);

  // Lấy tất cả users (cho member search)
  Future<List<UserModel>> getAllUsers();
}

// Mục đích của file là trả về thống nhất cho các thể method authentication
import 'user_model.dart';

class AuthResult {
  final UserModel? user; // Trả về user nếu thành công
  final String? error; // Trả về Error Message nếu thất bại
  AuthResult({this.user, this.error});

  // Hàm dựng kết quả thành công
  // ignore: prefer_initializing_formals
  AuthResult.success(UserModel user) : user = user, error = null;

  // Hàm dựng lỗi khi không trả về được user
  // ignore: prefer_initializing_formals
  AuthResult.failure(String error) : user = null, error = error;

  // Kiểm tra thành công hay thất bại
  bool get isSuccess => user != null && error == null;
  bool get isFailure => error != null;
}

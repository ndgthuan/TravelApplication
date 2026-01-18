// Mục dích của file là định nghĩa hợp đồng cho các phương thức Auth
// ViewModel sẽ phụ thuộc vào Interface này, không phụ thuộc vào Firebase trực tiếp
// UI sẽ tách rời và chỉ cần gọi không cần biết bên trong thực hiện như nào
import '../models/auth_result.dart';

// Abstract class định nghĩa các method mà bất kỳ Auth Repository nào cũng phải có
abstract class IAuthRepository {
  // Đăng nhập bằng email và password
  Future<AuthResult> signIn({required String email, required String password});

  // Đăng ký tài khoản mới
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
  });

  // Đăng nhập bằng google
  Future<AuthResult> signInWithGoogle();

  // Đăng nhập bằng Facebook
  Future<AuthResult> signInWithFacebook();

  // Gửi email reset password
  Future<void> sendPasswordResetEmail({required String email});

  // Dăng xuất
  Future<void> signOut();

  // Đổi mật khẩu
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

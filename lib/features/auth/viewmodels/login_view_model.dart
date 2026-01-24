// Mục đích của file này là file trung gian để gọi giữa UI và logic
// UI KHÔNG CẦN BIẾT FIREBASE LÀM GÌ ĐẰNG SAU, CHỈ CÓ GỌI METHOD THÔI
import 'package:flutter/material.dart';
import '../../../domain/repositories/i_auth_repository.dart';

// Tạo một enum để quản lý các trạng thái của màn hình
enum LoginState { initial, loading, success, error }

class LoginViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  // Sử dụng Dependency Injection để nhận repository qua hàm khởi tạo
  final IAuthRepository _authRepository;
  LoginViewModel(this._authRepository);

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  // Các biến lưu trạng thái
  LoginState _state = LoginState.initial;
  String? _emailError;
  String? _passwordError;
  bool _rememberMe = false;
  bool _isGooglePressed = false;
  bool _isFacebookPressed = false;

  // Getter để UI đọc state
  LoginState get state => _state;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _state == LoginState.loading;
  bool get isGooglePressed => _isGooglePressed;
  bool get isFacebookPressed => _isFacebookPressed;

  //==========================================================================//
  //                        ACTION                                            //
  //==========================================================================//
  // Cho phép bật/tắt remember Me checkbox
  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  // Set giá trị của Remember Me (dùng khi load từ storage)
  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  // Reset lại lỗi
  void clearError() {
    _emailError = null;
    _passwordError = null;
    notifyListeners();
  }

  // Đăng nhập bằng email/password
  Future<bool> signIn({required String email, required String password}) async {
    // Bắt đầu loading
    _state = LoginState.loading;
    _emailError = null;
    _passwordError = null;
    notifyListeners();

    // Gọi repository
    final result = await _authRepository.signIn(
      email: email,
      password: password,
    );

    // Xử lý biến kết quả
    if (result.isSuccess) {
      _state = LoginState.success;
      notifyListeners();
      return true; // Trả về true nếu đăng nhập thành công
    } else {
      _state = LoginState.error;
      _handleError(result.error ?? '');
      notifyListeners();
      return false; // Trả về false và lưu biến lỗi
    }
  }

  // Đăng nhập bằng Google
  Future<bool> signInWithGoogle() async {
    _isGooglePressed = true;
    _state = LoginState.loading;
    notifyListeners();
    final result = await _authRepository.signInWithGoogle();
    _isGooglePressed = false;
    if (result.isSuccess) {
      _state = LoginState.success;
      notifyListeners();
      return true; // Thành công thì return true
    } else {
      _state = LoginState.error;
      _emailError = result.error;
      notifyListeners();
      return false; // Thất bại thì return false
    }
  }

  // Đăng nhập bằng Facebook
  Future<bool> signInWithFacebook() async {
    _isFacebookPressed = true;
    _state = LoginState.loading;
    notifyListeners();
    final result = await _authRepository.signInWithFacebook();
    _isFacebookPressed = false;
    if (result.isSuccess) {
      _state = LoginState.success;
      notifyListeners();
      return true; // Thành công thì return true
    } else {
      _state = LoginState.error;
      _emailError = result.error;
      notifyListeners();
      return false; // Thất bại thì return false
    }
  }

  // Gửi email reset password
  Future<void> sendPasswordResetEmail(String email) async {
    await _authRepository.sendPasswordResetEmail(email: email);
  }

  //==========================================================================//
  //                        PRIVATE HELPERS                                   //
  //==========================================================================//
  // Phân loại error để hiện thị đúng field
  void _handleError(String error) {
    if (error.contains(' or ')) {
      // Lỗi cả email và password
      _emailError = error;
      _passwordError = error;
    } else if (error.toLowerCase().contains('email') ||
        error.contains('Account')) {
      _emailError = error;
    } else {
      _passwordError = error;
    }
  }
}

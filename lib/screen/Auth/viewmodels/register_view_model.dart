// Mục đích của file này là file trung gian để gọi giữa UI và logic
// UI KHÔNG CẦN BIẾT FIREBASE LÀM GÌ ĐẰNG SAU, CHỈ CÓ GỌI METHOD THÔI
import 'package:flutter/material.dart';
import '../../../domain/repositories/i_auth_repository.dart';

// Tạo enum quản lý state (tương tự như LoginViewModel)
enum RegisterState { initial, loading, success, error }

// Tạo class kế thừa ChangeNotifier
class RegisterViewModel extends ChangeNotifier {
  // Sử dụng Dependency Injection để nhận repository qua hàm khởi tạo
  final IAuthRepository _authRepository;
  RegisterViewModel(this._authRepository);

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  // Các biến lưu trạng thái
  RegisterState _state = RegisterState.initial;
  String? _emailError;
  String? _passwordError;
  int _passwordStrength = 0;

  // Getter để UI đọc state
  RegisterState get state => _state;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  bool get isLoading => _state == RegisterState.loading;
  int get passwordStrength => _passwordStrength;

  //==========================================================================//
  //                        ACTION                                            //
  //==========================================================================//
  // Cập nhật độ mạnh password
  void updatePasswordStrength(int strength) {
    _passwordStrength = strength;
    notifyListeners();
  }

  // Reset lại lỗi sau mỡi lần gọi
  void clearError() {
    _emailError = null;
    _passwordError = null;
    notifyListeners();
  }

  // Method đăng ký
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // Bắt đầu loading
    _state = RegisterState.loading;
    _emailError = null;
    _passwordError = null;
    notifyListeners();

    // Gọi repository
    final result = await _authRepository.signUp(
      email: email,
      password: password,
      name: name,
    );

    // Xử lý kết quả đầu ra
    if (result.isSuccess) {
      _state = RegisterState.success;
      notifyListeners();
      return true; // Trả về true nếu thành công
    } else {
      // Xử lý lỗi
      _state = RegisterState.error;
      _handleError(result.error ?? '');
      notifyListeners();
      return false; // Trả về false nếu có xuất hiện lỗi
    }
  }

  //==========================================================================//
  //                        PRIVATE HELPERS                                   //
  //==========================================================================//
  void _handleError(String error) {
    if (error.contains('email') || error.contains('Email')) {
      _emailError = error;
    } else {
      _passwordError = error;
    }
  }
}

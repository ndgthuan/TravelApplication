// Mục đích của file này quản lý state và login cho ChangePasswordScreen
// UI chỉ gọi method và lắng nghe state, không xử lý logic
import 'package:flutter/material.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../shared/utils/password_utils.dart';

// Enum quản lý trạng thái màn hình
enum ChangePasswordState { initial, loading, success, error }

class ChangePasswordViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCY INJECTION                              //
  //==========================================================================//
  final IAuthRepository _authRepository;
  ChangePasswordViewModel(this._authRepository);

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  // Các biến để gọi UI
  ChangePasswordState _state = ChangePasswordState.initial;
  String? _errorMessage;
  int _passwordStrength = 0;
  // Hàm gọi từ UI
  ChangePasswordState get state => _state;
  String? get errorMessage => _errorMessage;
  int get passwordStrength => _passwordStrength;
  bool get isLoading => _state == ChangePasswordState.loading;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Cập nhật độ mạnh password khi user nhập
  void updatePasswordStrength(String password) {
    _passwordStrength = checkPasswordStrength(password);
    notifyListeners();
  }

  // Reset lỗi mỗi lần VoidCallback lại
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Đổi mật khẩu
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String reenterPassword,
  }) async {
    // Xác minh nếu mật khẩu mới khác reenter password
    if (newPassword != reenterPassword) {
      _errorMessage = 'auth.password_not_match';
      notifyListeners();
      return false;
    }

    if (newPassword.length < 8) {
      _errorMessage = 'auth.min_chars';
      notifyListeners();
      return false;
    }
    // Gọi repository để truyền các method
    _state = ChangePasswordState.loading;
    _errorMessage = null;
    notifyListeners();
    final result = await _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (result == null) {
      _state = ChangePasswordState.success;
      notifyListeners();
      return true; // Trả về true nếu thành công
    } else {
      _state = ChangePasswordState.error;
      _errorMessage = result;
      notifyListeners();
      return false; // Trả về lỗi và false nếu không thành công
    }
  }
}

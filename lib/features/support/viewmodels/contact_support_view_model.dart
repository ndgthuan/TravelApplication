// Mục đích của file này quản lý state và logic cho ContactSupportScreen
// UI chỉ gọi method và lắng nghe state, không xử lý logic
import 'package:flutter/material.dart';
import 'package:travel_app/domain/services/i_support_email_service.dart';
import 'package:travel_app/domain/repositories/i_user_repository.dart';

// Gọi các method trạng thái cho UI
enum ContactSupportState { initial, sending, success, error }

class ContactSupportViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final ISupportEmailService _supportEmailService;
  final IUserRepository _userRepository;

  ContactSupportViewModel(this._supportEmailService, this._userRepository);

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  ContactSupportState _state = ContactSupportState.initial;
  String? _errorMessage;
  // Getters
  ContactSupportState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isSending => _state == ContactSupportState.sending;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Reset lỗi mỗi lần có nhập lại
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset toàn bộ state về initial khi thoát ra vào lại
  void reset() {
    _state = ContactSupportState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  // Gửi email hỗ trợ qua EmailJS
  Future<bool> sendSupportEmail({
    required String subject,
    required String message,
  }) async {
    if (subject.trim().isEmpty || message.trim().isEmpty) {
      _errorMessage = 'account.fill_all_fields';
      notifyListeners();
      return false;
    }
    _state = ContactSupportState.sending;
    _errorMessage = null;
    notifyListeners();

    String userName = 'App User';
    String userEmail = 'no-reply@app.com';
    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        if (user.name.isNotEmpty) userName = user.name;
        if (user.email.isNotEmpty) userEmail = user.email;
      }
    } catch (_) {}

    final success = await _supportEmailService.sendSupportEmail(
      subject: subject,
      message: message,
      userName: userName,
      userEmail: userEmail,
    );

    if (success) {
      _state = ContactSupportState.success;
      notifyListeners();
      return true;
    } else {
      _state = ContactSupportState.error;
      _errorMessage = 'account.send_error';
      notifyListeners();
      return false;
    }
  }
}

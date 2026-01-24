// Mục đích của file này quản lý state và logic cho ContactSupportScreen
// UI chỉ gọi method và lắng nghe state, không xử lý logic
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Gọi các method trạng thái cho UI
enum ContactSupportState { initial, sending, success, error }

class ContactSupportViewModel extends ChangeNotifier {
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
    required String subject, // Gọi title
    required String message, // Gọi thông tin tin nhắn
  }) async {
    // Validate
    if (subject.trim().isEmpty || message.trim().isEmpty) {
      _errorMessage = 'account.fill_all_fields'; // Key để translate
      notifyListeners();
      return false;
    }
    _state = ContactSupportState.sending;
    _errorMessage = null;
    notifyListeners();
    // Lấy thông tin user hiện tại
    final user = FirebaseAuth.instance.currentUser;
    final userName =
        user?.displayName ??
        'App User'; // Nếu userName không có display AppUser
    final userEmail =
        user?.email ??
        'no-reply@app.com'; // Nếu email không có display no-reply@app.com
    final url = Uri.parse(
      'https://api.emailjs.com/api/v1.0/email/send',
    ); // Đường dẫn email
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['PRIVATE_KEY']}',
        },
        body: json.encode({
          'service_id': dotenv.env['SERVICE_ID'],
          'template_id': dotenv.env['TEMPLATE_ID'],
          'user_id': dotenv.env['PUBLIC_KEY'],
          'accessToken': dotenv.env['PRIVATE_KEY'],
          'template_params': {
            'title': subject,
            'message': message,
            'name': userName,
            'email': userEmail,
          },
        }),
      );
      if (response.statusCode == 200) {
        _state = ContactSupportState.success;
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed: ${response.body}');
      }
    } catch (e) {
      _state = ContactSupportState.error;
      _errorMessage = 'account.send_error';
      notifyListeners();
      return false;
    }
  }
}

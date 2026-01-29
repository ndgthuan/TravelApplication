// Mục đích của file này quản lý state và login cho ProfileScreen
// UI chỉ gọi method và lắng nghe state, không xử lý logic
import 'package:flutter/material.dart';
import '../../../domain/repositories/i_user_repository.dart';
import 'package:travel_app/domain/services/i_cloudinary_service.dart';
import 'dart:io';

// Enum quản lý trạng thái màn hình
enum InformationState { initial, loading, loaded, saving, error }

class InformationViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCY INJECTION                              //
  //==========================================================================//
  final IUserRepository _userRepository;
  final ICloudinaryService _cloudinaryService;

  InformationViewModel(this._userRepository, this._cloudinaryService);

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  // Gọi các method bên đây để có gì gọi bên UI
  InformationState _state = InformationState.initial;
  String? _avatarUrl;
  bool _isUploading = false;

  // Thông tin người dùng
  String _name = '';
  String _email = '';
  String _phone = '';
  String _dob = '';
  String _address = '';
  // Getters để UI đọc state
  InformationState get state => _state;
  String? get avatarUrl => _avatarUrl;
  bool get isUploading => _isUploading;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get dob => _dob;
  String get address => _address;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Load thông tin user từ Repository
  Future<void> loadUserData() async {
    _state = InformationState.loading;
    notifyListeners();
    final user = await _userRepository.getCurrentUser();

    if (user != null) {
      _name = user.name;
      _email = user.email;
      _phone = user.phone ?? '';
      _dob = user.dob ?? '';
      _address = user.address ?? '';
      _avatarUrl = user.avatarUrl;
      _state = InformationState.loaded;
    } else {
      _state = InformationState.error;
    }
    notifyListeners();
  }

  // Upload và cập nhật avatar
  Future<void> uploadAvatar(File imageFile) async {
    _isUploading = true;
    notifyListeners();
    final url = await _cloudinaryService.uploadImage(imageFile);

    if (url != null) {
      await _userRepository.updateUser({'avatarUrl': url});
      _avatarUrl = url;
    }

    _isUploading = false;
    notifyListeners();
  }

  // Lưu thông tin user
  Future<bool> saveUserData({
    required String name,
    required String phone,
    required String dob,
    required String address,
  }) async {
    _state = InformationState.saving;
    notifyListeners();
    try {
      await _userRepository.updateUser({
        'name': name,
        'phone': phone,
        'dob': dob,
        'address': address,
      });
      _state = InformationState.loaded;
      notifyListeners();
      return true; // Update được thì trả về true
    } catch (e) {
      _state = InformationState.error;
      notifyListeners();
      return false; // Không update được thì trả về false
    }
  }
}

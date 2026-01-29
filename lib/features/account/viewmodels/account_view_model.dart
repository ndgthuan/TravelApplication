// Mục đích của file này quản lý state và login cho AccountScreen
// UI chỉ gọi method và lắng nghe state, không xử lý logic
import 'package:flutter/material.dart';
import '../../../domain/repositories/i_user_repository.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import 'package:travel_app/domain/services/i_storage_service.dart';
import 'dart:io';
import 'package:travel_app/domain/services/i_cloudinary_service.dart';

// Enum quản lý trạng thái màn hình
enum AccountState { initial, loading, loaded, error }

class AccountViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCY INJECTION                              //
  //==========================================================================//
  final IUserRepository _userRepository;
  final IAuthRepository _authRepository;
  final IStorageService _storageService;
  final ICloudinaryService _cloudinaryService;

  AccountViewModel(
    this._userRepository,
    this._authRepository,
    this._storageService,
    this._cloudinaryService,
  );

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  // Các biến khai báo để gọi bên UI
  AccountState _state = AccountState.initial;
  String? _userName;
  String? _userEmail;
  String? _avatarUrl;
  String? _backgroundUrl;
  bool _isUploadingBackground = false;

  // Getters để UI đọc state
  AccountState get state => _state;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get avatarUrl => _avatarUrl;
  String? get backgroundUrl => _backgroundUrl;
  bool get isUploadingBackground => _isUploadingBackground;
  bool get isLoading => _state == AccountState.loading;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Load thông tin user từ Repository
  Future<void> loadUserData() async {
    _state = AccountState.loading;
    notifyListeners();
    final user = await _userRepository.getCurrentUser();

    if (user != null) {
      _userName = user.name;
      _userEmail = user.email;
      _avatarUrl = user.avatarUrl;
      _backgroundUrl = user.backgroundUrl;
      _state = AccountState.loaded;
    } else {
      _state = AccountState.error;
    }
    notifyListeners();
  }

  // Upload và cập nhật background image
  Future<void> uploadBackgroundImage(File imageFile) async {
    _isUploadingBackground = true;
    notifyListeners();

    final url = await _cloudinaryService.uploadImage(imageFile);
    if (url != null) {
      await _userRepository.updateUser({'backgroundUrl': url});
      _backgroundUrl = url;
    }

    _isUploadingBackground = false;
    notifyListeners();
  }

  // Cập nhật background image URL
  Future<void> updateBackgroundUrl(String url) async {
    await _userRepository.updateUser({'backgroundUrl': url});
    _backgroundUrl = url;
    notifyListeners();
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _storageService.clearCredentials();
    await _authRepository.signOut();
  }
}

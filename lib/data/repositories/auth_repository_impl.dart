// Mục dích của file này là thực hiện các yêu cầu mà người dùng đưa ra
// Bên i_auth_repository sẽ được gọi function và file này sẽ là file được thực hiện
// Nếu sau này có đổi sang Supabase hay .. thì chỉ cần implment lại file này
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:easy_localization/easy_localization.dart';
import 'dart:developer';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/models/auth_result.dart';
import '../../domain/models/user_model.dart';

// Cook lại từng hàm của IAuthRepository
class AuthRepositoryImpl implements IAuthRepository {
  // Inject Firebase instance
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  AuthRepositoryImpl({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  //==========================================================================//
  //                            ĐĂNG NHẬP                                     //
  //==========================================================================//
  @override
  Future<AuthResult> signIn({
    required String email, // Đăng nhập bằng email
    required String password, // Đăng nhập bằng mật khẩu
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      log('Login Completed');

      // Lấy user data từ Firestore
      final user = await _getUserFromFirestore(userCredential.user!.uid);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.code));
    }
  }

  //==========================================================================//
  //                            ĐĂNG KÝ                                       //
  //==========================================================================//
  @override
  Future<AuthResult> signUp({
    required String email, // Lưu gồm email
    required String password, // Lưu gồm password
    required String name, // Lưu gồm tên
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Lưu user vào Firestore
      await _saveUserToFirestore(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
      );
      log('Register Completed');
      final user = await _getUserFromFirestore(userCredential.user!.uid);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.code));
    }
  }

  //==========================================================================//
  //                            ĐĂNG NHẬP BẰNG GOOGLE                         //
  //==========================================================================//
  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return AuthResult.failure("auth.google_cancelled".tr());
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        return AuthResult.failure("auth.google_failed".tr());
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // Kiểm tra và tạo user trong Firestore nếu chưa có
      await _ensureUserInFirestore(userCredential);

      final user = await _getUserFromFirestore(userCredential.user!.uid);
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure("auth.google_failed".tr());
    }
  }

  //==========================================================================//
  //                            ĐĂNG NHẬP BẰNG FACEBOOK                       //
  //==========================================================================//
  @override
  Future<AuthResult> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.accessToken == null) {
        return AuthResult.failure("auth.facebook_cancelled".tr());
      }
      final OAuthCredential facebookCredential =
          FacebookAuthProvider.credential(
            '${loginResult.accessToken?.tokenString}',
          );
      final userCredential = await _firebaseAuth.signInWithCredential(
        facebookCredential,
      );

      await _ensureUserInFirestore(userCredential);

      final user = await _getUserFromFirestore(userCredential.user!.uid);
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure("auth.facebook_failed".tr());
    }
  }

  //==========================================================================//
  //                            KHÔI PHỤC MẬT KHẨU                            //
  //==========================================================================//
  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  //==========================================================================//
  //                            ĐĂNG XUẤT                                     //
  //==========================================================================//
  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
    }
  }

  //==========================================================================//
  //                            ĐỔI MẬT KHẨU                                  //
  //==========================================================================//
  @override
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return "auth.user_not_found".tr();
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "auth.wrong_password".tr();
      } else if (e.code == 'weak-password') {
        return "auth.new_password_weak".tr();
      }
      return e.message ?? "auth.unknown_error".tr();
    }
  }

  //==========================================================================//
  //                            PRIVATE HELPER METHOD                         //
  //==========================================================================//
  /// Lấy UserModel từ Firestore
  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromJson(doc.data() ?? {}, uid);
  }

  /// Lưu user mới vào Firestore
  Future<void> _saveUserToFirestore({
    required String uid, // Lưu cái uid khác
    required String name, // Lưu tên
    required String email, // Lưu email
    String? photoUrl, // Lưu avatar của google/facebook mặc định
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'avatarUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Đảm bảo user tồn tại trong Firestore (cho Social Login)
  Future<void> _ensureUserInFirestore(UserCredential userCredential) async {
    final user = userCredential.user!;
    final doc = await _firestore.collection('users').doc(user.uid).get();

    // Kiểm tra có tồn tại hay không
    if (!doc.exists) {
      await _saveUserToFirestore(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      );
    }
  }

  /// Map Firebase error code sang message
  String _mapAuthError(String code) {
    switch (code) {
      case 'weak-password':
        return "auth.weak_password".tr();
      case 'email-already-in-use':
        return "auth.email_already_existed".tr();
      case 'invalid-email':
        return "auth.invalid_email".tr();
      case 'invalid-credential':
        return "auth.invalid_credential".tr();
      case 'user-disabled':
        return "auth.account_disabled".tr();
      default:
        return "auth.unknown_error".tr();
    }
  }
}

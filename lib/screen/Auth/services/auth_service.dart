import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthResult {
  final UserCredential? user;
  final String? error;

  AuthResult({this.user, this.error});

  bool get isSuccess => user != null;
}

class AuthService {
  // Phương thức dăng ký
  // ignore: body_might_complete_normally_nullable
  Future<AuthResult?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Khởi tạo password và email
      // ignore: unused_local_variable
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Lưu hết tất cả vào firestore
      await saveUserToFirestore(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
      );
      log('REGISTRATION COMPLETED');
      return AuthResult(user: userCredential);
    } on FirebaseException catch (e) {
      if (e.code == 'weak-password') {
        return AuthResult(error: "auth.weak_password".tr());
      } else if (e.code == 'email-already-in-use') {
        return AuthResult(error: "auth.email_already_existed".tr());
      } else if (e.code == 'invalid-email') {
        return AuthResult(error: "auth.invalid_email".tr());
      }
      return null;
    }
  }

  // Thêm method cho số điện thoại, tên, địa chỉ và năm sinh
  Future<void> saveUserToFirestore({
    required String uid,
    required String name,
    required String email,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ignore: body_might_complete_normally_nullable
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      log("LOGIN COMPLETED");
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'invalid-credential') {
        return "auth.invalid_credential".tr();
      } else if (e.code == 'invalid-email') {
        return "auth.invalid_email".tr();
      } else if (e.code == 'user-disabled') {
        return "auth.account_disabled".tr();
      }
      log('Firebase error: ${e.code}');
    }
  }

  // Google sign-in
  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser.authentication;

    // Kiểm tra token
    if (googleAuth?.accessToken == null && googleAuth?.idToken == null) {
      return null;
    }

    // Tạo tài khoản mới
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // Facebook sign-in
  Future<UserCredential?> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.accessToken == null) return null;

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(
          '${loginResult.accessToken?.tokenString}',
        );

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  // Reset password
  Future verifyEmail({required String email}) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  // Sign out
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
    }
  }

  // Đổi mật khẩu
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return "auth.user_not_found".tr();

      // Xác thực lại password hiện tại
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Đổi lại mật khẩu
      await user.updatePassword(newPassword);
      return null; // Thành công đổi mật khẩu
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "auth.wrong_password".tr();
      } else if (e.code == 'weak-password') {
        return "auth.new_password_weak".tr();
      }
      return e.message ?? "auth.unknown_error".tr();
    }
  }
}

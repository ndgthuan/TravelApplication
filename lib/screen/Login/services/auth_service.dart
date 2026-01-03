import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class AuthService {
  // Phương thức dăng ký
  // ignore: body_might_complete_normally_nullable
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // Khởi tạo password và email
      // ignore: unused_local_variable
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      log('REGISTRATION COMPLETED');
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'weak-password') {
        return "Weak password";
      } else if (e.code == 'email-already-in-use') {
        return "Email is already existed";
      } else if (e.code == 'invalid-email') {
        return "Invalid email";
      }
    }
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
        return 'Email or password is not correct';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email';
      } else if (e.code == 'user-disabled') {
        return 'Account is disabled';
      }
      log('Firebase error: ${e.code}');
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

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
}

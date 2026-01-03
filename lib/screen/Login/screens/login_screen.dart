import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isShowing = true;
  bool _isLoginPressed = false;
  bool _isGooglePressed = false;
  bool _isFacebookPressed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/login_screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Chữ Welcome Back!
            Align(
              alignment: Alignment.center,
              child: Text(
                "Welcome back!",
                style: GoogleFonts.abrilFatface(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Hộp nhập email
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  filled: true,

                  // Tạo icon nằm ở trước hộp nhập
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Hộp nhập password
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  filled: true,

                  // Tạo icon nằm ở trước hộp nhập
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white),

                  // Tạo icon con mắt ở sau hộp nhập
                  suffixIcon: IconButton(
                    // Nếu ấn vào thì chuyển sang icon còn lại
                    onPressed: () => setState(() {
                      _isShowing = !_isShowing;
                    }),
                    icon: Icon(
                      _isShowing ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Nút quên mật khẩu
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => log('FORGOT PASSWORD'),
                  child: Text(
                    "Forgot password",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ),
            ),

            // Thanh đăng nhập
            GestureDetector(
              onTapDown: (_) => setState(() => _isLoginPressed = true),
              onTapUp: (_) => setState(() => _isLoginPressed = false),
              onTapCancel: () => setState(() => _isLoginPressed = false),
              onTap: () => log('ENAIL LOGIN'),
              child: AnimatedScale(
                scale: _isLoginPressed ? 0.9 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                child: Container(
                  padding: EdgeInsets.only(
                    top: 15,
                    left: 175,
                    right: 175,
                    bottom: 15,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.white,
                        Color(
                          0xFFE0E0E0,
                        ), // Xám cực nhạt Hơi tím nhẹ (để hợp với dải ngân hà)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                    // Thêm hiệu ứng box shadow làm nổi bật nút login
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "Login",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dòng Or
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  // Vẽ thanh gạch ngang
                  Expanded(child: Divider(color: Colors.white, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Or",
                      style: GoogleFonts.dmSerifDisplay(
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(child: Divider(color: Colors.white, thickness: 1)),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Dòng logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Logo
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isGooglePressed = true),
                    onTapUp: (_) => setState(() => _isGooglePressed = false),
                    onTapCancel: () => setState(() => _isGooglePressed = false),
                    onTap: () => log('GOOGLE LOGIN'),
                    child: AnimatedScale(
                      scale: _isGooglePressed ? 0.9 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      child: Image.asset(
                        'lib/assets/images/google_logo.png',
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                ),

                // Facebook Logo
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isFacebookPressed = true),
                    onTapUp: (_) => setState(() => _isFacebookPressed = false),
                    onTapCancel: () =>
                        setState(() => _isFacebookPressed = false),
                    onTap: () => log('FACEBOOK LOGIN'),
                    child: AnimatedScale(
                      scale: _isFacebookPressed ? 0.9 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      child: Image.asset(
                        'lib/assets/images/facebook_logo.png',
                        width: 72,
                        height: 72,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Dòng signup
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),

                    // Tạo text span hộp để chứa các text chung
                    children: <TextSpan>[
                      TextSpan(text: "Don't have an account?"),
                      TextSpan(
                        text: ' Sign up',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Khi nhấn vào sign up sẽ chuyển sang trang Register
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                            log("SIGN UP");
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

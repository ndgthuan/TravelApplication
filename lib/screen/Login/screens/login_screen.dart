import 'dart:developer';
import 'package:flutter/gestures.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import '../../Plan/screens/plan_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isShowing = true;
  bool _isLoginPressed = false;
  bool _isGooglePressed = false;
  bool _isFacebookPressed = false;

  // Tạo instance của AuthService
  final AuthService _authService = AuthService();

  String? _emailError; // Lưu lỗi email từ Firebase
  String? _passwordError; // Lưu lỗi password từ Firebase

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

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
        child: Form(
          key: _formkey,
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
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is empty";
                    }
                    if (_emailError != null) {
                      return _emailError;
                    }
                    return null;
                  },
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
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is empty";
                    }
                    if (_passwordError != null) {
                      return _passwordError;
                    }
                    return null;
                  },
                  obscureText: _isShowing,
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
                onTap: () async {
                  // Nếu đang loading thì trả về
                  if (_isLoading) return;

                  // Xoá các lỗi sau khi có ấn lại
                  setState(() {
                    _isLoading = true;
                    _emailError = null;
                    _passwordError = null;
                  });

                  // Kiểm tra đầu ra result
                  if (_formkey.currentState!.validate()) {
                    String? result = await _authService.signIn(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    if (result == null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PlanScreen()),
                      );
                    } else {
                      // Truyền đầu ra error vào các biến
                      setState(() {
                        if (result.contains(' or ')) {
                          // Lỗi cả email và password
                          _emailError = result;
                          _passwordError = result;
                        } else if (result.toLowerCase().contains('email') ||
                            result.contains('Account')) {
                          _emailError = result;
                        } else {
                          _passwordError = result;
                        }
                      });
                      _formkey.currentState!.validate();
                    }
                  }

                  // Validate nếu thành công hay thất bại để khi nhấn thì vẫn sẽ chạy lại
                  setState(() {
                    _isLoading = false;
                  });
                },
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
                      onTapCancel: () =>
                          setState(() => _isGooglePressed = false),
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
                      onTapDown: (_) =>
                          setState(() => _isFacebookPressed = true),
                      onTapUp: (_) =>
                          setState(() => _isFacebookPressed = false),
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
      ),
    );
  }
}

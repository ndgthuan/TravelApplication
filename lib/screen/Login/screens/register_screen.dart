import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isShowingPassword = true;
  bool _isShowingReenterPassword = true;
  bool _isRegisterPressed = false;

  // Tạo các phương thức đăng ký
  String email = "", password = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reenterpasswordController = TextEditingController();

  // Tạo form key để bọc xung quanh các hộp đăng ký
  final _formkey = GlobalKey<FormState>();

  // Tạo instance của AuthService
  final AuthService _authService = AuthService();

  String? _emailError; // Lưu lỗi email từ Firebase

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/register_screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Chữ Welcome
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Welcome!",
                  style: GoogleFonts.abrilFatface(
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  // Tạo phương thức đăng ký
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Username is empty";
                    }
                    return null;
                  },
                  controller: nameController,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Username",
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.black.withValues(alpha: 0.3),
                    filled: true,

                    // Tạo icon nằm ở trước hộp nhập
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Hộp nhập email
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  // Tạo phương thức đăng ký
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is empty";
                    }
                    if (_emailError != null) {
                      return _emailError; // Hiện lỗi từ Firebase
                    }
                    return null;
                  },
                  controller: emailController,
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
                  // Tạo phương thức đăng ký
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is empty";
                    }
                    return null;
                  },
                  controller: passwordController,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  obscureText: _isShowingPassword,
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
                        _isShowingPassword = !_isShowingPassword;
                      }),
                      icon: Icon(
                        _isShowingPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  // Tạo phương thức đăng ký
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is empty";
                    }
                    if (value != passwordController.text) {
                      return "Password is not correct";
                    }
                    return null;
                  },
                  controller: reenterpasswordController,
                  obscureText: _isShowingReenterPassword,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Reenter password",
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.black.withValues(alpha: 0.3),
                    filled: true,

                    // Tạo icon nằm ở trước hộp nhập
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white),

                    // Tạo icon con mắt ở sau hộp nhập
                    suffixIcon: IconButton(
                      // Nếu ấn vào thì chuyển sang icon còn lại
                      onPressed: () => setState(() {
                        _isShowingReenterPassword = !_isShowingReenterPassword;
                      }),
                      icon: Icon(
                        _isShowingReenterPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Thanh đăng nhập
              GestureDetector(
                onTapDown: (_) => setState(() => _isRegisterPressed = true),
                onTapUp: (_) => setState(() => _isRegisterPressed = false),
                onTapCancel: () => setState(() => _isRegisterPressed = false),
                onTap: () async {
                  // Reset lỗi cũ
                  setState(() {
                    _emailError = null;
                  });
                  // Tạo form đăng ký
                  if (_formkey.currentState!.validate()) {
                    String? result = await _authService.signUp(
                      email: emailController.text,
                      password: passwordController.text,
                    );

                    // Kiểm tra nếu đăng ký thành công
                    if (result == null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    } else {
                      // Lưu lỗi vào state
                      setState(() {
                        _emailError =
                            result; // "Email is existed", "Invalid email"
                      });

                      _formkey.currentState!.validate();
                      // Validate lại để hiện lỗi trong TextFormField
                    }
                  }
                  log('ENAIL REGISTER');
                },
                child: AnimatedScale(
                  scale: _isRegisterPressed ? 0.9 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 15,
                      left: 170,
                      right: 170,
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
                      "Register",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
                        TextSpan(text: "Already have an account?"),
                        TextSpan(
                          text: ' Log in',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
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

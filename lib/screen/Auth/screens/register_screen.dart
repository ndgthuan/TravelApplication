import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/screen/Auth/services/password_service.dart';
import 'package:travel_app/screen/Auth/widgets/button_widget.dart';
import 'package:travel_app/screen/Auth/widgets/logo_widget.dart';
import 'package:travel_app/screen/Auth/widgets/password_widget.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../widgets/textfield_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;
  final bool _isShowingPassword = true;
  final bool _isShowingReenterPassword = true;

  // Tạo các phương thức đăng ký
  String email = "", password = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reenterpasswordController = TextEditingController();

  // Tạo form key để bọc xung quanh các hộp đăng ký
  final _formkey = GlobalKey<FormState>();

  // Tạo biến ẩn hiện kiểm tra
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
  }

  // Giải phóng bộ nhớ để khi không dùng để tránh memory leak
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    reenterpasswordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Tạo instance của AuthService
  final AuthService _authService = AuthService();

  String? _emailError; // Lưu lỗi email từ Firebase
  String? _passwordError;
  int _passwordStrength = 0; // Biến theo dõi độ mạnh password

  // Tạo các biến để lấy giá trị mật khẩu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(color: Color(0xFF121212)),
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo app
              AppLogo(),
              const SizedBox(height: 20),

              // Chữ Welcome
              TitleLogo(),
              const SizedBox(height: 10),

              // Subtitle
              SubtitleLogo(subtitleText: "Sign up to continue your journey"),
              const SizedBox(height: 50),

              // Hộp nhập Username
              UserTextField(
                labelText: "Username",
                prefixIcon: Icons.person,
                controller: nameController,
                textReturn: "Username is empty",
              ),
              const SizedBox(height: 15),

              // Hộp nhập email
              EmailTextField(
                labelText: "Email",
                prefixIcon: Icons.email_outlined,
                controller: emailController,
                textReturn: "Email is empty",
                stringError: _emailError,
              ),
              const SizedBox(height: 15),

              // Hộp nhập password
              PasswordTextField(
                focusNode: _passwordFocusNode,
                isShowing: _isShowingPassword,
                labelText: "Password",
                prefixIcon: Icons.lock_outline,
                controller: passwordController,
                onChanged: (value) {
                  setState(() {
                    _passwordStrength = checkPasswordStrength(value);
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password is empty";
                  }
                  if (_passwordError != null) return _passwordError;
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Thanh hiển thị độ mạnh password
              if (_isPasswordFocused)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress bar
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              _passwordStrength / 9, // Max strength = 9
                          child: Container(
                            decoration: BoxDecoration(
                              color: getPasswordStrength(_passwordStrength),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Text hiển thị độ mạnh
                      Text(
                        getStrengthText(_passwordStrength),
                        style: TextStyle(
                          color: getPasswordStrength(_passwordStrength),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              // Hộp reenter password
              PasswordTextField(
                isShowing: _isShowingReenterPassword,
                labelText: "Reenter password",
                prefixIcon: Icons.lock_outline,
                controller: reenterpasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password is empty";
                  }
                  if (value != passwordController.text) {
                    return "Password is not correct";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Thanh đăng ký
              ActionButton(
                buttonText: "Register",
                onTap: () async {
                  if (_isLoading) return;
                  // Reset lỗi cũ
                  setState(() {
                    _emailError = null;
                    _passwordError = null;
                    _isLoading = true;
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
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    } else if (result.contains('email') ||
                        result.contains('Email')) {
                      // Lưu lỗi vào state
                      setState(() {
                        _emailError =
                            result; // "Email is existed", "Invalid email"
                      });

                      _formkey.currentState!.validate();
                      // Validate lại để hiện lỗi trong TextFormField
                    } else if (result.contains('password')) {
                      setState(() {
                        _passwordError = result;
                      });
                      _formkey.currentState!.validate();
                    }
                  }

                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Dòng login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BottomSwitchPageButton(
                    formerText: "Already have an account? ",
                    latterText: "Log in",
                    destinationScreen: LoginScreen(),
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

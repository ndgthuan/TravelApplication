import 'package:travel_app/screen/Auth/widgets/logo_widget.dart';
import 'package:travel_app/shared/widgets/navigation_widget.dart';
import '../widgets/dialog_widget.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import '../widgets/button_widget.dart';
import '../widgets/textfield_widget.dart';
import 'package:animations/animations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Các bién
  bool _isLoading = false;
  final bool _isShowing = true;

  final bool _isGooglePressed = false;
  final bool _isFacebookPressed = false;
  final _resetEmail = TextEditingController();

  // Tạo instance của AuthService
  final AuthService _authService = AuthService();

  String? _emailError; // Lưu lỗi email từ Firebase
  String? _passwordError; // Lưu lỗi password từ Firebase

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _resetEmail.dispose();
    super.dispose();
  }

  void createForgotPassForm() {
    showModal(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(
        transitionDuration: Duration(milliseconds: 500), // Thời gian mở
        reverseTransitionDuration: Duration(
          milliseconds: 300,
        ), // Thời gian đóng
        barrierDismissible: true, // Tap ngoài để đóng
        barrierColor: Colors.black54, // Màu overlay
        barrierLabel: 'Dismiss',
      ),
      builder: (context) {
        return ForgotPasDialog(controller: _resetEmail);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF000000)),
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo app
                  AppLogo(),
                  const SizedBox(height: 20),

                  // Chữ Welcome!
                  TitleLogo(),
                  const SizedBox(height: 10),

                  SubtitleLogo(subtitleText: "Log in to continue your journey"),
                  const SizedBox(height: 50),

                  // Hộp nhập email
                  EmailTextField(
                    labelText: "Email",
                    prefixIcon: Icons.email_outlined,
                    controller: emailController,
                    textReturn: "Email is empty",
                    stringError: _emailError,
                  ),
                  const SizedBox(height: 15),

                  PasswordTextField(
                    isShowing: _isShowing,
                    labelText: "Password",
                    prefixIcon: Icons.lock_outline,
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
                  ),
                  const SizedBox(height: 10),

                  // Nút quên mật khẩu
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Color(0xFFFFAD33);
                          createForgotPassForm();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(
                            0xFFFFAD33,
                          ), // Màu hiệu ứng khi bấm vào
                        ),
                        child: Text(
                          "Forgot password",
                          style: GoogleFonts.beVietnamPro(
                            color: Color(0xFFCCCCCC),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Thanh đăng nhập
                  ActionButton(
                    buttonText: "Login",
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
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => BottomNavigation(),
                            ),
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
                  ),
                  const SizedBox(height: 20),

                  // Dòng Or
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      children: [
                        // Vẽ thanh gạch ngang
                        Expanded(
                          child: Divider(color: Colors.white, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Or login with",
                            style: GoogleFonts.beVietnamPro(
                              color: Color(0xFF888888),
                              fontSize: 13,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Divider(color: Colors.white, thickness: 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Dòng logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Logo
                      SocialIconButton(
                        isPressed: _isGooglePressed,
                        imagePath: "lib/assets/images/google_logo.png",
                        authFunction: _authService.signInWithGoogle,
                      ),

                      // Facebook Logo
                      SocialIconButton(
                        isPressed: _isFacebookPressed,
                        imagePath: 'lib/assets/images/facebook_logo.png',
                        authFunction: _authService.signInWithFacebook,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Dòng signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BottomSwitchPageButton(
                        formerText: "Don't have an account? ",
                        latterText: "Sign up",
                        destinationScreen: RegisterScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

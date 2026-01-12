import 'package:travel_app/screen/Auth/widgets/logo_widget.dart';
import 'package:travel_app/screen/Auth/widgets/social_login_widget.dart';
import 'package:travel_app/shared/widgets/navigation_widget.dart';
import '../widgets/dialog_widget.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'register_screen.dart';
import '../widgets/switch_page_button_widget.dart';
import 'package:animations/animations.dart';
import '../services/storage_service.dart';
import '../widgets/login_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Các bién
  bool _isCheck = false;
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadSaveCredentails();
  }

  Future<void> _loadSaveCredentails() async {
    final credentials = await StorageService.getCredentials();
    if (credentials['email'] != null && credentials['password'] != null) {
      if (!mounted) return;
      setState(() {
        emailController.text = credentials['email']!;
        passwordController.text = credentials['password']!;
        _isCheck = true;
        _isLoading = true;
      });

      // Tự động gọi đăng nhập
      String? result = await _authService.signIn(
        email: credentials['email']!,
        password: credentials['password']!,
      );

      if (result == null) {
        // Thành công thì vào thẳng home
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigation()),
        );
      } else {
        setState(() {
          _isLoading = false; // Thất bại thì tự bấm
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild mỗi khi đổi ngôn ngữ
    var _ = context.locale;
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

                  SubtitleLogo(subtitleText: "auth.login_subtitle".tr()),
                  const SizedBox(height: 50),

                  LoginFormWidget(
                    emailController: emailController,
                    passwordController: passwordController,
                    formKey: _formkey,
                    emailError: _emailError,
                    passwordError: _passwordError,
                    isCheck: _isCheck,
                    isShowing: _isShowing,
                    onRememberMeChanged: () {
                      setState(() {
                        _isCheck = !_isCheck;
                      });
                    },
                    onForgotPassword: () {
                      Color(0xFFFFAD33);
                      createForgotPassForm();
                    },
                    onLogin: () async {
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
                          if (_isCheck) {
                            await StorageService.saveCredentials(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                          } else {
                            await StorageService.clearCredentials();
                          }

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

                  SocialLoginWidget(
                    isGooglePressed: _isGooglePressed,
                    isFacebookPressed: _isFacebookPressed,
                  ),
                  SizedBox(height: 20),

                  // Dòng signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SwitchPageButtonWidget(
                        formerText: "auth.dont_have_account".tr(),
                        latterText: "auth.sign_up".tr(),
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

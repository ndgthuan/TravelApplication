import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/screen/Auth/services/password_service.dart';
import 'package:travel_app/screen/Auth/widgets/switch_page_button_widget.dart';
import 'package:travel_app/screen/Auth/widgets/logo_widget.dart';
import 'package:travel_app/screen/Auth/widgets/register_form_widget.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

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
            decoration: BoxDecoration(color: Color(0xFF000000)),
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
                  SubtitleLogo(subtitleText: "auth.signup_subtitle".tr()),
                  const SizedBox(height: 50),

                  // Register Form Widget
                  RegisterFormWidget(
                    nameController: nameController,
                    emailController: emailController,
                    passwordController: passwordController,
                    reenterpasswordController: reenterpasswordController,
                    emailError: _emailError,
                    passwordError: _passwordError,
                    isPasswordFocused: _isPasswordFocused,
                    isShowingPassword: _isShowingPassword,
                    isShowingReenterPassword: _isShowingReenterPassword,
                    passwordFocusNode: _passwordFocusNode,
                    passwordStrength: _passwordStrength,
                    onChange: (value) {
                      setState(() {
                        _passwordStrength = checkPasswordStrength(value);
                      });
                    },
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
                        AuthResult? result = await _authService.signUp(
                          email: emailController.text,
                          password: passwordController.text,
                          name: nameController.text,
                        );

                        // Kiểm tra nếu đăng ký thành công
                        if (result != null && result.isSuccess) {
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        } else if (result != null && result.error != null) {
                          if (result.error!.contains('email') ||
                              result.error!.contains('Email')) {
                            setState(() {
                              _emailError = result.error;
                            });
                            _formkey.currentState!.validate();
                          } else if (result.error!.contains('password')) {
                            setState(() {
                              _passwordError = result.error;
                            });
                            _formkey.currentState!.validate();
                          }
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
                      SwitchPageButtonWidget(
                        formerText: "auth.already_have_account".tr(),
                        latterText: "auth.log_in".tr(),
                        destinationScreen: LoginScreen(),
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

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/shared/utils/password_utils.dart';
import 'package:travel_app/features/Auth/viewmodels/register_view_model.dart';
import 'package:travel_app/features/Auth/widgets/auth_switch_button_widget.dart';
import 'package:travel_app/features/Auth/widgets/auth_logo_widget.dart';
import 'package:travel_app/features/Auth/widgets/register_form_widget.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Tạo các phương thức đăng ký
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final reenterpasswordController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    // Rebuild mỗi khi đổi ngôn ngữ
    var _ = context.locale;
    final viewModel = context.watch<RegisterViewModel>();
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
                  AuthLogoWidget(),
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
                    emailError: viewModel.emailError,
                    passwordError: viewModel.passwordError,
                    isPasswordFocused: _isPasswordFocused,
                    isShowingPassword: true,
                    isShowingReenterPassword: true,
                    passwordFocusNode: _passwordFocusNode,
                    passwordStrength: viewModel.passwordStrength,
                    onChange: (value) {
                      viewModel.updatePasswordStrength(
                        checkPasswordStrength(value),
                      );
                    },
                    onTap: () async {
                      // Loading khi đang trong qua trình đăng ký
                      if (viewModel.isLoading) return;
                      // Tạo form đăng ký
                      if (_formkey.currentState!.validate()) {
                        final success = await viewModel.signUp(
                          email: emailController.text,
                          password: passwordController.text,
                          name: nameController.text,
                        );

                        if (success && mounted) {
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        } else {
                          _formkey.currentState!.validate();
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Dòng login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AuthSwitchButtonWidget(
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

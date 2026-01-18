// Đây là trang UI và chỉ có 1 mục đích là gọi UI
// Không thêm các biến hay phương thức nào trong trang
import 'package:provider/provider.dart';
import 'package:travel_app/features/Auth/viewmodels/login_view_model.dart';
import 'package:travel_app/features/Auth/widgets/auth_logo_widget.dart';
import 'package:travel_app/features/Auth/widgets/social_login_widget.dart';
import 'package:travel_app/shared/widgets/navigation_widget.dart';
import '../widgets/forgot_password_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'register_screen.dart';
import '../widgets/auth_switch_button_widget.dart';
import 'package:animations/animations.dart';
import '../../../shared/services/storage_service.dart';
import '../widgets/login_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _resetEmail = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _resetEmail.dispose();
    super.dispose();
  }

  void createForgotPassForm() {
    // Gọi view model
    final viewModel = context.read<LoginViewModel>();
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
        return ForgotPasswordDialogWidget(
          controller: _resetEmail,
          onSendResetEmail: (email) async {
            await viewModel.sendPasswordResetEmail(email);
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSaveCredentials();
  }

  Future<void> _loadSaveCredentials() async {
    final viewModel = context.read<LoginViewModel>();
    final credentials = await StorageService.getCredentials();

    if (credentials['email'] != null && credentials['password'] != null) {
      if (!mounted) return;
      emailController.text = credentials['email']!;
      passwordController.text = credentials['password']!;
      viewModel.setRememberMe(true);
      // Tự động đăng nhập
      final success = await viewModel.signIn(
        email: credentials['email']!,
        password: credentials['password']!,
      );
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigation()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild mỗi khi đổi ngôn ngữ
    var _ = context.locale;

    // Lắng nghe ViewModel
    final viewModel = context.watch<LoginViewModel>();
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
                  AuthLogoWidget(),
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
                    emailError: viewModel.emailError,
                    passwordError: viewModel.passwordError,
                    isCheck: viewModel.rememberMe,
                    isShowing: true,
                    onRememberMeChanged: () => viewModel.toggleRememberMe(),
                    onForgotPassword: () => createForgotPassForm(),
                    onLogin: () async {
                      // Nếu đang loading thì trả về
                      if (viewModel.isLoading) return;

                      // Kiểm tra đầu ra result
                      if (_formkey.currentState!.validate()) {
                        final success = await viewModel.signIn(
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        if (success) {
                          if (viewModel.rememberMe) {
                            await StorageService.saveCredentials(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                          } else {
                            await StorageService.clearCredentials();
                          }

                          if (mounted) {
                            Navigator.pushReplacement(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                builder: (context) => BottomNavigation(),
                              ),
                            );
                          } else {
                            _formkey.currentState!.validate();
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  SocialLoginWidget(
                    isGooglePressed: viewModel.isGooglePressed,
                    isFacebookPressed: viewModel.isFacebookPressed,
                    onGoogleTap: () async {
                      final success = await viewModel.signInWithGoogle();
                      if (success && mounted) {
                        Navigator.pushReplacement(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(builder: (_) => BottomNavigation()),
                        );
                      }
                    },
                    onFacebookTap: () async {
                      final success = await viewModel.signInWithFacebook();
                      if (success && mounted) {
                        Navigator.pushReplacement(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(builder: (_) => BottomNavigation()),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 20),

                  // Dòng signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AuthSwitchButtonWidget(
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

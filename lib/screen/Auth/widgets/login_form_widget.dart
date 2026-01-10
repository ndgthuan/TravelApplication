import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/shared/widgets/action_button_widget.dart';
import 'package:travel_app/screen/Auth/widgets/email_field_widget.dart';
import 'package:travel_app/screen/Auth/widgets/password_field_widget.dart';

class LoginFormWidget extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final String? emailError;
  final String? passwordError;
  final bool isCheck;
  final bool isShowing;
  final VoidCallback onRememberMeChanged;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;
  const LoginFormWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    required this.emailError,
    required this.passwordError,
    required this.isCheck,
    required this.isShowing,
    required this.onRememberMeChanged,
    required this.onForgotPassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hộp nhập email
        EmailFieldWidget(
          labelText: "Email",
          prefixIcon: Icons.email_outlined,
          controller: emailController,
          textReturn: "Email is empty",
          stringError: emailError,
        ),
        const SizedBox(height: 15),

        PasswordFieldWidget(
          isShowing: isShowing,
          labelText: "Password",
          prefixIcon: Icons.lock_outline,
          controller: passwordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Password is empty";
            }
            if (passwordError != null) {
              return passwordError;
            }
            return null;
          },
        ),
        const SizedBox(height: 10),

        // Nút quên mật khẩu
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    // Hộp checkbox
                    GestureDetector(
                      onTap: onRememberMeChanged,
                      child: Icon(
                        isCheck
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: Color(0xFFFFAD35),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Chữ remember me
                    Text(
                      'Remember me',
                      style: GoogleFonts.beVietnamPro(
                        color: Color(0xFFCCCCCC),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onForgotPassword,
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
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Thanh đăng nhập
        ActionButtonWidget(buttonText: "Login", onTap: onLogin),
      ],
    );
  }
}

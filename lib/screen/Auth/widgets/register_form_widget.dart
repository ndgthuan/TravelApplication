import 'package:flutter/material.dart';
import 'package:travel_app/screen/Auth/widgets/action_button_widget.dart';
import 'package:travel_app/screen/Auth/widgets/email_field_widget.dart';
import 'package:travel_app/screen/Auth/widgets/password_field_widget.dart';
import 'password_widget.dart';
import 'user_field_widget.dart';

class RegisterFormWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController reenterpasswordController;
  final String? emailError;
  final String? passwordError;
  final FocusNode passwordFocusNode;
  final bool isPasswordFocused;
  final bool isShowingPassword;
  final bool isShowingReenterPassword;
  final VoidCallback onTap;
  final void Function(String)? onChange;
  final int passwordStrength;
  const RegisterFormWidget({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.reenterpasswordController,
    required this.emailError,
    required this.passwordError,
    required this.isPasswordFocused,
    required this.isShowingPassword,
    required this.isShowingReenterPassword,
    required this.onChange,
    required this.passwordFocusNode,
    required this.passwordStrength,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hộp nhập Username
        UserFieldWidget(
          labelText: "Username",
          prefixIcon: Icons.person,
          controller: nameController,
          textReturn: "Username is empty",
        ),
        const SizedBox(height: 15),

        // Hộp nhập email
        EmailFieldWidget(
          labelText: "Email",
          prefixIcon: Icons.email_outlined,
          controller: emailController,
          textReturn: "Email is empty",
          stringError: emailError,
        ),
        const SizedBox(height: 15),

        // Hộp nhập password
        PasswordFieldWidget(
          focusNode: passwordFocusNode,
          isShowing: isShowingPassword,
          labelText: "Password",
          prefixIcon: Icons.lock_outline,
          controller: passwordController,
          onChanged: onChange,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Password is empty";
            }
            if (passwordError != null) return passwordError;
            return null;
          },
        ),
        const SizedBox(height: 15),

        // Thanh hiển thị độ mạnh password
        if (isPasswordFocused)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    widthFactor: passwordStrength / 9, // Max strength = 9
                    child: Container(
                      decoration: BoxDecoration(
                        color: getPasswordStrength(passwordStrength),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Text hiển thị độ mạnh
                Text(
                  getStrengthText(passwordStrength),
                  style: TextStyle(
                    color: getPasswordStrength(passwordStrength),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

        // Hộp reenter password
        PasswordFieldWidget(
          isShowing: isShowingReenterPassword,
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
        ActionButtonWidget(buttonText: "Register", onTap: onTap),
      ],
    );
  }
}

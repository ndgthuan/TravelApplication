import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/screen/Auth/widgets/email_field_widget.dart';
import 'package:travel_app/screen/Auth/widgets/password_field_widget.dart';
import 'package:travel_app/shared/utils/password_utils.dart';
import 'package:travel_app/shared/widgets/app_button_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'username_field_widget.dart';

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
        UsernameFieldWidget(
          labelText: "auth.username".tr(),
          prefixIcon: Icons.person,
          controller: nameController,
          textReturn: "auth.username_empty".tr(),
        ),
        const SizedBox(height: 15),

        // Hộp nhập email
        EmailFieldWidget(
          labelText: "auth.email".tr(),
          prefixIcon: Icons.email_outlined,
          controller: emailController,
          textReturn: "auth.email_empty".tr(),
          stringError: emailError,
        ),
        const SizedBox(height: 15),

        // Hộp nhập password
        PasswordFieldWidget(
          focusNode: passwordFocusNode,
          isShowing: isShowingPassword,
          labelText: "auth.password".tr(),
          prefixIcon: Icons.lock_outline,
          controller: passwordController,
          onChanged: onChange,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "auth.password_empty".tr();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getPasswordStrengthText(passwordStrength),
                      style: TextStyle(
                        color: getPasswordStrength(passwordStrength),
                        fontSize: 12,
                      ),
                    ),

                    Text(
                      'auth.min_chars'.tr(),
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Hộp reenter password
        PasswordFieldWidget(
          isShowing: isShowingReenterPassword,
          labelText: "auth.reenter_password".tr(),
          prefixIcon: Icons.lock_outline,
          controller: reenterpasswordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "auth.password_empty".tr();
            }
            if (value != passwordController.text) {
              return "auth.password_not_match".tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 30),

        // Thanh đăng ký
        AppButtonWidget(buttonText: "auth.register".tr(), onTap: onTap),
      ],
    );
  }
}

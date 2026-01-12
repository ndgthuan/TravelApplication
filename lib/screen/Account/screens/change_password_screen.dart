import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/screen/Auth/services/auth_service.dart';
import '../../../shared/widgets/action_button_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/password_field_widget.dart';
import '../../Auth/widgets/password_widget.dart';
import '../../Auth/services/password_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Biến đổi mật khẩu
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  // Các phương thức cho hộp nhập
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController reenterPasswordController =
      TextEditingController();

  // FocusNode để hiển thị thanh password strength
  final FocusNode _newPasswordFocusNode = FocusNode();
  bool _isNewPasswordFocused = false;
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _newPasswordFocusNode.addListener(() {
      setState(() {
        _isNewPasswordFocused = _newPasswordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    reenterPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1C1D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'account.change_password'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF000000),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon chiếc khiên bảo vệ
              Icon(Icons.shield_outlined, color: Color(0xFFFFAD35), size: 250),
              const SizedBox(height: 10),

              Text(
                'account.password_security_hint'.tr(),
                style: GoogleFonts.beVietnamPro(
                  color: Colors.grey[600],
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 25),
              // Current Password
              PasswordFieldWidget(
                titleText: 'auth.current_password'.tr(),
                isShowing: true,
                hintText: 'auth.current_password'.tr(),
                prefixIcon: Icons.lock_outline,
                controller: currentPasswordController,
              ),
              const SizedBox(height: 20),

              // New Password
              PasswordFieldWidget(
                titleText: 'auth.new_password'.tr(),
                isShowing: true,
                hintText: 'auth.new_password'.tr(),
                prefixIcon: Icons.lock_open,
                controller: newPasswordController,
                focusNode: _newPasswordFocusNode,
                onChanged: (value) {
                  setState(() {
                    _passwordStrength = checkPasswordStrength(value);
                  });
                },
              ),
              const SizedBox(height: 10),

              // Password Strength Meter
              if (_isNewPasswordFocused ||
                  newPasswordController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          widthFactor: _passwordStrength / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              color: getPasswordStrength(_passwordStrength),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Text hiển thị độ mạnh + Requirements
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getStrengthText(_passwordStrength),
                            style: TextStyle(
                              color: getPasswordStrength(_passwordStrength),
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
              const SizedBox(height: 15),

              // Reenter New Password
              PasswordFieldWidget(
                titleText: 'auth.reenter_new_password'.tr(),
                isShowing: true,
                hintText: 'auth.reenter_new_password'.tr(),
                prefixIcon: Icons.lock_open,
                controller: reenterPasswordController,
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'auth.password_not_match'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Hiển thị lỗi
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // Save Button
              ActionButtonWidget(
                buttonText: _isLoading
                    ? 'general.loading'.tr()
                    : 'account.save_changes'.tr(),
                onTap: () async {
                  if (_isLoading) return;
                  // Xác minh
                  if (newPasswordController.text !=
                      reenterPasswordController.text) {
                    setState(
                      () => _errorMessage = 'auth.password_not_match'.tr(),
                    );
                    return;
                  }

                  if (newPasswordController.text.length < 8) {
                    setState(() => _errorMessage = 'auth.min_chars'.tr());
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  // Gọi changePassword
                  final result = await _authService.changePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                  );

                  if (!mounted) return;

                  setState(() => _isLoading = false);
                  // Thoát khi ấn thay đổi
                  if (result == null) {
                    // Success
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('general.success'.tr()),
                        backgroundColor: Color(0xFFFFAD35),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  } else {
                    // Gọi lỗi
                    setState(() => _errorMessage = result);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

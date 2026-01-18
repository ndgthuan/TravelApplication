import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/account/viewmodels/change_password_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/shared/widgets/password_field_widget.dart';
import 'package:travel_app/shared/utils/password_utils.dart';
import 'package:travel_app/shared/widgets/app_button_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Các phương thức cho hộp nhập
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final reenterPasswordController = TextEditingController();

  // FocusNode để hiển thị thanh password strength
  final FocusNode _newPasswordFocusNode = FocusNode();
  bool _isNewPasswordFocused = false;

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
    final viewModel = context.watch<ChangePasswordViewModel>();
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
              Icon(CupertinoIcons.shield, color: Color(0xFFFFAD35), size: 250),
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
                showTitle: true,
                hintText: 'auth.current_password'.tr(),
                prefixIcon: CupertinoIcons.lock,
                controller: currentPasswordController,
              ),
              const SizedBox(height: 20),

              // New Password
              PasswordFieldWidget(
                titleText: 'auth.new_password'.tr(),
                isShowing: true,
                showTitle: true,
                hintText: 'auth.new_password'.tr(),
                prefixIcon: Icons.lock_open,
                controller: newPasswordController,
                focusNode: _newPasswordFocusNode,
                onChanged: (value) {
                  context
                      .read<ChangePasswordViewModel>()
                      .updatePasswordStrength(value);
                  setState(() {});
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
                          widthFactor: viewModel.passwordStrength / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              color: getPasswordStrength(
                                viewModel.passwordStrength,
                              ),
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
                            getPasswordStrengthText(viewModel.passwordStrength),
                            style: TextStyle(
                              color: getPasswordStrength(
                                viewModel.passwordStrength,
                              ),
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
                showTitle: true,
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
              const SizedBox(height: 10),

              // Hiển thị lỗi
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    viewModel.errorMessage!,
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // Save Button
              AppButtonWidget(
                buttonText: viewModel.isLoading
                    ? 'general.loading'.tr()
                    : 'account.save_changes'.tr(),
                onTap: () async {
                  final viewModel = context.read<ChangePasswordViewModel>();
                  final success = await viewModel.changePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                    reenterPassword: reenterPasswordController.text,
                  );

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('general.success'.tr()),
                        backgroundColor: Color(0xFFFFAD35),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    Navigator.pop(context);
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

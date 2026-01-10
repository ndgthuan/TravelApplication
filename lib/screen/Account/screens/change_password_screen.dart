import 'package:flutter/material.dart';
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
        backgroundColor: const Color(0xFF1C1C1D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Change Password',
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF000000),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon chiếc khiên bảo vệ
            Icon(Icons.shield_outlined, color: Color(0xFFFFAD35), size: 250),
            const SizedBox(height: 10),

            Text(
              'Password for your account security',
              style: GoogleFonts.beVietnamPro(
                color: Colors.grey[600],
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 25),
            // Current Password
            PasswordFieldWidget(
              titleText: 'Current Password',
              isShowing: true,
              hintText: 'Enter your current password',
              prefixIcon: Icons.lock_outline,
              controller: currentPasswordController,
            ),
            const SizedBox(height: 20),

            // New Password
            PasswordFieldWidget(
              titleText: 'New Password',
              isShowing: true,
              hintText: 'Enter your new password',
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
            if (_isNewPasswordFocused || newPasswordController.text.isNotEmpty)
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
                          'Min. 8 chars, include number & symbol',
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
              titleText: 'Reenter New Password',
              isShowing: true,
              hintText: 'Reenter your new password',
              prefixIcon: Icons.lock_open,
              controller: reenterPasswordController,
              validator: (value) {
                if (value != newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),

            // Save Button
            ActionButtonWidget(
              buttonText: "Save Changes",
              onTap: () {
                // TODO: Add validation and save logic
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

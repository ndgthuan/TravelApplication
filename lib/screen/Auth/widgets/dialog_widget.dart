import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class ForgotPasDialog extends StatefulWidget {
  final controller;
  const ForgotPasDialog({super.key, required this.controller});

  @override
  State<ForgotPasDialog> createState() => _ForgotPasDialogState();
}

class _ForgotPasDialogState extends State<ForgotPasDialog> {
  bool _isResetPasswordPress = false;
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFF333333), // Viền xám nhẹ để tách nền
          width: 1,
        ),
      ),

      title: Text(
        "Reset Email",
        style: GoogleFonts.beVietnamPro(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hộp nhập
          TextFormField(
            controller: widget.controller,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelText: "Enter your email",
              labelStyle: GoogleFonts.beVietnamPro(
                color: Colors.grey[600],
                fontSize: 15,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 20),

          // Nút reset email
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isResetPasswordPress = true),
              onTapUp: (_) => setState(() => _isResetPasswordPress = false),
              onTapCancel: () => setState(() => _isResetPasswordPress = false),
              onTap: () async {
                if (widget.controller.text.isNotEmpty) {
                  await _authService.verifyEmail(email: widget.controller.text);
                  // Đóng dialog sau khi gửi
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: AnimatedScale(
                scale: _isResetPasswordPress ? 0.9 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Resend email",
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

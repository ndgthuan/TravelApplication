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
      backgroundColor: Colors.transparent,
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Colors.white, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        height: 200,
        width: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Chữ Reset email
            Text(
              "Reset Email",
              style: GoogleFonts.nunito(color: Colors.black, fontSize: 19),
            ),
            const SizedBox(height: 10),

            // Hộp nhập
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: double.infinity,
                child: TextFormField(
                  controller: widget.controller,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Email",
                    labelStyle: GoogleFonts.nunito(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nút reset email
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isResetPasswordPress = true),
                onTapUp: (_) => setState(() => _isResetPasswordPress = false),
                onTapCancel: () =>
                    setState(() => _isResetPasswordPress = false),
                onTap: () async {
                  if (widget.controller.text.isNotEmpty) {
                    await _authService.verifyEmail(
                      email: widget.controller.text,
                    );
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
                        style: GoogleFonts.nunito(
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
      ),
    );
  }
}

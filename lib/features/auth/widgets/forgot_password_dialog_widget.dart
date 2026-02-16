import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordDialogWidget extends StatefulWidget {
  final TextEditingController controller;
  final Future<void> Function(String email)
  onSendResetEmail; // Hàm gọi method reset email
  const ForgotPasswordDialogWidget({
    super.key,
    required this.controller,
    required this.onSendResetEmail,
  });

  @override
  State<ForgotPasswordDialogWidget> createState() =>
      _ForgotPasswordDialogWidgetState();
}

class _ForgotPasswordDialogWidgetState
    extends State<ForgotPasswordDialogWidget> {
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
        "auth.reset_email_title".tr(),
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Color(0xFFFFAD33), width: 1.5),
              ),
              labelText: "auth.reset_email_instruction".tr(),
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
              onTap: () async {
                if (widget.controller.text.isNotEmpty) {
                  await widget.onSendResetEmail(
                    widget.controller.text,
                  ); // Gọi callback
                  // Đóng dialog sau khi gửi
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFAD35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "auth.resend_email".tr(),
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.black,
                        fontSize: 15,
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

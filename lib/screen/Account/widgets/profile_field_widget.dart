import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class ProfileFieldWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final bool isShow;

  const ProfileFieldWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.isShow = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            obscureText: isShow,
            cursorColor: Color(0xFFFFAD35),
            inputFormatters: inputFormatters,
            style: GoogleFonts.beVietnamPro(color: Colors.white),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Color(0xFF333333)),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Color(0xFFFFAD33), width: 1.5),
              ),
              // Tạo icon nằm ở trước hộp nhập
              prefixIcon: Icon(icon, color: Colors.grey[600]),
              hintText: hintText,
              fillColor: Color(0xFF1C1C1D),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}

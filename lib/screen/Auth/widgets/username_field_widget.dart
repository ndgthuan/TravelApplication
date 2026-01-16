import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UsernameFieldWidget extends StatelessWidget {
  final String labelText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String textReturn;

  const UsernameFieldWidget({
    super.key,
    required this.labelText,
    required this.prefixIcon,
    required this.controller,
    required this.textReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return textReturn;
          }
          return null;
        },
        style: GoogleFonts.beVietnamPro(color: Colors.white),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF333333)),
          ),
          labelText: labelText,
          labelStyle: GoogleFonts.beVietnamPro(
            color: Colors.grey[600],
            fontSize: 18,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFFFAD33), width: 1.5),
          ),
          fillColor: Color(0xFF1C1C1D),
          filled: true,
          prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
        ),
      ),
    );
  }
}

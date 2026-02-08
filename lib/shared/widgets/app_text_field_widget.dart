import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Mục đích của widget này là tạo text field thống nhất
class AppTextFieldWidget extends StatelessWidget {
  // Text
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final double? labelFontSize;
  // Icons
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  // Behavior
  final int maxLines;
  final bool readOnly;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  // Validation
  final String? Function(String?)? validator;
  final String? errorText;
  // Callbacks
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  // Style
  final bool showLabel; // Hiện label phía trên field
  final double horizontalPadding; // Padding mặc định
  const AppTextFieldWidget({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.errorText,
    this.onChanged,
    this.focusNode,
    this.showLabel = false,
    this.horizontalPadding = 20,
    this.labelFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label phía trên (nếu showLabel = true)
          if (showLabel && labelText != null) ...[
            Text(
              labelText!,
              style: GoogleFonts.beVietnamPro(
                color: Colors.white,
                fontSize: labelFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          // TextFormField chính
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            readOnly: readOnly,
            obscureText: obscureText,
            maxLines: obscureText ? 1 : maxLines,
            cursorColor: const Color(0xFFFFAD35),
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: GoogleFonts.beVietnamPro(color: Colors.white),
            validator: validator,
            decoration: InputDecoration(
              labelText: showLabel ? null : labelText,
              labelStyle: GoogleFonts.beVietnamPro(
                color: Colors.grey[600],
                fontSize: 18,
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.beVietnamPro(
                color: Colors.grey[600],
                fontSize: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF333333)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFFFAD33),
                  width: 1.5,
                ),
              ),
              fillColor: const Color(0xFF1C1C1D),
              filled: true,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: Colors.grey[600])
                  : null,
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}

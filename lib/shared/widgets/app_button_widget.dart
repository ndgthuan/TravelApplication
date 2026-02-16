import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Các style cho button
enum AppButtonStyle { filled, outlined }

// Nút cho đăng nhập và đăng ký
class AppButtonWidget extends StatefulWidget {
  final String buttonText;
  final VoidCallback onTap;
  final AppButtonStyle style;
  final Color? outlineColor;
  final bool isLoading; // Loading state
  final double height;

  const AppButtonWidget({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.style = AppButtonStyle.filled,
    this.outlineColor,
    this.isLoading = false,
    this.height = 65,
  });

  @override
  State<AppButtonWidget> createState() => _AppButtonWidgetState();
}

class _AppButtonWidgetState extends State<AppButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: widget.style == AppButtonStyle.filled
            ? _buildFilledButton()
            : _buildOutlinedButton(),
      ),
    );
  }

  // Style 1: Filled (màu cam đặc)
  Widget _buildFilledButton() {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFFF6D00),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: widget.isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(
                widget.buttonText,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // Style 2: Outlined (chỉ có border)
  Widget _buildOutlinedButton() {
    final color = widget.outlineColor ?? Colors.redAccent;
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: widget.isLoading ? Colors.grey : color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: widget.isLoading
            ? CircularProgressIndicator(color: color)
            : Text(
                widget.buttonText,
                style: GoogleFonts.beVietnamPro(color: color, fontSize: 15),
              ),
      ),
    );
  }
}

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

  const AppButtonWidget({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.style = AppButtonStyle.filled,
    this.outlineColor,
  });

  @override
  State<AppButtonWidget> createState() => _AppButtonWidgetState();
}

class _AppButtonWidgetState extends State<AppButtonWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: widget.style == AppButtonStyle.filled
              ? _buildFilledButton()
              : _buildOutlinedButton(),
        ),
      ),
    );
  }

  // Style 1: Filled (màu cam đặc)
  Widget _buildFilledButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFAD35),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          widget.buttonText,
          style: GoogleFonts.beVietnamPro(
            fontSize: 18,
            fontWeight: FontWeight.w500,
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
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          widget.buttonText,
          style: GoogleFonts.beVietnamPro(color: color, fontSize: 15),
        ),
      ),
    );
  }
}

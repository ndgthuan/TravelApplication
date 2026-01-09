import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionButton extends StatefulWidget {
  final String buttonName;
  final Color color;
  final VoidCallback? onTap;
  const ActionButton({
    super.key,
    required this.buttonName,
    required this.color,
    this.onTap,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isClick = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isClick = true),
      onTapUp: (_) => setState(() => _isClick = false),
      onTapCancel: () => setState(() => _isClick = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isClick ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: widget.color),
            borderRadius: BorderRadius.circular(20),
          ),

          // Tên của hoạt động
          child: Center(
            child: Text(
              widget.buttonName,
              style: GoogleFonts.beVietnamPro(
                color: widget.color,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

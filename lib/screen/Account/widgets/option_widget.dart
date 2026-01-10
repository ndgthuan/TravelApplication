import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionWidget extends StatefulWidget {
  final IconData optionIcon;
  final String optionText;
  final VoidCallback? onTap;
  const OptionWidget({
    super.key,
    required this.optionText,
    required this.optionIcon,
    this.onTap,
  });

  @override
  State<OptionWidget> createState() => _OptionWidgetState();
}

class _OptionWidgetState extends State<OptionWidget> {
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
        child: SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // icon danh mục
                  Icon(widget.optionIcon, color: Colors.grey, size: 25),
                  const SizedBox(width: 5),
                  // Tên danh mục
                  Text(
                    widget.optionText,
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              // Icon mũi tên
              Icon(Icons.keyboard_arrow_right_outlined, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExtensionWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  const ExtensionWidget({super.key, required this.icon, required this.title});

  @override
  State<ExtensionWidget> createState() => _ExtensionWidgetState();
}

class _ExtensionWidgetState extends State<ExtensionWidget> {
  bool _isClick = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isClick = true),
      onTapUp: (_) => setState(() => _isClick = false),
      onTapCancel: () => setState(() => _isClick = false),
      child: AnimatedScale(
        scale: _isClick ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon của tiện ích đó
              Icon(widget.icon, color: Color(0xFFFFAD35), size: 30),
              const SizedBox(height: 5),

              // Tên của hoạt động
              Text(
                widget.title,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

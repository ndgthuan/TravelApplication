import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class TranslateButtonWidget extends StatefulWidget {
  final String languageCode;
  final String languageName;
  final String flag;
  final VoidCallback? onTap;
  const TranslateButtonWidget({
    super.key,
    required this.flag,
    required this.languageCode,
    required this.languageName,
    this.onTap,
  });

  @override
  State<TranslateButtonWidget> createState() => _TranslateButtonWidgetState();
}

class _TranslateButtonWidgetState extends State<TranslateButtonWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFFFAD35)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text bên trong nút
                  Flexible(
                    child: Text(
                      '${widget.flag} ${widget.languageName}',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  Icon(CupertinoIcons.chevron_down, color: Color(0xFFFFAD35)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

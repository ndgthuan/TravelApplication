import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppHeaderWidget extends StatelessWidget {
  final String title;
  final double fontSize;
  final Widget? trailing;
  const AppHeaderWidget({
    super.key,
    required this.title,
    this.fontSize = 32,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.beVietnamPro(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

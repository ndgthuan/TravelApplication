import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderTitleWidget extends StatelessWidget {
  final String titleText;
  final double fontSize;
  const HeaderTitleWidget({
    super.key,
    required this.titleText,
    this.fontSize = 23,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        titleText,
        style: GoogleFonts.beVietnamPro(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

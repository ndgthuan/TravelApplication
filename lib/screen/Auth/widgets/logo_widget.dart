import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Hình tròn
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E1E), // Màu sáng hơn
              Color(0xFF1A1A1A), // Màu tối
            ],
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            'lib/assets/images/dark_logo.png',
            width: 170,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class TitleLogo extends StatelessWidget {
  const TitleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return // Chữ Welcome!
    Align(
      alignment: Alignment.center,
      child: Text(
        "general.welcome".tr(),
        style: GoogleFonts.beVietnamPro(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class SubtitleLogo extends StatelessWidget {
  final String subtitleText;
  const SubtitleLogo({super.key, required this.subtitleText});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        subtitleText,
        style: GoogleFonts.beVietnamPro(
          fontSize: 18,
          fontWeight: FontWeight.w200,
          color: Colors.white,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF1C1C1D),
        centerTitle: true,
        title: Text(
          'World Clock',
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserGuideWidget extends StatefulWidget {
  final String titleText;
  const UserGuideWidget({super.key, required this.titleText});

  @override
  State<UserGuideWidget> createState() => _UserGuideWidgetState();
}

class _UserGuideWidgetState extends State<UserGuideWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Color(0xFF1C1C1D),
          borderRadius: BorderRadius.circular(15),
        ),

        // Tên của hoạt động
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tên tiêu đề
              Text(
                widget.titleText,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),

              // Icon mũi tên
              Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}

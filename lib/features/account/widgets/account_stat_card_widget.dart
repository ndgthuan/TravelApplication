import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountStatCardWidget extends StatelessWidget {
  final String title;
  final int number;
  final IconData icon;
  const AccountStatCardWidget({
    super.key,
    required this.title,
    required this.number,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Số lượng hoạt động đã làm
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(icon, color: Color(0xFFFF6D00)),
              const SizedBox(width: 3),
              Text(
                number.toString(),
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ],
          ),
          // Tên của hoạt động
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

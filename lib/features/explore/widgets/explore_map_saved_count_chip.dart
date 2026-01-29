// Đếm số lượng destination đã lưu
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreMapSavedCountChip extends StatelessWidget {
  final int savedCount;

  const ExploreMapSavedCountChip({super.key, required this.savedCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 15, left: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.location_fill, color: Color(0xFFFFAD35)),
            const SizedBox(width: 10),
            Text(
              '$savedCount Saved Places',
              style: GoogleFonts.beVietnamPro(
                color: const Color(0xFFFFAD35),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Hàng hai ô để trả về giờ và ngày, tap mở bottom sheet tương ứng
class ActivityTimeDateRowWidget extends StatelessWidget {
  const ActivityTimeDateRowWidget({
    super.key,
    required this.time,
    required this.date,
    required this.onTapTime,
    required this.onTapDate,
  });

  final TimeOfDay time;
  final DateTime date;
  final VoidCallback onTapTime;
  final VoidCallback onTapDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTapTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF1C1C1D),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFF333333)),
                ),
                child: Row(
                  children: [
                    Text(
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      CupertinoIcons.chevron_down,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onTapDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF1C1C1D),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFF333333)),
                ),
                child: Row(
                  children: [
                    Text(
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      CupertinoIcons.chevron_down,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

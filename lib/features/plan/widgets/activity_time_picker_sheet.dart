import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Bottom sheet chọn giờ
// initialTime giờ ban đầu, onConfirm trả về giờ đã chọn
Future<void> showActivityTimePickerSheet(
  BuildContext context, {
  required TimeOfDay initialTime,
  required ValueChanged<TimeOfDay> onConfirm,
}) async {
  TimeOfDay temp = initialTime;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: 320,
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.beVietnamPro(color: Colors.white70),
                  ),
                ),
                Text(
                  'Chọn giờ',
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onConfirm(temp);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Xong',
                    style: GoogleFonts.beVietnamPro(color: Color(0xFFFF6D00)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: Brightness.dark,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: GoogleFonts.beVietnamPro(
                    color: Colors.white,
                    fontSize: 21,
                  ),
                ),
              ),
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: Duration(
                  hours: initialTime.hour,
                  minutes: initialTime.minute,
                ),
                onTimerDurationChanged: (Duration d) {
                  temp = TimeOfDay(
                    hour: d.inHours % 24,
                    minute: d.inMinutes % 60,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

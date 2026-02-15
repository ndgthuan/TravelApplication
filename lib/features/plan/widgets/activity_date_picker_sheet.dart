import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Bottom sheet chọn ngày
// InitialDate ngày ban đầu, onConfirm trả về ngày đã chọn
// minimumDate và maximumDate để giới hạn khoảng chọn
Future<void> showActivityDatePickerSheet(
  BuildContext context, {
  required DateTime initialDate,
  required ValueChanged<DateTime> onConfirm,
  DateTime? minimumDate,
  DateTime? maximumDate,
}) async {
  DateTime temp = initialDate;
  final min = minimumDate ?? DateTime(2020);
  final max = maximumDate ?? DateTime(2030);
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
                  'Chọn ngày',
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
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDate,
                minimumDate: min,
                maximumDate: max,
                onDateTimeChanged: (DateTime d) => temp = d,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

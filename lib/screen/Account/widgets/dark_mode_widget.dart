import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkModeWidget extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool)? onChanged;
  const DarkModeWidget({
    super.key,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // icon danh mục
              Icon(Icons.dark_mode_outlined, color: Colors.grey, size: 25),
              const SizedBox(width: 5),
              // Tên danh mục
              Text(
                'account.dark_mode'.tr(),
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          // Icon mũi tên
          // Switch Dark Mode
          Switch(
            value: isDarkMode,
            onChanged: onChanged,
            activeThumbColor: Colors.white, // Màu nút tròn khi BẬT
            activeTrackColor: Color(0xFFFFAD35), // Màu nền khi BẬT (cam)
            inactiveThumbColor: Colors.white, // Màu nút tròn khi TẮT
            inactiveTrackColor: Colors.grey.shade600, // Màu nền khi TẮT
          ),
        ],
      ),
    );
  }
}

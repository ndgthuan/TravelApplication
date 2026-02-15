import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Chip chọn các loại hoạt động
// Parent truyền [isSelected] và [onTap]; khi tap thì parent setState gán type tương ứng.
class BuildActivityTypeChip extends StatelessWidget {
  final String label;
  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  const BuildActivityTypeChip({
    super.key,
    required this.label,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Color(0xFFFF6D00).withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Color(0xFFFF6D00)
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            label,
            style: GoogleFonts.beVietnamPro(color: Colors.white, fontSize: 17),
          ),
        ),
      ),
    );
  }
}

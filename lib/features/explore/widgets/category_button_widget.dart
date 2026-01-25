// Tạo widget riêng cho mỗi nút danh mục, có thể bấm được
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryButtonWidget extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButtonWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFFFAD35) : Colors.white,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFAD35) : Colors.grey,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.beVietnamPro(
                color: isSelected ? const Color(0xFFFFAD35) : Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

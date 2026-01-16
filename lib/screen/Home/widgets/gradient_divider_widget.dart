import 'package:flutter/material.dart';

class GradientDividerWidget extends StatelessWidget {
  const GradientDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent, // Mờ bên trái
            Colors.white, // Đậm ở giữa
            Colors.transparent, // Mờ bên phải
          ],
          stops: [0.0, 0.5, 1.0], // Điểm chuyển màu
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HeartButton extends StatefulWidget {
  const HeartButton({super.key});

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  bool isPressed = false;
  bool isFavourite = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xFFFFAD35),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        onTap: () {
          setState(() {
            isFavourite = !isFavourite;
          });
        },
        child: AnimatedScale(
          scale: isPressed ? 0.9 : 1.0,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: Icon(
            isFavourite ? Icons.favorite : Icons.favorite_border,
            color: Colors.black,
            size: 24,
          ),
        ),
      ),
    );
  }
}

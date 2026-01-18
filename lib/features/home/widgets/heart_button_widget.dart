import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HeartButtonWidget extends StatefulWidget {
  const HeartButtonWidget({super.key});

  @override
  State<HeartButtonWidget> createState() => _HeartButtonWidgetState();
}

class _HeartButtonWidgetState extends State<HeartButtonWidget> {
  bool isPressed = false;
  bool isFavourite = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
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
            isFavourite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: isFavourite ? Color(0xFFFFAD35) : Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

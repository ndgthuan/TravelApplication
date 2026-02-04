import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HeartButtonWidget extends StatefulWidget {
  final bool isSaved;
  final VoidCallback? onTap;

  const HeartButtonWidget({super.key, required this.isSaved, this.onTap});

  @override
  State<HeartButtonWidget> createState() => _HeartButtonWidgetState();
}

class _HeartButtonWidgetState extends State<HeartButtonWidget> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 3,
        ),
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: isPressed ? 0.9 : 1.0,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: Icon(
            widget.isSaved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: widget.isSaved ? Color(0xFFFFAD35) : Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

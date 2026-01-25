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

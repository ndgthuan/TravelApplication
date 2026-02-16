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
        onTap: widget.onTap,
        child: Icon(
          widget.isSaved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          color: widget.isSaved ? Color(0xFFFFAD35) : Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SocialButtonWidget extends StatefulWidget {
  final bool isPressed;
  final String imagePath;
  final VoidCallback onTap;
  const SocialButtonWidget({
    super.key,
    required this.isPressed,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<SocialButtonWidget> createState() => _SocialButtonWidgetState();
}

class _SocialButtonWidgetState extends State<SocialButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Image.asset(widget.imagePath, width: 70, height: 70),
        ),
      ),
    );
  }
}

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
  late bool isPressed;
  @override
  void initState() {
    super.initState();
    isPressed = widget.isPressed;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),

        // Thêm phương thức đăng nhập bằng google
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: isPressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
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
      ),
    );
  }
}

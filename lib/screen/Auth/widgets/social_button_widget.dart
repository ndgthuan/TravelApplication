import 'package:flutter/material.dart';
import 'package:travel_app/shared/widgets/navigation_widget.dart';

class SocialButtonWidget extends StatefulWidget {
  final bool isPressed;
  final String imagePath;
  final Future<dynamic> Function() authFunction;
  const SocialButtonWidget({
    super.key,
    required this.isPressed,
    required this.imagePath,
    required this.authFunction,
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
        onTap: () async {
          final result = await widget.authFunction();
          if (result != null && context.mounted) {
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (context) => BottomNavigation()),
            );
          }
        },
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:travel_app/screen/Plan/screens/plan_screen.dart';
import 'package:animations/animations.dart';

class SocialIconButton extends StatefulWidget {
  final bool isPressed;
  final String imagePath;
  final Future<dynamic> Function() authFunction;
  const SocialIconButton({
    super.key,
    required this.isPressed,
    required this.imagePath,
    required this.authFunction,
  });

  @override
  State<SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<SocialIconButton> {
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
              MaterialPageRoute(builder: (context) => PlanScreen()),
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

class BottomSwitchPageButton extends StatelessWidget {
  final String formerText;
  final String latterText;
  final Widget destinationScreen;
  const BottomSwitchPageButton({
    super.key,
    required this.formerText,
    required this.latterText,
    required this.destinationScreen,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.nunito(fontSize: 18, color: Colors.white70),

        // Tạo text span hộp để chứa các text chung
        children: <TextSpan>[
          TextSpan(text: formerText),
          TextSpan(
            text: latterText,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Khi nhấn vào sign up sẽ chuyển sang trang Register
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    // Thời gian animation
                    transitionDuration: const Duration(seconds: 1),
                    reverseTransitionDuration: const Duration(
                      milliseconds: 800,
                    ),

                    // Xây dựng transition
                    pageBuilder:
                        // Callback transition
                        (context, animation, secondaryAnimation) {
                          return destinationScreen;
                        },
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return SharedAxisTransition(
                            fillColor: Colors.grey,
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                  ),
                );
              },
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatefulWidget {
  final bool isPress;
  final String buttonText;
  final VoidCallback onTap;
  const ActionButton({
    super.key,
    required this.isPress,
    required this.buttonText,
    required this.onTap,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  late bool isPress;

  @override
  void initState() {
    super.initState();
    isPress = widget.isPress;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPress = true),
      onTapUp: (_) => setState(() => isPress = false),
      onTapCancel: () => setState(() => isPress = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: isPress ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 25),
            decoration: BoxDecoration(
              color: Colors.white,

              // Thêm hiệu ứng box shadow làm nổi bật nút register
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.buttonText,
                style: GoogleFonts.nunito(color: Colors.black, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

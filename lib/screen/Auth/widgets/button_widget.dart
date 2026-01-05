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
        style: GoogleFonts.beVietnamPro(fontSize: 18, color: Colors.white70),

        // Tạo text span hộp để chứa các text chung
        children: <TextSpan>[
          TextSpan(text: formerText),
          TextSpan(
            text: latterText,
            style: GoogleFonts.beVietnamPro(
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
                            fillColor: Colors.grey.shade900,
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

// Hàm gọi các button như login, register
class ActionButton extends StatefulWidget {
  final String buttonText;
  final VoidCallback onTap;
  const ActionButton({
    super.key,
    required this.buttonText,
    required this.onTap,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFAD35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.buttonText,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

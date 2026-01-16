import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:animations/animations.dart';

class AuthSwitchButtonWidget extends StatelessWidget {
  final String formerText;
  final String latterText;
  final Widget destinationScreen;
  const AuthSwitchButtonWidget({
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

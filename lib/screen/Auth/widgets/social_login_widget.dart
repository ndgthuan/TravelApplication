import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/screen/Auth/widgets/social_button_widget.dart';
import '../services/auth_service.dart';

class SocialLoginWidget extends StatelessWidget {
  final bool isGooglePressed;
  final bool isFacebookPressed;

  // Tạo instance của AuthService
  final AuthService _authService = AuthService();

  SocialLoginWidget({
    super.key,
    required this.isGooglePressed,
    required this.isFacebookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              // Vẽ thanh gạch ngang
              Expanded(child: Divider(color: Colors.white, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "auth.or_login_with".tr(),
                  style: GoogleFonts.beVietnamPro(
                    color: Color(0xFF888888),
                    fontSize: 13,
                  ),
                ),
              ),

              Expanded(child: Divider(color: Colors.white, thickness: 1)),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Dòng logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Logo
            SocialButtonWidget(
              isPressed: isGooglePressed,
              imagePath: "lib/assets/images/google_logo.png",
              authFunction: _authService.signInWithGoogle,
            ),

            // Facebook Logo
            SocialButtonWidget(
              isPressed: isFacebookPressed,
              imagePath: 'lib/assets/images/facebook_logo.png',
              authFunction: _authService.signInWithFacebook,
            ),
          ],
        ),
      ],
    );
  }
}

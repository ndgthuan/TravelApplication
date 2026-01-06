import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import '../../Auth/screens/login_screen.dart';

// Hàm khởi tạo để truyền tham số nhanh hơn
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() {
    return _StartScreenState();
  }
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  // Biến để track trạng thái nhấn nút
  bool _isPressed = false;

  // Animation controllers
  late AnimationController _buttonController;

  // Animations
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Controller cho animation slide từ dưới lên
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Slide từ dưới lên (offset y: 1 -> 0)
    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Fade in
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    // Bắt đầu animation
    _buttonController.forward();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF000000)),
        // Get start button
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content với animation float từ dưới lên
            SlideTransition(
              position: _buttonSlideAnimation,
              child: FadeTransition(
                opacity: _buttonFadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 120),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          "Plan Your Day",
                          style: GoogleFonts.pacifico(
                            color: Colors.white,
                            fontSize: 44,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          height: 448,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'lib/assets/images/schedule_icon.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, 10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Simple tools to manage your daily schedule effectively.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontSize: 19,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Nút Get started
            SlideTransition(
              position: _buttonSlideAnimation,
              child: FadeTransition(
                opacity: _buttonFadeAnimation,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    // Phương thức chuyển qua trang đăng nhập
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _isPressed = true),
                      onTapUp: (_) => setState(() => _isPressed = false),
                      onTapCancel: () => setState(() => _isPressed = false),
                      child: Center(
                        child: AnimatedScale(
                          scale: _isPressed ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeInOut,
                          child: SizedBox(
                            width: 350,
                            height: 80,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(
                                      seconds: 1,
                                    ),
                                    reverseTransitionDuration: const Duration(
                                      milliseconds: 800,
                                    ),
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) {
                                          return const LoginScreen();
                                        },
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          return SharedAxisTransition(
                                            fillColor: Colors.grey.shade900,
                                            animation: animation,
                                            secondaryAnimation:
                                                secondaryAnimation,
                                            transitionType:
                                                SharedAxisTransitionType
                                                    .horizontal,
                                            child: child,
                                          );
                                        },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFAD33),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Get started",
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

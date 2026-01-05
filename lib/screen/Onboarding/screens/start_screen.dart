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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white70, // Màu xám bạc (#bdc3c7)
              Colors.black, // Màu xanh đen (#2c3e50)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                        decoration: BoxDecoration(
                          // Shadow để tạo chiều sâu
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          "Plan Your Day",
                          style: GoogleFonts.pacifico(
                            color: Colors.white,
                            fontSize: 44,
                          ),
                        ),
                      ),
                      Container(
                        width: 448,
                        height: 448,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'lib/assets/images/schedule_icon.png',
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                179,
                                148,
                                144,
                                144,
                              ).withValues(alpha: 0.4),
                              blurRadius: 60,
                            ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, -35),
                        child: Text(
                          "Simple tools to manage your daily schedule effectively.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
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
                      onTap: () {
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
                                    fillColor: Colors.grey,
                                    animation: animation,
                                    secondaryAnimation: secondaryAnimation,
                                    transitionType:
                                        SharedAxisTransitionType.horizontal,
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                      // Animation scale khi nhấn
                      child: Center(
                        child: AnimatedScale(
                          scale: _isPressed ? 0.9 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInOut,
                          child: Container(
                            width: 350,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.white,

                              // Shadow để tạo chiều sâu
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Get started",
                                style: GoogleFonts.nunito(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
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

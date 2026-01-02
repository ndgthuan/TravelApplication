import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

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
  late AnimationController _orionController;
  late AnimationController _buttonController;

  // Animations
  late Animation<Offset> _orionSlideAnimation;
  late Animation<double> _orionFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Controller cho ORION text - float từ dưới lên
    _orionController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Controller cho nút - slide từ phải sang trái
    _buttonController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // ORION slide từ dưới lên (offset y: 1 -> 0)
    _orionSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: _orionController, curve: Curves.easeOutCubic),
        );

    // ORION fade in
    _orionFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _orionController, curve: Curves.easeOut));

    // Button slide từ phải sang trái (offset x: 1 -> 0)
    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Button fade in
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    // Bắt đầu animations với delay
    _orionController.forward();
    Future.delayed(const Duration(seconds: 1), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _orionController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Images
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/start_screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        // Get start button
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ORION word với animation float từ dưới lên
            SlideTransition(
              position: _orionSlideAnimation,
              child: FadeTransition(
                opacity: _orionFadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(left: 75, top: 120),
                  child: Row(
                    children: [
                      // Icon la bàn
                      const Icon(Icons.explore, color: Colors.white, size: 90),
                      // Chữ orion
                      Text(
                        "RION",
                        style: GoogleFonts.abrilFatface(
                          fontSize: 80,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Nút bấm tròn với animation slide từ phải sang trái
            SlideTransition(
              position: _buttonSlideAnimation,
              child: FadeTransition(
                opacity: _buttonFadeAnimation,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50, right: 30),
                    // Phương thức chuyển qua trang đăng nhập
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _isPressed = true),
                      onTapUp: (_) => setState(() => _isPressed = false),
                      onTapCancel: () => setState(() => _isPressed = false),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      // Animation scale khi nhấn
                      child: AnimatedScale(
                        scale: _isPressed ? 0.9 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            // Gradient xanh than sang xanh lam
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromRGBO(22, 42, 60, 1), // Màu xanh than
                                Color.fromRGBO(60, 110, 130, 1), // Màu xanh lam
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),

                            // Vẽ hình tròn
                            shape: BoxShape.circle,
                            // Shadow để tạo chiều sâu
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          // Icon mũi tên
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 30,
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

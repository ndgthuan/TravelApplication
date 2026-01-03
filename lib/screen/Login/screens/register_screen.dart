import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:travel_app/screen/Plan/screens/plan_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isShowingPassword = true;
  bool _isShowingReenterPassword = true;
  bool _isRegisterPressed = false;

  // Tạo các phương thức đăng ký
  String email = "", password = "", username = "", reenterpassword = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reenterpasswordController = TextEditingController();

  // Tạo form key để bọc xung quanh các hộp đăng ký
  final _formkey = GlobalKey<FormState>();

  // Tạo phương thức đăng ký
  registration() async {
    if (nameController.text != "" &&
        emailController.text != "" &&
        reenterpasswordController.text == passwordController.text) {
      email = emailController.text;
      password = passwordController.text;
      try {
        // Khởi tạo password và email
        // ignore: unused_local_variable
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        log('REGISTRATION COMPLETED');
        // CHuyển trang
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PlanScreen()),
        );
      } on FirebaseException catch (e) {
        if (e.code == 'weak-password') {
          log('WEAK PASSWORD');
        } else if (e.code == 'email-already-in-use') {
          log('EMAIL EXISTED');
        } else if (e.code == 'invalid-email') {
          log('INVALID EMAIL');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/register_screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Chữ Welcome
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Welcome!",
                  style: GoogleFonts.abrilFatface(
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  // Tạo phương thức đăng ký
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      log("NAME HAS NOT ENTERED YET");
                      return "NAME HAS NOT ENTERED YET";
                    }
                    return null;
                  },
                  controller: nameController,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Username",
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.black.withValues(alpha: 0.3),
                    filled: true,

                    // Tạo icon nằm ở trước hộp nhập
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Hộp nhập email
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  // Tạo phương thức đăng ký
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      log("EMAIL HAS NOT ENTERED YET");
                      return "EMAIL HAS NOT ENTERED YET";
                    }
                    return null;
                  },
                  controller: emailController,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.black.withValues(alpha: 0.3),
                    filled: true,

                    // Tạo icon nằm ở trước hộp nhập
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Hộp nhập password
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  // Tạo phương thức đăng ký
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      log("PASSWORD HAS NOT ENTERED YET");
                      return "PASSWORD HAS NOT ENTERED YET";
                    }
                    return null;
                  },
                  controller: passwordController,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  obscureText: _isShowingPassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.black.withValues(alpha: 0.3),
                    filled: true,

                    // Tạo icon nằm ở trước hộp nhập
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white),

                    // Tạo icon con mắt ở sau hộp nhập
                    suffixIcon: IconButton(
                      // Nếu ấn vào thì chuyển sang icon còn lại
                      onPressed: () => setState(() {
                        _isShowingPassword = !_isShowingPassword;
                      }),
                      icon: Icon(
                        _isShowingPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  // Tạo phương thức đăng ký
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      log("REENTER PASSWORD HAS NOT ENTERED YET");
                      return "REENTER PASSWORD HAS NOT ENTERED YET";
                    }
                    if (value != passwordController.text) {
                      log("REENTER PASSWORD IS NOT CORRECT");
                      return "REENTER PASSWORD IS NOT CORRECT";
                    }
                    return null;
                  },
                  controller: reenterpasswordController,
                  obscureText: _isShowingReenterPassword,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Reenter password",
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.black.withValues(alpha: 0.3),
                    filled: true,

                    // Tạo icon nằm ở trước hộp nhập
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white),

                    // Tạo icon con mắt ở sau hộp nhập
                    suffixIcon: IconButton(
                      // Nếu ấn vào thì chuyển sang icon còn lại
                      onPressed: () => setState(() {
                        _isShowingReenterPassword = !_isShowingReenterPassword;
                      }),
                      icon: Icon(
                        _isShowingReenterPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Thanh đăng nhập
              GestureDetector(
                onTapDown: (_) => setState(() => _isRegisterPressed = true),
                onTapUp: (_) => setState(() => _isRegisterPressed = false),
                onTapCancel: () => setState(() => _isRegisterPressed = false),
                onTap: () {
                  // Tạo form đăng ký
                  if (_formkey.currentState!.validate()) {
                    setState(() {
                      username = nameController.text;
                      email = emailController.text;
                      password = passwordController.text;
                    });
                    registration();
                  }
                  log('ENAIL REGISTER');
                },
                child: AnimatedScale(
                  scale: _isRegisterPressed ? 0.9 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 15,
                      left: 170,
                      right: 170,
                      bottom: 15,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.white,
                          Color(
                            0xFFE0E0E0,
                          ), // Xám cực nhạt Hơi tím nhẹ (để hợp với dải ngân hà)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      // Thêm hiệu ứng box shadow làm nổi bật nút login
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "Register",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dòng signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),

                      // Tạo text span hộp để chứa các text chung
                      children: <TextSpan>[
                        TextSpan(text: "Already have an account?"),
                        TextSpan(
                          text: ' Log in',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                              log("LOGIN");
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

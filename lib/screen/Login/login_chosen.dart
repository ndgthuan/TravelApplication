import 'package:flutter/material.dart';

class LoginChosenScreen extends StatelessWidget {
  const LoginChosenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/login_screen.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
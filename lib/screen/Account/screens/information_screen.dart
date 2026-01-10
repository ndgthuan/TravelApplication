import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/screen/Account/widgets/profile_field_widget.dart';
import 'package:travel_app/shared/widgets/action_button_widget.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  bool isClick = false;
  final TextEditingController nameController = TextEditingController(
    text: "Nguyễn Dương Gia Thuận",
  );
  final TextEditingController emailController = TextEditingController(
    text: "giathuannguyenduong5000@gmail.com",
  );
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Personal Information',
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar Section
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Align(
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFFAD35),
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: AssetImage(
                            'lib/assets/images/google_logo.png',
                          ), // Placeholder or User Avatar
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => isClick = true),
                        onTapUp: (_) => setState(() => isClick = false),
                        onTapCancel: () => setState(() => isClick = false),
                        child: AnimatedScale(
                          scale: isClick ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeInOut,
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFAD35),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ProfileFieldWidget(
              icon: Icons.person_outline,
              label: 'Username',
              hintText: 'Enter your name',
              controller: nameController,
            ),

            ProfileFieldWidget(
              icon: Icons.mail_outline,
              label: 'Email',
              hintText: 'Enter your email',
              controller: emailController,
              readOnly: true,
            ),

            ProfileFieldWidget(
              icon: Icons.phone_outlined,
              label: 'Phone',
              hintText: 'Enter your phone number',
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),

            ProfileFieldWidget(
              icon: Icons.calendar_month_outlined,
              label: 'Date of birth',
              hintText: "DD/MM/YYYY",
              controller: dobController,
            ),

            ProfileFieldWidget(
              icon: Icons.push_pin_outlined,
              label: 'Address',
              hintText: 'Enter your address',
              controller: addressController,
            ),
            const SizedBox(height: 30),

            // Save Button
            ActionButtonWidget(
              buttonText: "Save Changes",
              onTap: () {
                // Handle Save Logic
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

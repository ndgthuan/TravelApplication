import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/screen/Support/screens/contact_support_screen.dart';
import 'package:travel_app/screen/Support/screens/faq_screen.dart';
import 'package:travel_app/screen/Support/screens/terms_privacy_screen.dart';
import 'package:travel_app/screen/Support/screens/user_guide_screen.dart';
import 'package:travel_app/screen/Support/widgets/help_support_widget.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  bool isClick = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1C1D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'account.help_support'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            HelpSupportWidget(
              icon: Icons.help,
              taskName: 'account.faqs'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FaqScreen()),
                );
              },
            ),
            HelpSupportWidget(
              icon: Icons.message_outlined,
              taskName: 'account.contact_support'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactSupportScreen(),
                  ),
                );
              },
            ),
            HelpSupportWidget(
              icon: Icons.menu_book_sharp,
              taskName: 'account.user_guide'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserGuideScreen()),
                );
              },
            ),
            HelpSupportWidget(
              icon: Icons.insert_drive_file,
              taskName: 'account.terms_privacy'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TermsPrivacyScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/features/Support/screens/contact_support_screen.dart';
import 'package:travel_app/features/Support/screens/faq_screen.dart';
import 'package:travel_app/features/Support/screens/terms_privacy_screen.dart';
import 'package:travel_app/features/Support/screens/user_guide_screen.dart';
import 'package:travel_app/features/Support/widgets/support_option_widget.dart';

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
            SupportOptionWidget(
              icon: CupertinoIcons.question_circle,
              taskName: 'account.faqs'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FaqScreen()),
                );
              },
            ),
            SupportOptionWidget(
              icon: CupertinoIcons.chat_bubble,
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
            SupportOptionWidget(
              icon: CupertinoIcons.book,
              taskName: 'account.user_guide'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserGuideScreen()),
                );
              },
            ),
            SupportOptionWidget(
              icon: CupertinoIcons.doc,
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

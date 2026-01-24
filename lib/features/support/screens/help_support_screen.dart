import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/features/support/screens/contact_support_screen.dart';
import 'package:travel_app/features/support/screens/faq_screen.dart';
import 'package:travel_app/features/support/screens/terms_privacy_screen.dart';
import 'package:travel_app/features/support/screens/user_guide_screen.dart';
import 'package:travel_app/features/support/widgets/support_option_widget.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';

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
      appBar: AppBarWidget(title: 'account.help_support'.tr()),
      backgroundColor: const Color(0xFF000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
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

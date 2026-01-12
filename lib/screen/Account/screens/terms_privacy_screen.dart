import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/screen/Account/widgets/terms_privacy_stat_widget.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'account.terms_privacy'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            TermsPrivacyStatWidget(
              titleText: 'account.terms_of_service_title'.tr(),
              paragraphText: 'account.terms_of_service_body'.tr(),
            ),
            TermsPrivacyStatWidget(
              titleText: 'account.privacy_policy_title'.tr(),
              paragraphText: 'account.privacy_policy_body'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_app/screen/Account/widgets/terms_privacy_stat_widget.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  // Thêm đường dẫn cho button
  static const String _termsOfServiceUrl =
      'https://docs.google.com/document/d/1cqyo3D39_65RAtekklclsVaZuYHMaTKVLxFg_8Je7IM/edit?usp=sharing';
  static const String _privacyPolicyUrl =
      'https://docs.google.com/document/d/1Mqw5r5i2s23FIRsJZ3m84kwXCi1TK7UVPQ4Tp7qQjBE/edit?usp=sharing';

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
              onTap: () => _launchUrl(_termsOfServiceUrl),
            ),
            TermsPrivacyStatWidget(
              titleText: 'account.privacy_policy_title'.tr(),
              paragraphText: 'account.privacy_policy_body'.tr(),
              onTap: () => _launchUrl(_privacyPolicyUrl),
            ),
          ],
        ),
      ),
    );
  }
}

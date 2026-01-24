import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_app/features/support/widgets/terms_card_widget.dart';

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
      appBar: AppBarWidget(title: 'account.terms_privacy'.tr()),
      backgroundColor: const Color(0xFF000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            TermsCardWidget(
              titleText: 'account.terms_of_service_title'.tr(),
              paragraphText: 'account.terms_of_service_body'.tr(),
              onTap: () => _launchUrl(_termsOfServiceUrl),
            ),
            TermsCardWidget(
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

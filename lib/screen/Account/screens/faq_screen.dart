import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/screen/Account/widgets/faq_stat_widget.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'account.faqs'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            FaqStatWidget(
              titleText: 'account.faq_create_plan_title'.tr(),
              paragraphText: 'account.faq_create_plan_body'.tr(),
            ),

            FaqStatWidget(
              titleText: 'account.faq_change_currency_title'.tr(),
              paragraphText: 'account.faq_change_currency_body'.tr(),
            ),
            FaqStatWidget(
              titleText: 'account.faq_report_problem_title'.tr(),
              paragraphText: 'account.faq_report_problem_body'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

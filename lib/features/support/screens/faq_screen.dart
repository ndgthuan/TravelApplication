import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/features/support/widgets/faq_card_widget.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'account.faqs'.tr()),
      backgroundColor: const Color(0xFF000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FaqCardWidget(
              titleText: 'account.faq_create_plan_title'.tr(),
              paragraphText: 'account.faq_create_plan_body'.tr(),
            ),

            FaqCardWidget(
              titleText: 'account.faq_change_currency_title'.tr(),
              paragraphText: 'account.faq_change_currency_body'.tr(),
            ),
            FaqCardWidget(
              titleText: 'account.faq_report_problem_title'.tr(),
              paragraphText: 'account.faq_report_problem_body'.tr(),
            ),
            FaqCardWidget(
              titleText: 'account.faq_edit_profile_title'.tr(),
              paragraphText: 'account.faq_edit_profile_body'.tr(),
            ),
            FaqCardWidget(
              titleText: 'account.faq_notifications_title'.tr(),
              paragraphText: 'account.faq_notifications_body'.tr(),
            ),
            FaqCardWidget(
              titleText: 'account.faq_offline_mode_title'.tr(),
              paragraphText: 'account.faq_offline_mode_body'.tr(),
            ),
            FaqCardWidget(
              titleText: 'account.faq_sync_data_title'.tr(),
              paragraphText: 'account.faq_sync_data_body'.tr(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

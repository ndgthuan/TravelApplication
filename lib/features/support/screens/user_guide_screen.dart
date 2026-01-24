import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/features/support/widgets/user_guide_widget.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'account.user_guide'.tr()),
      backgroundColor: const Color(0xFF000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserGuideWidget(
              titleText: 'account.guide_getting_started'.tr(),
              contentText: 'account.guide_getting_started_body'.tr(),
            ),
            UserGuideWidget(
              titleText: 'account.guide_planning_trip'.tr(),
              contentText: 'account.guide_planning_trip_body'.tr(),
            ),
            UserGuideWidget(
              titleText: 'account.guide_managing_account'.tr(),
              contentText: 'account.guide_managing_account_body'.tr(),
            ),
            UserGuideWidget(
              titleText: 'account.guide_using_utilities'.tr(),
              contentText: 'account.guide_using_utilities_body'.tr(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

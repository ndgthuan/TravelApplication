import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/features/Support/widgets/user_guide_widget.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1C1D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'account.user_guide'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
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

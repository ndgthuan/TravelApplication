import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/features/plan/widgets/add_plan_sheet.dart';

class BuildPlanCardWidget extends StatelessWidget {
  const BuildPlanCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showAddPlanModal(context),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/add_plan_image.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 33,
              height: 33,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E1E1D),
              ),
              child: Icon(Icons.add, color: Color(0xFFFFAD35), size: 30),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'plan.plan_with_squad'.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//=====================================================================//
//                          HELPER FUNCTION                            //
//=====================================================================//
// Helper gọi add plan sheet
void _showAddPlanModal(BuildContext context) {
  final height = MediaQuery.sizeOf(context).height;
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, _) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return Stack(
        children: [
          // Phần blur + tối phía trên (tap để đóng)
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: AnimatedOpacity(
              opacity: curve.value,
              duration: const Duration(milliseconds: 300),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black38),
              ),
            ),
          ),
          // Sheet 80% từ dưới lên
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curve),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: SizedBox(height: height * 0.9, child: AddPlanSheet()),
              ),
            ),
          ),
        ],
      );
    },
  );
}

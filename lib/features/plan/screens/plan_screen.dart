import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/features/plan/viewmodels/plan_view_model.dart';
import 'package:travel_app/features/plan/widgets/build_plan_card_widget.dart';
import 'package:travel_app/features/plan/widgets/ongoing_plan_card_widget.dart';
import 'package:travel_app/features/plan/widgets/upcoming_plan_card_widget.dart';
import 'package:travel_app/shared/widgets/app_header_widget.dart';
import 'package:travel_app/shared/widgets/header_title_widget.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanViewModel>().loadPlans();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _ = context.locale;
    // Bắt đầu gọi backend
    final viewModel = context.watch<PlanViewModel>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFAD35)),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppHeaderWidget(
                      title: 'navigation.plan'.tr(),
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: Icon(
                            Icons.insights,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),

                    // Error banner
                    if (viewModel.error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            viewModel.error!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),

                    HeaderTitleWidget(titleText: 'plan.ongoing'.tr()),

                    // Ongoing plans carousel
                    if (viewModel.ongoingPlans.isNotEmpty) ...[
                      SizedBox(
                        height: 370,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: viewModel.ongoingPlans.length,
                          onPageChanged: (i) =>
                              setState(() => _currentPage = i),
                          itemBuilder: (context, index) {
                            final plan = viewModel.ongoingPlans[index];
                            return GestureDetector(
                              onLongPress: () => _confirmDeletePlan(plan),
                              child: OngoingPlanCardWidget(plan: plan),
                            );
                          },
                        ),
                      ),
                      // Dot indicator (chỉ hiện khi > 1 plan)
                      if (viewModel.ongoingPlans.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              viewModel.ongoingPlans.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: _currentPage == i ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == i
                                      ? const Color(0xFFFFAD35)
                                      : Colors.white24,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'plan.no_ongoing_trips'.tr(),
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),

                    HeaderTitleWidget(titleText: 'plan.upcoming'.tr()),

                    // Horizontal list cards
                    SizedBox(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        children: [
                          // Card tạo plan mới
                          BuildPlanCardWidget(),
                          SizedBox(width: 10),
                          // Các upcoming plans từ ViewModel
                          for (final plan in viewModel.upcomingPlans) ...[
                            GestureDetector(
                              onLongPress: () => _confirmDeletePlan(plan),
                              child: UpcomingPlanCardWidget(plan: plan),
                            ),
                            SizedBox(width: 10),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
    );
  }

  //=====================================================================//
  //                          HELPER FUNCTION                            //
  //=====================================================================//
  // Dialog xác nhận xoá kế hoạch
  void _confirmDeletePlan(PlanModel plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text(
          'plan.delete_trip_title'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        content: Text(
          'plan.delete_trip_confirm'.tr(namedArgs: {'title': plan.title}),
          style: GoogleFonts.beVietnamPro(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'plan.cancel'.tr(),
              style: GoogleFonts.beVietnamPro(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PlanViewModel>().deletePlan(plan.id);
            },
            child: Text(
              'plan.delete'.tr(),
              style: GoogleFonts.beVietnamPro(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

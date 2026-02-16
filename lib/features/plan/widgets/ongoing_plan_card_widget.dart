// Widget hiển thị ongoing plan card
// Khi plan đang diễn ra, upcoming plan card sẽ tự động chuyển thành ongoing plan card
// Ongoing plan card hiển thị đầy đủ ngày, thông tin và progress bar
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/core/di/injection.dart'; // Sử dụng injection tại đây vì mỗi plan cần viewmodel riêng
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/features/plan/viewmodels/activity_plan_view_model.dart';
import 'package:travel_app/features/plan/screens/activity_plan_screen.dart';

class OngoingPlanCardWidget extends StatelessWidget {
  final PlanModel plan;
  const OngoingPlanCardWidget({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final progress = plan.totalDays > 0
        ? (plan.currentDay / plan.totalDays).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1,
          ),
        ),

        // Phần ảnh được hiển thị khi create plan sheet
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            height: 350,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Ảnh full card
                CachedNetworkImage(
                  imageUrl: plan.imageUrl.isNotEmpty
                      ? plan.imageUrl
                      : 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=600',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
                // Lớp đen mờ gradient
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                          Colors.black.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),
                // Nội dung nằm trên lớp mờ
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên của phần mục đã được tạo trước đó trong sheet
                        Text(
                          plan.title,
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Ngày thực hiện hành động trong khoảng ngày
                        Text(
                          plan.dateRangeText(context.locale.toString()),
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Đây là thanh progress bar cho biết thời điểm chuyển đi đã được diễn ra bao nhiu ngày
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFAD35),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Số ngày dẵ thực hiện của chuyến đi đó
                            Text(
                              'plan.day_progress'.tr(
                                namedArgs: {
                                  'current': '${plan.currentDay}',
                                  'total': '${plan.totalDays}',
                                },
                              ),
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Avatars từ plan.members
                            if (plan.members.isNotEmpty)
                              SizedBox(
                                width:
                                    (plan.members.length.clamp(0, 3) - 1) *
                                        14.0 +
                                    36,
                                height: 36,
                                child: Stack(
                                  children: [
                                    for (
                                      int i = 0;
                                      i < plan.members.length.clamp(0, 3);
                                      i++
                                    )
                                      Positioned(
                                        left: i * 14.0,
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Color(0xFFFFAD35),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 16,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                  plan
                                                          .members[i]
                                                          .avatarUrl
                                                          .isNotEmpty
                                                      ? plan
                                                            .members[i]
                                                            .avatarUrl
                                                      : 'https://i.pravatar.cc/100?img=${i + 1}',
                                                ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            const Spacer(),
                            // Phần mục xem chi tiết ấn vào để chuyển sang activity plan screen
                            Material(
                              color: Color(0xFFFFAD35),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider(
                                            create: (_) {
                                              final vm =
                                                  getIt<ActivityPlanViewModel>(
                                                    param1: plan,
                                                  );
                                              vm.loadPlan();
                                              return vm;
                                            },
                                            child: ActivityPlanScreen(
                                              plan: plan,
                                            ),
                                          ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'plan.view_details'.tr(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

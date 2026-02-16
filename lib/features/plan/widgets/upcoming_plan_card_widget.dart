// Widget hiển thị upcoming plan card, đây là plan được tạo trước ở tương lai
// Khi đến thời điểm bắt đầu, upcoming card sẽ tự động chuyển thành ongoing card
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/core/di/injection.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/features/plan/viewmodels/activity_plan_view_model.dart';
import 'package:travel_app/features/plan/screens/activity_plan_screen.dart';

class UpcomingPlanCardWidget extends StatelessWidget {
  final PlanModel plan;
  const UpcomingPlanCardWidget({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final maxAvatars = plan.members.length.clamp(0, 3);

    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) {
                final vm = getIt<ActivityPlanViewModel>(param1: plan);
                vm.loadPlan();
                return vm;
              },
              child: ActivityPlanScreen(plan: plan),
            ),
          ),
        );
      },
      child: Container(
        width: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Phần ảnh với avatars
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Stack(
                clipBehavior: Clip.antiAlias,
                children: [
                  // Ảnh
                  CachedNetworkImage(
                    imageUrl: plan.imageUrl.isNotEmpty
                        ? plan.imageUrl
                        : 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400',
                    height: 137,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: Colors.grey[800],
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),

                  // Avatars góc phải
                  if (plan.members.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: SizedBox(
                        width: (maxAvatars - 1) * 16.0 + 28,
                        height: 28,
                        child: Stack(
                          children: [
                            for (int i = 0; i < maxAvatars; i++)
                              Positioned(
                                left: i * 16.0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFFFF6D00),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundImage: CachedNetworkImageProvider(
                                      plan.members[i].avatarUrl.isNotEmpty
                                          ? plan.members[i].avatarUrl
                                          : 'https://i.pravatar.cc/100?img=${i + 1}',
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Phần thông tin ở dưới
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin về tên đã được đặt trước đó ở trong new_plan_card_widget
                  Text(
                    plan.title,
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4),

                  // Khoảng thời gian dặt ngày
                  Text(
                    plan.dateRangeText(context.locale.toString()),
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

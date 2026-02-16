import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/domain/models/plan_activity_model.dart';
import 'package:travel_app/domain/models/plan_model.dart';
import 'package:travel_app/features/plan/screens/plan_section_screen.dart';
import 'package:travel_app/features/plan/widgets/activity_timeline_item.dart';

// Bottom sheet để tiêu đề plan, khoảng ngày, timeline các activity.
class ActivityPlanSheet extends StatelessWidget {
  final PlanModel plan;
  final List<PlanActivityModel> activities;
  final int currentIndex;
  final ScrollController? scrollController;
  final VoidCallback? onAddTap;
  final VoidCallback? onCheckIn;
  final void Function(PlanActivityModel)? onUncheckIn;
  final void Function(PlanActivityModel)? onEditActivity;
  final void Function(PlanActivityModel)? onDeleteActivity;

  const ActivityPlanSheet({
    super.key,
    required this.plan,
    required this.activities,
    this.currentIndex = 0,
    this.scrollController,
    this.onAddTap,
    this.onCheckIn,
    this.onUncheckIn,
    this.onEditActivity,
    this.onDeleteActivity,
  });

  static final _timeFormat = DateFormat('HH:mm');

  void _confirmDelete(BuildContext context, PlanActivityModel activity) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Xóa điểm đến'),
        content: Text(
          'Bạn có chắc muốn xóa "${activity.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true) onDeleteActivity?.call(activity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  if (activities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Chưa có điểm đến nào. Thêm điểm để xem lộ trình.',
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._buildTimeline(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                plan.title,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: onAddTap ?? () => _openAddDestination(context),
              icon: const Icon(
                CupertinoIcons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          plan.dateRangeText('vi'),
          style: GoogleFonts.beVietnamPro(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  void _openAddDestination(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => OngoingPlanSectionScreen(
          planId: plan.id,
          destination: plan.destination,
          planStartDate: plan.startDate,
          planEndDate: plan.endDate,
        ),
      ),
    );
  }

  List<Widget> _buildTimeline(BuildContext context) {
    final list = <Widget>[];
    for (int i = 0; i < activities.length; i++) {
      final activity = activities[i];
      final isCurrent = i == currentIndex;
      final isPast = i < currentIndex;
      final timeStr = _timeFormat.format(activity.time);
      // Current = nổi bật; đã check-in = xanh/xám nhạt; chưa tới = xám.
      final textColor = isCurrent
          ? Colors.white
          : isPast
          ? Colors.white.withValues(alpha: 0.7)
          : Colors.white.withValues(alpha: 0.5);
      final timeColor = isCurrent
          ? Colors.white.withValues(alpha: 0.8)
          : isPast
          ? Colors.white.withValues(alpha: 0.75)
          : Colors.white.withValues(alpha: 0.5);

      // Đoạn nội dung nếu cái nào đang là current (cái mà hiện bảng check-in ngay)
      // Container lúc đó sẽ được dài ra và ngược lại
      final lineHeight = i >= activities.length - 1
          ? 30.0
          : (isCurrent ? 186.0 : 120.0);
      // Đoạn dọc nối với item tiếp theo nếu đã được check in thì màu xanh lá còn không thì ngược lại
      final lineColor = isPast
          ? Colors.green
          : Colors.white.withValues(alpha: 0.3);

      list.add(
        ActivityTimelineItem(
          activity: activity,
          isCurrent: isCurrent,
          isPast: isPast,
          timeStr: timeStr,
          textColor: textColor,
          timeColor: timeColor,
          lineHeight: i >= activities.length - 1 ? 30.0 : lineHeight,
          lineColor: lineColor,
          onUncheckIn: onUncheckIn,
          onEditActivity: onEditActivity,
          onDeleteActivity: (a) => _confirmDelete(context, a),
          onCheckIn: onCheckIn,
        ),
      );
    }
    return list;
  }
}
